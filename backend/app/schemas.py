from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, Field


class MunicipioOut(BaseModel):
    id: int
    nombre: str
    departamento: str
    poblacion_estimada: int | None
    geometria: dict | None  # GeoJSON


class RiesgoTipoOut(BaseModel):
    tipo_evento: str
    nivel_riesgo: str | None
    probabilidad: float | None
    fecha_calculo: datetime | None
    variables_entrada: dict | None
    version_modelo: str | None


class RiesgoMunicipioOut(BaseModel):
    municipio_id: int
    riesgos: list[RiesgoTipoOut]


class EventoHistoricoOut(BaseModel):
    id: int
    tipo_evento: str
    fecha: date
    severidad: str
    fuente: str
    descripcion: str | None

    class Config:
        from_attributes = True


class MedicionDiariaOut(BaseModel):
    fecha: date
    lluvia_mm_promedio: float | None
    nivel_rio_m_promedio: float | None


class HistoricoMunicipioOut(BaseModel):
    municipio_id: int
    eventos: list[EventoHistoricoOut]
    mediciones_diarias: list[MedicionDiariaOut]


class AlertaActivaOut(BaseModel):
    municipio_id: int
    municipio_nombre: str
    tipo_evento: str
    nivel_riesgo: str
    fecha_calculo: datetime


class LoginRequest(BaseModel):
    correo: str
    contrasena: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    rol: str


class RegistroIngestionOut(BaseModel):
    id: int
    fuente: str | None
    ejecutado_en: datetime
    estado: str
    detalle: str | None

    class Config:
        from_attributes = True


class EstadisticasOut(BaseModel):
    total_municipios: int
    poblacion_total: int
    estaciones_activas: int
    eventos_documentados: int


TipoEventoReporte = Literal["inundacion", "deslizamiento", "sequia"]
EstadoReporte = Literal["pendiente", "verificado", "descartado"]


class ReporteComunitarioCrear(BaseModel):
    municipio_id: int
    tipo_evento: TipoEventoReporte
    descripcion: str | None = Field(default=None, max_length=1000)
    zona_aproximada: str | None = Field(default=None, max_length=150)
    # foto_url deliberadamente no expuesto aún: no hay almacenamiento de
    # archivos configurado (ver docs/despliegue.md). El campo existe en el
    # esquema para cuando se agregue.


class ReporteComunitarioOut(BaseModel):
    id: int
    municipio_id: int
    tipo_evento: str
    descripcion: str | None
    foto_url: str | None
    zona_aproximada: str | None
    estado: str
    creado_en: datetime

    class Config:
        from_attributes = True


class ReporteComunitarioModeracionPatch(BaseModel):
    estado: EstadoReporte
