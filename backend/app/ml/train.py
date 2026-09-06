"""Entrena el primer modelo de riesgo de inundación de Cauce.

Uso: python -m app.ml.train (desde backend/, con el venv activado y .env configurado)

Datos de entrenamiento: los eventos de inundación reales de `eventos_historicos`
(fuente: prensa/OCHA, ver database/seeds/05_eventos_historicos.sql) cruzados con
precipitación histórica real de NASA POWER (ver app/ml/features.py) en la fecha de
cada evento. Con solo 14 eventos reales esto es deliberadamente un "primer modelo"
(así lo llama la Fase 3 del plan): sirve para probar el pipeline completo
(entrenamiento -> predicción -> `predicciones_riesgo` -> API), no para calibrar un
sistema de alerta operativo. Se valida con leave-one-out por ser la única validación
cruzada razonable con un dataset de este tamaño, y el resultado se reporta tal cual,
sin maquillar su precisión.

IMPORTANTE: los 14 eventos son todos desastres documentados (severidad medio/alto/
critico) — ninguno es 'bajo', porque nadie reporta en prensa una lluvia que no causó
daños. Sin ejemplos negativos el modelo nunca aprende a distinguir un día tranquilo
de uno crítico (se probó: predecía 'critico' incluso con 0mm de lluvia). Para
corregirlo, se agregan ejemplos 'bajo' sintéticos: fechas alejadas (>45 días) de
cualquier evento registrado en ese municipio, asumiendo razonablemente que la
ausencia de un desastre documentado en una fecha así implica riesgo bajo. Es una
suposición, no un hecho verificado evento por evento — está declarada explícitamente
aquí y en la metadata del modelo.

No existe suficiente data real de deslizamiento (1 solo evento verificado) para
entrenar un modelo propio — ver app/ml/predict.py para cómo se maneja ese caso.
"""

import json
from datetime import date, datetime, timedelta
from pathlib import Path

import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import LeaveOneOut
from sqlalchemy import text

from app.database import SessionLocal
from app.ml.features import acumulados_desde_serie, centroide_municipio, lluvia_historica_nasa_power

SEVERIDAD_ORDINAL = {"bajo": 0, "medio": 1, "alto": 2, "critico": 3}
ORDINAL_SEVERIDAD = {v: k for k, v in SEVERIDAD_ORDINAL.items()}
FEATURES = ["lluvia_acum_7d", "lluvia_acum_15d", "lluvia_acum_30d"]
MODEL_PATH = Path(__file__).parent / "modelo_riesgo_inundacion.joblib"
META_PATH = Path(__file__).parent / "modelo_riesgo_inundacion.meta.json"


CANDIDATAS_BAJO = [date(y, m, 15) for y in (2005, 2008, 2012, 2017, 2022) for m in (1, 4, 7, 10)]


def _fechas_bajo_riesgo(fechas_evento: list[date], n: int = 3) -> list[date]:
    """Fechas candidatas a 'bajo' riesgo: a más de 45 días de cualquier evento real
    de ese municipio (ver advertencia de módulo sobre este supuesto)."""
    elegidas = []
    for candidata in CANDIDATAS_BAJO:
        if all(abs((candidata - fe).days) > 45 for fe in fechas_evento):
            elegidas.append(candidata)
        if len(elegidas) == n:
            break
    return elegidas


