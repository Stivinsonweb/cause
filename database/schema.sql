-- Esquema de base de datos Cauce (MySQL 8+)
-- Ver docs/proyecto-cauce-contexto.md sección 4 para el contexto completo.

CREATE TABLE municipios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL DEFAULT 'Chocó',
    geometria POLYGON NOT NULL SRID 4326,
    poblacion_estimada INT,
    SPATIAL INDEX(geometria)
);

CREATE TABLE cuencas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    rio_principal VARCHAR(100),
    geometria POLYGON NOT NULL SRID 4326,
    SPATIAL INDEX(geometria)
);

CREATE TABLE municipio_cuenca (
    municipio_id INT NOT NULL,
    cuenca_id INT NOT NULL,
    PRIMARY KEY (municipio_id, cuenca_id),
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    FOREIGN KEY (cuenca_id) REFERENCES cuencas(id)
);

CREATE TABLE estaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_ideam VARCHAR(50) UNIQUE,
    nombre VARCHAR(150),
    tipo ENUM('pluviometrica', 'hidrometrica', 'mixta') NOT NULL,
    ubicacion POINT NOT NULL SRID 4326,
    municipio_id INT,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    SPATIAL INDEX(ubicacion)
);

CREATE TABLE mediciones (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    estacion_id INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    lluvia_mm DECIMAL(6,2),
    nivel_rio_m DECIMAL(5,2),
    fuente VARCHAR(50) DEFAULT 'IDEAM',
    FOREIGN KEY (estacion_id) REFERENCES estaciones(id),
    INDEX idx_estacion_fecha (estacion_id, fecha_hora)
);

CREATE TABLE eventos_historicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    municipio_id INT NOT NULL,
    tipo_evento ENUM('inundacion', 'deslizamiento') NOT NULL,
    fecha DATE NOT NULL,
    severidad ENUM('bajo', 'medio', 'alto', 'critico') NOT NULL,
    fuente VARCHAR(100) DEFAULT 'UNGRD',
    descripcion TEXT,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id)
);

CREATE TABLE predicciones_riesgo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    municipio_id INT NOT NULL,
    tipo_evento ENUM('inundacion', 'deslizamiento') NOT NULL,
    fecha_calculo DATETIME NOT NULL,
    nivel_riesgo ENUM('bajo', 'medio', 'alto', 'critico') NOT NULL,
    probabilidad DECIMAL(5,4),
    variables_entrada JSON,
    version_modelo VARCHAR(20),
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    INDEX idx_municipio_fecha (municipio_id, fecha_calculo)
);

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150),
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol ENUM('ciudadano', 'entidad', 'admin') NOT NULL DEFAULT 'entidad',
    municipio_id INT,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id)
);

CREATE TABLE registro_ingestion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fuente VARCHAR(50),
    ejecutado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('exitoso', 'fallido', 'parcial') NOT NULL,
    detalle TEXT
);
