"""Subida de fotos de reportes comunitarios a Supabase Storage.

Se sube desde el backend (no directo del navegador a Supabase) a propósito:
así la misma protección contra spam de POST /reportes (rate limit de 5/hora
por IP) también cubre las fotos — un cliente no puede subir fotos sin pasar
por ese límite. Usa la Storage REST API de Supabase directamente (con
`requests`, ya es dependencia del proyecto) en vez de una librería cliente
aparte, con la service key (bypassa RLS; nunca se expone al frontend).
"""

import uuid

import requests

from app.config import settings

BUCKET = "reportes-fotos"
TIPOS_PERMITIDOS = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}
TAMANO_MAXIMO_BYTES = 5 * 1024 * 1024  # 5MB, igual que el límite configurado en el bucket


class FotoInvalida(Exception):
    pass


def subir_foto_reporte(contenido: bytes, content_type: str) -> str:
    if content_type not in TIPOS_PERMITIDOS:
        raise FotoInvalida("Formato de imagen no soportado (solo JPEG, PNG o WEBP).")
    if len(contenido) > TAMANO_MAXIMO_BYTES:
        raise FotoInvalida("La imagen supera el tamaño máximo permitido (5MB).")

    extension = TIPOS_PERMITIDOS[content_type]
    ruta = f"{uuid.uuid4()}.{extension}"

    resp = requests.post(
        f"{settings.supabase_url}/storage/v1/object/{BUCKET}/{ruta}",
        headers={
            "apikey": settings.supabase_service_key,
            "Authorization": f"Bearer {settings.supabase_service_key}",
            "Content-Type": content_type,
        },
        data=contenido,
        timeout=30,
    )
    resp.raise_for_status()

    return f"{settings.supabase_url}/storage/v1/object/public/{BUCKET}/{ruta}"