def construir_dataset():
    db = SessionLocal()
    try:
        eventos = db.execute(
            text("SELECT municipio_id, fecha, severidad FROM eventos_historicos WHERE tipo_evento = 'inundacion'")
        ).mappings().all()

        fechas_por_municipio: dict[int, list[date]] = {}
        for evento in eventos:
            fechas_por_municipio.setdefault(evento["municipio_id"], []).append(evento["fecha"])

        filas = []
        for evento in eventos:
            lon, lat = centroide_municipio(db, evento["municipio_id"])
            serie = lluvia_historica_nasa_power(lon, lat, evento["fecha"])
            acumulados = acumulados_desde_serie(serie, evento["fecha"])
            filas.append({**acumulados, "severidad": evento["severidad"], "municipio_id": evento["municipio_id"]})
            print(f"  [evento real] municipio_id={evento['municipio_id']} fecha={evento['fecha']} {acumulados} -> {evento['severidad']}")

        for municipio_id, fechas_evento in fechas_por_municipio.items():
            lon, lat = centroide_municipio(db, municipio_id)
            for fecha_bajo in _fechas_bajo_riesgo(fechas_evento):
                serie = lluvia_historica_nasa_power(lon, lat, fecha_bajo)
                acumulados = acumulados_desde_serie(serie, fecha_bajo)
                filas.append({**acumulados, "severidad": "bajo", "municipio_id": municipio_id})
                print(f"  [bajo riesgo, sin evento] municipio_id={municipio_id} fecha={fecha_bajo} {acumulados} -> bajo")

        return filas
    finally:
        db.close()


def entrenar():
    print("Descargando precipitación histórica real (NASA POWER) para cada evento...")
    filas = construir_dataset()

    X = np.array([[f[c] for c in FEATURES] for f in filas])
    y = np.array([SEVERIDAD_ORDINAL[f["severidad"]] for f in filas])

    n_reales = sum(1 for f in filas if f["severidad"] != "bajo")
    n_bajo = len(filas) - n_reales
    print(f"\nDataset de entrenamiento: {n_reales} eventos reales de inundación + {n_bajo} ejemplos 'bajo' sintéticos")

    print("\nValidación leave-one-out (n muy pequeño: resultado orientativo, no una métrica de producción):")
    loo = LeaveOneOut()
    aciertos = 0
    errores_ordinales = []
    for train_idx, test_idx in loo.split(X):
        modelo_cv = RandomForestClassifier(n_estimators=50, max_depth=3, random_state=42)
        modelo_cv.fit(X[train_idx], y[train_idx])
        pred = modelo_cv.predict(X[test_idx])[0]
        real = y[test_idx][0]
        aciertos += int(pred == real)
        errores_ordinales.append(abs(int(pred) - int(real)))

    exactitud = aciertos / len(filas)
    error_ordinal_medio = sum(errores_ordinales) / len(errores_ordinales)
    print(f"  Exactitud (clase exacta): {exactitud:.2%}")
    print(f"  Error ordinal medio (0=exacto, 1=un nivel de diferencia, etc.): {error_ordinal_medio:.2f}")

    modelo_final = RandomForestClassifier(n_estimators=50, max_depth=3, random_state=42)
    modelo_final.fit(X, y)

    version = "rf-inund-v1"  # version_modelo es VARCHAR(20); fecha completa de entrenamiento va en meta.json
    joblib.dump(modelo_final, MODEL_PATH)
    META_PATH.write_text(
        json.dumps(
            {
                "version_modelo": version,
                "features": FEATURES,
                "clases_ordinal": ORDINAL_SEVERIDAD,
                "n_entrenamiento": len(filas),
                "n_eventos_reales": n_reales,
                "n_bajo_sintetico": n_bajo,
                "loocv_exactitud": exactitud,
                "loocv_error_ordinal_medio": error_ordinal_medio,
                "fuente_entrenamiento": (
                    "eventos_historicos (prensa/OCHA) + NASA POWER PRECTOTCORR; "
                    "ejemplos 'bajo' son fechas sin evento registrado (>45 días de distancia), no verificados uno a uno"
                ),
                "entrenado_en": datetime.now().isoformat(),
                "advertencia": (
                    "Modelo preliminar entrenado con muestra muy pequeña (n="
                    f"{len(filas)}). No usar como única fuente de decisión operativa."
                ),
            },
            indent=2,
            ensure_ascii=False,
        )
    )
    print(f"\nModelo guardado en {MODEL_PATH}")
    print(f"Metadata guardada en {META_PATH}")
    return version


if __name__ == "__main__":
    entrenar()
