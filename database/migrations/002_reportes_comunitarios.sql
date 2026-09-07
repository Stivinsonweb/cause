-- Canal de verificación comunitaria (propuesta de diseño del usuario, 2026-09-07).
-- Adaptado a las convenciones del proyecto: VARCHAR+CHECK en vez de ENUM nativo,
-- BIGSERIAL en vez de BIGINT AUTO_INCREMENT, TIMESTAMPTZ en vez de DATETIME.

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
