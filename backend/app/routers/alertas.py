from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas import AlertaActivaOut

router = APIRouter(prefix="/alertas", tags=["alertas"])


@router.get("/activas", response_model=list[AlertaActivaOut])
def alertas_activas(horas: int = 24, db: Session = Depends(get_db)):
    """Última predicción por municipio+tipo_evento, calculada en las últimas `horas`,
    cuyo nivel de riesgo no es 'bajo'."""
    filas = db.execute(
        text(
            """
            SELECT p.municipio_id, m.nombre AS municipio_nombre, p.tipo_evento,
                   p.nivel_riesgo, p.fecha_calculo
            FROM predicciones_riesgo p
            JOIN municipios m ON m.id = p.municipio_id
            JOIN (
                SELECT municipio_id, tipo_evento, MAX(fecha_calculo) AS max_fecha
                FROM predicciones_riesgo
                GROUP BY municipio_id, tipo_evento
            ) ultimas
              ON ultimas.municipio_id = p.municipio_id
             AND ultimas.tipo_evento = p.tipo_evento
             AND ultimas.max_fecha = p.fecha_calculo
            WHERE p.nivel_riesgo <> 'bajo'
              AND p.fecha_calculo >= DATE_SUB(NOW(), INTERVAL :horas HOUR)
            ORDER BY FIELD(p.nivel_riesgo, 'critico', 'alto', 'medio'), p.fecha_calculo DESC
            """
        ),
        {"horas": horas},
    ).mappings().all()

    return [
        AlertaActivaOut(
            municipio_id=fila["municipio_id"],
            municipio_nombre=fila["municipio_nombre"],
            tipo_evento=fila["tipo_evento"],
            nivel_riesgo=fila["nivel_riesgo"],
            fecha_calculo=fila["fecha_calculo"],
        )
        for fila in filas
    ]
