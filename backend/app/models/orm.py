from sqlalchemy import (
    Column,
    Date,
    DateTime,
    Enum,
    Integer,
    JSON,
    Numeric,
    String,
    Text,
    func,
)

from app.database import Base

# native_enum=False: usamos VARCHAR + CHECK en el esquema (ver database/schema.sql),
# no un tipo ENUM nativo de Postgres. Sin esto, SQLAlchemy asume que existe un tipo
# nativo con el `name` dado y falla con "type ... does not exist" al insertar.


class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True)
    nombre = Column(String(150))
    correo = Column(String(150), unique=True, nullable=False)
    contrasena_hash = Column(String(255), nullable=False)
    rol = Column(
        Enum("ciudadano", "entidad", "admin", name="rol_usuario", native_enum=False),
        nullable=False,
        default="entidad",
    )
    municipio_id = Column(Integer)
    creado_en = Column(DateTime(timezone=True), server_default=func.now())


class EventoHistorico(Base):
    __tablename__ = "eventos_historicos"

    id = Column(Integer, primary_key=True)
    municipio_id = Column(Integer, nullable=False)
    tipo_evento = Column(
        Enum("inundacion", "deslizamiento", "sequia", name="tipo_evento_historico", native_enum=False),
        nullable=False,
    )
    fecha = Column(Date, nullable=False)
    severidad = Column(
        Enum("bajo", "medio", "alto", "critico", name="severidad_evento", native_enum=False), nullable=False
    )
    fuente = Column(String(100), default="UNGRD")
    descripcion = Column(Text)


class PrediccionRiesgo(Base):
    __tablename__ = "predicciones_riesgo"

    id = Column(Integer, primary_key=True)
    municipio_id = Column(Integer, nullable=False)
    tipo_evento = Column(
        Enum("inundacion", "deslizamiento", "sequia", name="tipo_evento_prediccion", native_enum=False),
        nullable=False,
    )
    fecha_calculo = Column(DateTime(timezone=True), nullable=False)
    nivel_riesgo = Column(
        Enum("bajo", "medio", "alto", "critico", name="nivel_riesgo_prediccion", native_enum=False), nullable=False
    )
    probabilidad = Column(Numeric(5, 4))
    variables_entrada = Column(JSON)
    version_modelo = Column(String(20))


class Medicion(Base):
    __tablename__ = "mediciones"

    id = Column(Integer, primary_key=True)
    estacion_id = Column(Integer, nullable=False)
    fecha_hora = Column(DateTime(timezone=True), nullable=False)
    lluvia_mm = Column(Numeric(6, 2))
    nivel_rio_m = Column(Numeric(5, 2))
    fuente = Column(String(50), default="IDEAM")


class RegistroIngestion(Base):
    __tablename__ = "registro_ingestion"

    id = Column(Integer, primary_key=True)
    fuente = Column(String(50))
    ejecutado_en = Column(DateTime(timezone=True), server_default=func.now())
    estado = Column(
        Enum("exitoso", "fallido", "parcial", name="estado_ingestion", native_enum=False), nullable=False
    )
    detalle = Column(Text)
