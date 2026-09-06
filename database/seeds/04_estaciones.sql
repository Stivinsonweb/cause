-- ============================================================
-- Fuente: Catálogo Nacional de Estaciones del IDEAM (datos.gov.co, dataset hp9r-jxuu)
-- https://www.datos.gov.co/Ambiente-y-Desarrollo-Sostenible/Cat-logo-Nacional-de-Estaciones-del-IDEAM/hp9r-jxuu
-- Consultado: 2026-09-06, filtrado por departamento=Choco, municipio en los 6 del MVP.
-- WKT: ST_PointFromText('POINT(lon lat)', 4326) -- longitud primero, luego latitud.
-- `activa` refleja el estado real del catálogo (TRUE solo si estado='Activa'; el
-- estado original de cada estación va en el comentario de fin de línea).
-- Antes de producción: verificar decimales de lat/lon contra el CSV oficial
-- (https://www.datos.gov.co/resource/hp9r-jxuu.csv?$limit=50000), ya que esta
-- extracción pasó por una herramienta intermedia de fetch.
-- ============================================================

-- ---------- QUIBDÓ ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0011040010', 'TUTUNENDO',            'pluviometrica', ST_PointFromText('POINT(-76.53780556 5.743611111)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), TRUE),   -- Activa
('0011047020', 'QUIBDO',               'hidrometrica',  ST_PointFromText('POINT(-76.662222222 5.697778056)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), TRUE),   -- Limnigráfica, Activa
('0011050010', 'TAGACHI',              'pluviometrica', ST_PointFromText('POINT(-76.72702778 6.221777778)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), TRUE),   -- Activa
('0011030060', 'INST DEL CHOCO',       'pluviometrica', ST_PointFromText('POINT(-76.66666667 5.683333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Suspendida
('0011047030', 'NEGUA',                'hidrometrica',  ST_PointFromText('POINT(-76.618016667 5.828168889)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Limnimétrica, Suspendida
('0011030050', 'QUIBDO',               'pluviometrica', ST_PointFromText('POINT(-76.68333333 5.683333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Suspendida
('0011045030', 'HUAPANGO',             'mixta',         ST_PointFromText('POINT(-76.63333333 5.7)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0011045010', 'AEROPUERTO EL CARAÑO', 'mixta',         ST_PointFromText('POINT(-76.64377778 5.690555556)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), TRUE),   -- Sinóptica Principal, Activa
('0011057010', 'TAGACHI',              'hidrometrica',  ST_PointFromText('POINT(-76.71666667 6.216666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Limnimétrica, Suspendida
('0011047040', 'QUIBDO',               'hidrometrica',  ST_PointFromText('POINT(-76.66222222 5.697778056)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Limnigráfica, Suspendida
('0011050040', 'CALAORRA',             'pluviometrica', ST_PointFromText('POINT(-76.85 5.766666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), FALSE),  -- Suspendida
('0011047010', 'BELÉN - AUT',          'hidrometrica',  ST_PointFromText('POINT(-76.669666667 5.764858333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Quibdó'), TRUE);   -- Limnigráfica, Activa

-- ---------- ISTMINA ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0054017030', 'ISTMINA - AUT',  'hidrometrica',  ST_PointFromText('POINT(-76.68286111 5.154166667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), TRUE),   -- Limnigráfica, Activa
('0054010010', 'ISTMINA',        'mixta',         ST_PointFromText('POINT(-76.689222222 5.15875)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), TRUE),   -- Climatológica Ordinaria, Activa
('0054017010', 'MUNGUIDO',       'hidrometrica',  ST_PointFromText('POINT(-76.66666667 5.266666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Limnimétrica, Suspendida
('0054010100', 'CEFERINA LA',    'pluviometrica', ST_PointFromText('POINT(-76.65 5.166666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Suspendida
('0055010020', 'PIE DE PEPE',    'pluviometrica', ST_PointFromText('POINT(-76.82472222 5.118416667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), TRUE),   -- Activa
('0054025040', 'ANDAGOYA',       'mixta',         ST_PointFromText('POINT(-76.71666667 5.133333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0054027010', 'YAMAQUE',        'hidrometrica',  ST_PointFromText('POINT(-76.66666667 5.083333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Limnigráfica, Suspendida
('0054087020', 'NOANAMA PUEBLO', 'hidrometrica',  ST_PointFromText('POINT(-76.95 4.666666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Limnimétrica, Suspendida
('0054050020', 'NOANAMA',        'pluviometrica', ST_PointFromText('POINT(-76.86666667 4.666666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), FALSE),  -- Pluviográfica, Suspendida
('0054050010', 'NOANAMA',        'mixta',         ST_PointFromText('POINT(-76.916666667 4.716666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Istmina'), TRUE);   -- Climatológica Ordinaria, Activa

-- ---------- CONDOTO ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0054020070', 'CONDOTO',            'pluviometrica', ST_PointFromText('POINT(-76.61666667 5.1)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), FALSE),  -- Suspendida
('0054025030', 'SAN JOSE',           'mixta',         ST_PointFromText('POINT(-76.6 5.1)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0054020090', 'AEROPUERTO CONDOTO', 'mixta',         ST_PointFromText('POINT(-76.676666667 5.0735)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), TRUE),   -- Climatológica Ordinaria, Activa
('0054020060', 'OPOGODO',            'pluviometrica', ST_PointFromText('POINT(-76.65 5.06)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), TRUE),   -- Activa
('0054025020', 'AEROPUERTO CONDOTO', 'mixta',         ST_PointFromText('POINT(-76.67666667 5.0735)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), FALSE),  -- Climatológica Principal, Suspendida
('0054027020', 'BOCAS DE IRO',       'hidrometrica',  ST_PointFromText('POINT(-76.683 5.105527778)', 4326), (SELECT id FROM municipios WHERE nombre = 'Condoto'), FALSE);  -- Limnigráfica, En Mantenimiento

-- ---------- TADÓ ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0054017040', 'TADO - AUT', 'hidrometrica', ST_PointFromText('POINT(-76.56275 5.265111111)', 4326), (SELECT id FROM municipios WHERE nombre = 'Tadó'), TRUE),   -- Limnigráfica, Activa
('0054017100', 'ANTON',      'hidrometrica', ST_PointFromText('POINT(-76.03333333 5.266666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Tadó'), TRUE),   -- Limnigráfica, Activa
('0054015020', 'TADO - AUT', 'mixta',        ST_PointFromText('POINT(-76.551836111 5.270111111)', 4326), (SELECT id FROM municipios WHERE nombre = 'Tadó'), FALSE);  -- Climatológica Ordinaria, En Mantenimiento

-- ---------- RIOSUCIO ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0011125010', 'TERESITA LA', 'mixta',         ST_PointFromText('POINT(-77.5 7.0)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0011135010', 'SAUTATA',     'mixta',         ST_PointFromText('POINT(-77.11666667 7.85)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0011147020', 'BAJIRA',      'hidrometrica',  ST_PointFromText('POINT(-76.72727778 7.368444444)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Limnigráfica, Suspendida
('0011120040', 'RIOSUCIO',    'mixta',         ST_PointFromText('POINT(-77.11527778 7.439444444)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Climatológica Ordinaria, En Mantenimiento
('0011127010', 'NUEVA LA',    'hidrometrica',  ST_PointFromText('POINT(-77.16666667 7.316666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Limnimétrica, Suspendida
('0011135020', 'BALSA LA',    'mixta',         ST_PointFromText('POINT(-77.2 7.516666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0011145010', 'BAJIRA',      'mixta',         ST_PointFromText('POINT(-76.66666667 7.383333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Climatológica Ordinaria, Suspendida
('0011130020', 'HONDA LA',    'pluviometrica', ST_PointFromText('POINT(-77.12555556 7.576666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Suspendida
('0011130030', 'SAUTATA',     'pluviometrica', ST_PointFromText('POINT(-77.16666667 7.866666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE),  -- Suspendida
('0011147010', 'RIOSUCIO',    'hidrometrica',  ST_PointFromText('POINT(-77.12 7.44)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), TRUE),   -- Limnimétrica, Activa
('0011120010', 'SALAQUI',     'pluviometrica', ST_PointFromText('POINT(-77.28333333 7.433333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Riosucio'), FALSE);  -- Suspendida

-- ---------- BOJAYÁ ----------
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
('0011085010', 'LOMA LA',           'mixta',         ST_PointFromText('POINT(-76.98333333 6.533333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bojayá'), FALSE),  -- Agrometeorológica, Suspendida
('0011077010', 'BELLAVISTA',        'hidrometrica',  ST_PointFromText('POINT(-76.88447222 6.558805556)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bojayá'), TRUE),   -- Limnimétrica, Activa
('0011090010', 'OPOGADO',           'pluviometrica', ST_PointFromText('POINT(-76.97272222 6.812527778)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bojayá'), TRUE),   -- Activa
('0011080030', 'LOMA LA-BOJAYA',    'pluviometrica', ST_PointFromText('POINT(-76.983332778 6.533333056)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bojayá'), FALSE),  -- Suspendida
('0011080010', 'BELLAVISTA - AUT',  'mixta',         ST_PointFromText('POINT(-76.881077778 6.553941667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bojayá'), TRUE);   -- Climatológica Ordinaria, Activa
