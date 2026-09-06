"""Tarea programada de ingestión.

La API de datos en tiempo real de IDEAM (DHIME) requiere registro/acceso que este
proyecto aún no tiene configurado (ver IDEAM_API_KEY en .env). Mientras tanto, esta
tarea genera lecturas simuladas (fuente='simulado') para las estaciones activas, con
la misma forma que tendrían los datos reales, para poder ejercitar el resto del
pipeline (predicciones, alertas, frontend) de punta a punta. Cuando se disponga de
acceso a la API real, solo hay que reemplazar `_generar_lectura_simulada` por la
llamada HTTP real a IDEAM.
"""

import logging
import random
from datetime import datetime, timezone

from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import text

from app.database import SessionLocal
from app.models.orm import RegistroIngestion

logger = logging.getLogger("cauce.ingesta")


def _generar_lectura_simulada() -> dict:
    return {
        "lluvia_mm": round(random.uniform(0, 40), 2),
        "nivel_rio_m": round(random.uniform(1, 5), 2),
    }


def ejecutar_ingestion() -> None:
    db = SessionLocal()
    try:
        estaciones = db.execute(
            text("SELECT id FROM estaciones WHERE activa = TRUE")
        ).all()

        ahora = datetime.now(timezone.utc)
        for (estacion_id,) in estaciones:
            lectura = _generar_lectura_simulada()
            db.execute(
                text(
                    """
                    INSERT INTO mediciones (estacion_id, fecha_hora, lluvia_mm, nivel_rio_m, fuente)
                    VALUES (:estacion_id, :fecha_hora, :lluvia_mm, :nivel_rio_m, 'simulado')
                    """
                ),
                {
                    "estacion_id": estacion_id,
                    "fecha_hora": ahora,
                    "lluvia_mm": lectura["lluvia_mm"],
                    "nivel_rio_m": lectura["nivel_rio_m"],
                },
            )

        estado = "exitoso" if estaciones else "parcial"
        detalle = f"{len(estaciones)} estaciones procesadas (datos simulados, IDEAM API pendiente de integrar)"
        db.add(RegistroIngestion(fuente="IDEAM", estado=estado, detalle=detalle))
        db.commit()
        logger.info(detalle)
    except Exception as exc:  # noqa: BLE001
        db.rollback()
        db.add(RegistroIngestion(fuente="IDEAM", estado="fallido", detalle=str(exc)))
        db.commit()
        logger.exception("Fallo la ingestión programada")
    finally:
        db.close()

    _recalcular_riesgo()


def _recalcular_riesgo() -> None:
    """Tras cada ingestión, recalcula el riesgo de todos los municipios con el
    modelo entrenado (ver app/ml/predict.py). Si el modelo aún no se ha entrenado
    (Fase 3 no ejecutada), simplemente no hace nada — /municipios/{id}/riesgo sigue
    devolviendo nivel_riesgo=null hasta entonces."""
    from app.ml.predict import calcular_riesgo_todos_los_municipios

    db = SessionLocal()
    try:
        n = calcular_riesgo_todos_los_municipios(db)
        logger.info(f"Riesgo recalculado para {n} municipios")
    except RuntimeError:
        logger.info("Modelo de riesgo no entrenado aún; se omite el recálculo")
    except Exception:  # noqa: BLE001
        db.rollback()
        logger.exception("Fallo el recálculo de riesgo")
    finally:
        db.close()


def iniciar_scheduler() -> BackgroundScheduler:
    scheduler = BackgroundScheduler(timezone="UTC")
    scheduler.add_job(ejecutar_ingestion, "interval", hours=1, id="ingestion_ideam")
    scheduler.start()
    return scheduler
