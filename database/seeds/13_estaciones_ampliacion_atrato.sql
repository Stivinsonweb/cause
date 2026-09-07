-- Fuente: Catálogo Nacional de Estaciones del IDEAM (datos.gov.co, dataset hp9r-jxuu).
INSERT INTO estaciones (codigo_ideam, nombre, tipo, ubicacion, municipio_id, activa) VALUES
-- Lloró
('1117500060', 'LLORO', 'mixta', ST_PointFromText('POINT(-76.58 5.51)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), FALSE),
('0011017010', 'AGUASAL', 'hidrometrica', ST_PointFromText('POINT(-76.537861111 5.473943889)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), TRUE),
('0011035010', 'LLORO', 'mixta', ST_PointFromText('POINT(-76.539 5.499)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), TRUE),
('0011027070', 'BORAUDO', 'hidrometrica', ST_PointFromText('POINT(-76.57569444 5.514611111)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), FALSE),
('0011027050', 'GINDRAMA', 'hidrometrica', ST_PointFromText('POINT(-76.51772222 5.521555556)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), FALSE),
('0011010020', 'GRANJA AGRICOLA LLORO', 'pluviometrica', ST_PointFromText('POINT(-76.53333333 5.5)', 4326), (SELECT id FROM municipios WHERE nombre = 'Lloró'), FALSE),
-- El Carmen de Atrato
('0011027010', 'PUENTE LAS SANCHEZ', 'hidrometrica', ST_PointFromText('POINT(-76.18080556 5.851972222)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011020020', 'GUADUAS', 'pluviometrica', ST_PointFromText('POINT(-76.18333333 5.766666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0026190130', 'MANSA LA', 'pluviometrica', ST_PointFromText('POINT(-76.1 5.75)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011020060', 'CARMEN EL', 'pluviometrica', ST_PointFromText('POINT(-76.66666667 5.833333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011027020', 'OCHO EL', 'hidrometrica', ST_PointFromText('POINT(-76.25 5.85)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011025501', 'CARMEN DE ATRATO - AUT', 'mixta', ST_PointFromText('POINT(-76.14516667 5.888719444)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), TRUE),
('0011020010', 'CARMEN DE ATRATO', 'pluviometrica', ST_PointFromText('POINT(-76.14208333 5.908527778)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), TRUE),
('0011027060', 'PINON EL', 'hidrometrica', ST_PointFromText('POINT(-76.36666667 5.733333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011020050', 'EL PINON', 'pluviometrica', ST_PointFromText('POINT(-76.25086111 5.757666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), TRUE),
('0011027040', 'ARRAYANES LOS', 'hidrometrica', ST_PointFromText('POINT(-76.3 5.8)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), FALSE),
('0011027030', 'EL SIETE - AUT', 'hidrometrica', ST_PointFromText('POINT(-76.152063889 5.862022222)', 4326), (SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), TRUE),
-- Atrato (Yuto)
('0011175000', 'ATRATO - AUT', 'mixta', ST_PointFromText('POINT(-76.64351 5.58835)', 4326), (SELECT id FROM municipios WHERE nombre = 'Atrato'), TRUE),
-- Medio Atrato (Beté)
('0011050020', 'BETE', 'pluviometrica', ST_PointFromText('POINT(-76.78002778 5.994722222)', 4326), (SELECT id FROM municipios WHERE nombre = 'Medio Atrato'), TRUE),
('0011050030', 'EL BUEY', 'pluviometrica', ST_PointFromText('POINT(-76.82136111 6.1025)', 4326), (SELECT id FROM municipios WHERE nombre = 'Medio Atrato'), TRUE),
('0011050060', 'ALTO DEL BUEY', 'pluviometrica', ST_PointFromText('POINT(-76.91563889 6.108333333)', 4326), (SELECT id FROM municipios WHERE nombre = 'Medio Atrato'), TRUE),
-- Bagadó
('0011017020', 'BAGADO - AUT', 'hidrometrica', ST_PointFromText('POINT(-76.417925 5.412225)', 4326), (SELECT id FROM municipios WHERE nombre = 'Bagadó'), FALSE),
-- Cértegui
('0011010010', 'LA VUELTA', 'pluviometrica', ST_PointFromText('POINT(-76.544722222 5.458944444)', 4326), (SELECT id FROM municipios WHERE nombre = 'Cértegui'), TRUE),
('0011030010', 'CERTEGUI', 'pluviometrica', ST_PointFromText('POINT(-76.61 5.38)', 4326), (SELECT id FROM municipios WHERE nombre = 'Cértegui'), TRUE),
('0011037020', 'PUENTE CERTEGUI', 'hidrometrica', ST_PointFromText('POINT(-76.61325 5.37475)', 4326), (SELECT id FROM municipios WHERE nombre = 'Cértegui'), TRUE),
-- Río Quito (Paimadó)
('0011030040', 'PAIMADO', 'pluviometrica', ST_PointFromText('POINT(-76.74086111 5.481611111)', 4326), (SELECT id FROM municipios WHERE nombre = 'Río Quito'), TRUE),
('0011037010', 'SAN ISIDRO', 'hidrometrica', ST_PointFromText('POINT(-76.749721944 5.62625)', 4326), (SELECT id FROM municipios WHERE nombre = 'Río Quito'), FALSE),
('0011037030', 'LA LOMA PUEBLO', 'hidrometrica', ST_PointFromText('POINT(-76.75327778 5.584666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Río Quito'), FALSE),
('0011035020', 'SAN ISIDRO', 'pluviometrica', ST_PointFromText('POINT(-76.74972222 5.626166667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Río Quito'), TRUE),
('0011030070', 'LOMA LA PUEBLO NUEVO', 'pluviometrica', ST_PointFromText('POINT(-76.753277778 5.584666667)', 4326), (SELECT id FROM municipios WHERE nombre = 'Río Quito'), FALSE),
-- Unión Panamericana (Ánimas)
('0011035030', 'UNION PANAMERICANA - AUT', 'mixta', ST_PointFromText('POINT(-76.627822222 5.284827778)', 4326), (SELECT id FROM municipios WHERE nombre = 'Unión Panamericana'), TRUE);
