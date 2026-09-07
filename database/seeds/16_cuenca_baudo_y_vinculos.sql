-- Crea la cuenca del río Baudó (pendiente desde el lote sur, cuando solo
-- teníamos Alto Baudó) ahora que Bajo Baudó y Medio Baudó ya están cargados.
-- Geometría: envolvente convexa de los 3 municipios miembro (misma aproximación
-- documentada en 02_cuencas.sql para Atrato/San Juan — no es el área de drenaje
-- hidrológico real, que sería más extensa e irregular).
INSERT INTO cuencas (nombre, rio_principal, geometria) VALUES
('Cuenca del río Baudó', 'Río Baudó', ST_PolygonFromText('POLYGON((-77.5396002 5.4808137, -77.2946066 4.5631207, -77.2073758 4.4659196, -77.0906915 4.5012113, -76.9346979 4.8206251, -76.8234283 5.0575539, -76.8097059 5.114595, -76.8246818 5.3439653, -76.898006 5.5602859, -77.0721514 5.9666992, -77.1909271 6.0454122, -77.2923796 5.9697411, -77.5384339 5.483551, -77.5396002 5.4808137))', 4326));

INSERT INTO municipio_cuenca (municipio_id, cuenca_id) VALUES
((SELECT id FROM municipios WHERE nombre = 'Alto Baudó'),  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Baudó')),
((SELECT id FROM municipios WHERE nombre = 'Bajo Baudó'),  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Baudó')),
((SELECT id FROM municipios WHERE nombre = 'Medio Baudó'), (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Baudó')),
((SELECT id FROM municipios WHERE nombre = 'Carmen del Darién'), (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato'));

-- Bahía Solano, Nuquí, Juradó, Acandí y Unguía tienen ríos costeros cortos e
-- independientes (Pacífico norte / Darién-Caribe) que no se modelan como cuenca
-- propia en este MVP — quedan sin vínculo en municipio_cuenca, lo cual es
-- correcto (el campo es opcional), no un dato faltante por error.
