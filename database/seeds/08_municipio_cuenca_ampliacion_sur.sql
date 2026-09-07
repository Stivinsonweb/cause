-- Alto Baudó pertenece a la cuenca del río Baudó (pendiente de crear hasta
-- tener Bajo Baudó y Medio Baudó del siguiente lote) — no se vincula aquí.
INSERT INTO municipio_cuenca (municipio_id, cuenca_id) VALUES
((SELECT id FROM municipios WHERE nombre = 'Medio San Juan'),        (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Nóvita'),                (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Sipí'),                  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Río Iró'),               (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'San José del Palmar'),   (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Cantón de San Pablo'),   (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'El Litoral del San Juan'), (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan'));
