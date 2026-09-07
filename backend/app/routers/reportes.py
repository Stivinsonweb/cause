"""Canal de verificación comunitaria.

Ningún reporte se muestra públicamente hasta que un usuario con rol entidad o
admin lo marque como 'verificado' — ver el flujo de moderación abajo. Esto es
deliberado: evita pánico por un reporte falso y mantiene el modelo automático y
los reportes ciudadanos como dos fuentes separadas, nunca fusionadas en un solo
número (así lo consume el frontend: "el modelo estima X" junto a, si aplica,
"N reportes ciudadanos verificados").

POST /reportes acepta multipart/form-data (no JSON) porque la foto opcional se
sube en la misma petición — así el límite de 5/hora por IP también protege la
subida de fotos, no solo el texto del reporte.
"""

import hashlib
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, Request, UploadFile
from pydantic import ValidationError
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.orm import ReporteComunitario
from app.rate_limit import limiter
from app.schemas import (
    EstadoReporte,
    ReporteComunitarioCrear,
    ReporteComunitarioModeracionPatch,
    ReporteComunitarioOut,
)
from app.security import require_role
from app.storage import FotoInvalida, subir_foto_reporte

router = APIRouter(prefix="/reportes", tags=["reportes"])


def _hash_ip(ip: str) -> str:
    return hashlib.sha256(ip.encode()).hexdigest()


@router.post("", response_model=ReporteComunitarioOut, status_code=201)
@limiter.limit("5/hour")
def crear_reporte(
    request: Request,
    municipio_id: int = Form(...),
    tipo_evento: str = Form(...),
    descripcion: str | None = Form(default=None),
    zona_aproximada: str | None = Form(default=None),
    foto: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
):
    try:
        datos = ReporteComunitarioCrear(
            municipio_id=municipio_id,
            tipo_evento=tipo_evento,  # type: ignore[arg-type]
            descripcion=descripcion,
            zona_aproximada=zona_aproximada,
        )
    except ValidationError as exc:
        raise HTTPException(status_code=422, detail=exc.errors())

    existe = db.execute(text("SELECT 1 FROM municipios WHERE id = :id"), {"id": datos.municipio_id}).first()
    if existe is None:
        raise HTTPException(status_code=404, detail="Municipio no encontrado")

    foto_url = None
    if foto is not None and foto.filename:
        try:
            foto_url = subir_foto_reporte(foto.file.read(), foto.content_type or "")
        except FotoInvalida as exc:
            raise HTTPException(status_code=422, detail=str(exc))

    reporte = ReporteComunitario(
        municipio_id=datos.municipio_id,
        tipo_evento=datos.tipo_evento,
        descripcion=datos.descripcion,
        zona_aproximada=datos.zona_aproximada,
        foto_url=foto_url,
        estado="pendiente",
        ip_hash=_hash_ip(request.client.host if request.client else "desconocido"),
    )
    db.add(reporte)
    db.commit()
    db.refresh(reporte)
    return reporte


@router.get("", response_model=list[ReporteComunitarioOut], dependencies=[Depends(require_role("entidad", "admin"))])
def listar_reportes_moderacion(estado: EstadoReporte | None = Query(default=None), db: Session = Depends(get_db)):
    consulta = db.query(ReporteComunitario)
    if estado is not None:
        consulta = consulta.filter(ReporteComunitario.estado == estado)
    return consulta.order_by(ReporteComunitario.creado_en.desc()).all()


@router.patch("/{reporte_id}", response_model=ReporteComunitarioOut)
def moderar_reporte(
    reporte_id: int,
    datos: ReporteComunitarioModeracionPatch,
    db: Session = Depends(get_db),
    usuario: dict = Depends(require_role("entidad", "admin")),
):
    reporte = db.query(ReporteComunitario).filter(ReporteComunitario.id == reporte_id).first()
    if reporte is None:
        raise HTTPException(status_code=404, detail="Reporte no encontrado")

    reporte.estado = datos.estado
    reporte.moderado_por = usuario["usuario_id"]
    reporte.moderado_en = datetime.now(timezone.utc)
    db.commit()
    db.refresh(reporte)
    return reporte
