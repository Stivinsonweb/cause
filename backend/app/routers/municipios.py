from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.database import get_db
from app.geo_utils import polygon_wkt_to_geojson
from app.models.orm import EventoHistorico, PrediccionRiesgo, ReporteComunitario
from app.schemas import (
    EstadisticasOut,
    EventoHistoricoOut,
    HistoricoMunicipioOut,
    MedicionDiariaOut,
    MunicipioOut,
    ReporteComunitarioOut,
    RiesgoMunicipioOut,
    RiesgoTipoOut,
)

router = APIRouter(prefix="/municipios", tags=["municipios"])


@router.get("", response_model=list[MunicipioOut])
def listar_municipios(db: Session = Depends(get_db)):
    filas = db.execute(
        text(
            """
            SELECT id, nombre, departamento, poblacion_estimada, ST_AsText(geometria) AS geometria_wkt
            FROM municipios
            ORDER BY nombre
            """
        )
    ).mappings().all()
    return [
        MunicipioOut(
            id=fila["id"],
            nombre=fila["nombre"],
            departamento=fila["departamento"],
            poblacion_estimada=fila["poblacion_estimada"],
            geometria=polygon_wkt_to_geojson(fila["geometria_wkt"]) if fila["geometria_wkt"] else None,
        )
        for fila in filas
    ]


@router.get("/estadisticas", response_model=EstadisticasOut)
def estadisticas(db: Session = Depends(get_db)):
    fila = db.execute(
        text(
            """
            SELECT
                (SELECT COUNT(*) FROM municipios) AS total_municipios,
                (SELECT COALESCE(SUM(poblacion_estimada), 0) FROM municipios) AS poblacion_total,
                (SELECT COUNT(*) FROM estaciones WHERE activa = TRUE) AS estaciones_activas,
                (SELECT COUNT(*) FROM eventos_historicos) AS eventos_documentados
            """
        )
    ).mappings().one()
    return EstadisticasOut(**fila)


def _municipio_existe(db: Session, municipio_id: int) -> bool:
    return db.execute(
        text("SELECT 1 FROM municipios WHERE id = :id"), {"id": municipio_id}
    ).first() is not None


@router.get("/{municipio_id}/riesgo", response_model=RiesgoMunicipioOut)
def riesgo_municipio(municipio_id: int, db: Session = Depends(get_db)):
    if not _municipio_existe(db, municipio_id):
        raise HTTPException(status_code=404, detail="Municipio no encontrado")

    riesgos = []
    for tipo in ("inundacion", "deslizamiento", "sequia"):
        ultima = (
            db.query(PrediccionRiesgo)
            .filter(
                PrediccionRiesgo.municipio_id == municipio_id,
                PrediccionRiesgo.tipo_evento == tipo,
            )
            .order_by(PrediccionRiesgo.fecha_calculo.desc())
            .first()
        )
        if ultima is None:
            riesgos.append(
                RiesgoTipoOut(
                    tipo_evento=tipo,
                    nivel_riesgo=None,
                    probabilidad=None,
                    fecha_calculo=None,
                    variables_entrada=None,
                    version_modelo=None,
                )
            )
        else:
            riesgos.append(
                RiesgoTipoOut(
                    tipo_evento=tipo,
                    nivel_riesgo=ultima.nivel_riesgo,
                    probabilidad=float(ultima.probabilidad) if ultima.probabilidad is not None else None,
                    fecha_calculo=ultima.fecha_calculo,
                    variables_entrada=ultima.variables_entrada,
                    version_modelo=ultima.version_modelo,
                )
            )
    return RiesgoMunicipioOut(municipio_id=municipio_id, riesgos=riesgos)


@router.get("/{municipio_id}/historico", response_model=HistoricoMunicipioOut)
def historico_municipio(municipio_id: int, dias: int = 90, db: Session = Depends(get_db)):
    if not _municipio_existe(db, municipio_id):
        raise HTTPException(status_code=404, detail="Municipio no encontrado")

    eventos = (
        db.query(EventoHistorico)
        .filter(EventoHistorico.municipio_id == municipio_id)
        .order_by(EventoHistorico.fecha.desc())
        .all()
    )

    filas = db.execute(
        text(
            """
            SELECT
                m.fecha_hora::date AS fecha,
                AVG(m.lluvia_mm) AS lluvia_mm_promedio,
                AVG(m.nivel_rio_m) AS nivel_rio_m_promedio
            FROM mediciones m
            JOIN estaciones e ON e.id = m.estacion_id
            WHERE e.municipio_id = :municipio_id
              AND m.fecha_hora >= NOW() - make_interval(days => :dias)
            GROUP BY m.fecha_hora::date
            ORDER BY fecha ASC
            """
        ),
        {"municipio_id": municipio_id, "dias": dias},
    ).mappings().all()

    mediciones_diarias = [
        MedicionDiariaOut(
            fecha=fila["fecha"],
            lluvia_mm_promedio=float(fila["lluvia_mm_promedio"]) if fila["lluvia_mm_promedio"] is not None else None,
            nivel_rio_m_promedio=float(fila["nivel_rio_m_promedio"]) if fila["nivel_rio_m_promedio"] is not None else None,
        )
        for fila in filas
    ]

    return HistoricoMunicipioOut(
        municipio_id=municipio_id,
        eventos=eventos,
        mediciones_diarias=mediciones_diarias,
    )


@router.get("/{municipio_id}/reportes", response_model=list[ReporteComunitarioOut])
def reportes_verificados_municipio(municipio_id: int, db: Session = Depends(get_db)):
    """Solo reportes ciudadanos ya moderados como 'verificado' — nunca pendientes
    ni descartados. Este endpoint es público a propósito, por eso no acepta un
    parámetro `estado`: filtrar por otro estado queda solo en /reportes (protegido)."""
    if not _municipio_existe(db, municipio_id):
        raise HTTPException(status_code=404, detail="Municipio no encontrado")

    return (
        db.query(ReporteComunitario)
        .filter(ReporteComunitario.municipio_id == municipio_id, ReporteComunitario.estado == "verificado")
        .order_by(ReporteComunitario.creado_en.desc())
        .all()
    )
