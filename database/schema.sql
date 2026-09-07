-- Esquema de base de datos Cauce (PostgreSQL 15+ / PostGIS, ej. Supabase)
-- Ver docs/proyecto-cauce-contexto.md sección 4 para el contexto completo.
-- Migrado desde MySQL: ver docs/despliegue.md para las diferencias relevantes.

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE municipios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL DEFAULT 'Chocó',
    geometria geometry(Polygon, 4326) NOT NULL,
    poblacion_estimada INT
);
CREATE INDEX idx_municipios_geometria ON municipios USING GIST (geometria);

CREATE TABLE cuencas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rio_principal VARCHAR(100),
    geometria geometry(Polygon, 4326) NOT NULL
);
CREATE INDEX idx_cuencas_geometria ON cuencas USING GIST (geometria);

CREATE TABLE municipio_cuenca (
    municipio_id INT NOT NULL REFERENCES municipios(id),
    cuenca_id INT NOT NULL REFERENCES cuencas(id),
    PRIMARY KEY (municipio_id, cuenca_id)
);

CREATE TABLE estaciones (
    id SERIAL PRIMARY KEY,
    codigo_ideam VARCHAR(50) UNIQUE,
    nombre VARCHAR(150),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('pluviometrica', 'hidrometrica', 'mixta')),
    ubicacion geometry(Point, 4326) NOT NULL,
    municipio_id INT REFERENCES municipios(id),
    activa BOOLEAN DEFAULT TRUE
);
CREATE INDEX idx_estaciones_ubicacion ON estaciones USING GIST (ubicacion);

CREATE TABLE mediciones (
    id BIGSERIAL PRIMARY KEY,
    estacion_id INT NOT NULL REFERENCES estaciones(id),
    fecha_hora TIMESTAMPTZ NOT NULL,
    lluvia_mm DECIMAL(6, 2),
    nivel_rio_m DECIMAL(5, 2),
    fuente VARCHAR(50) DEFAULT 'IDEAM'
);
CREATE INDEX idx_estacion_fecha ON mediciones (estacion_id, fecha_hora);

CREATE TABLE eventos_historicos (
    id SERIAL PRIMARY KEY,
    municipio_id INT NOT NULL REFERENCES municipios(id),
    tipo_evento VARCHAR(20) NOT NULL CHECK (tipo_evento IN ('inundacion', 'deslizamiento', 'sequia')),
    fecha DATE NOT NULL,
    severidad VARCHAR(10) NOT NULL CHECK (severidad IN ('bajo', 'medio', 'alto', 'critico')),
    fuente VARCHAR(100) DEFAULT 'UNGRD',
    descripcion TEXT
);

CREATE TABLE predicciones_riesgo (
    id BIGSERIAL PRIMARY KEY,
    municipio_id INT NOT NULL REFERENCES municipios(id),
    tipo_evento VARCHAR(20) NOT NULL CHECK (tipo_evento IN ('inundacion', 'deslizamiento', 'sequia')),
    fecha_calculo TIMESTAMPTZ NOT NULL,
    nivel_riesgo VARCHAR(10) NOT NULL CHECK (nivel_riesgo IN ('bajo', 'medio', 'alto', 'critico')),
    probabilidad DECIMAL(5, 4),
    variables_entrada JSONB,
    version_modelo VARCHAR(20)
);
CREATE INDEX idx_municipio_fecha ON predicciones_riesgo (municipio_id, fecha_calculo);

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150),
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(10) NOT NULL DEFAULT 'entidad' CHECK (rol IN ('ciudadano', 'entidad', 'admin')),
    municipio_id INT REFERENCES municipios(id),
    creado_en TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registro_ingestion (
    id BIGSERIAL PRIMARY KEY,
    fuente VARCHAR(50),
    ejecutado_en TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(10) NOT NULL CHECK (estado IN ('exitoso', 'fallido', 'parcial')),
    detalle TEXT
);

-- Canal de verificación comunitaria (ver database/migrations/002_reportes_comunitarios.sql)
CREATE TABLE reportes_comunitarios (
    id BIGSERIAL PRIMARY KEY,
    municipio_id INT NOT NULL REFERENCES municipios(id),
    tipo_evento VARCHAR(20) NOT NULL CHECK (tipo_evento IN ('inundacion', 'deslizamiento', 'sequia')),
    descripcion TEXT,
    foto_url VARCHAR(255),
    zona_aproximada VARCHAR(150),
    estado VARCHAR(15) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'verificado', 'descartado')),
    creado_en TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    moderado_por INT REFERENCES usuarios(id),
    moderado_en TIMESTAMPTZ,
    ip_hash VARCHAR(64)
);
CREATE INDEX idx_reportes_municipio_estado ON reportes_comunitarios (municipio_id, estado);
