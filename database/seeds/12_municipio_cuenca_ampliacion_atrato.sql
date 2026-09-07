INSERT INTO municipio_cuenca (municipio_id, cuenca_id) VALUES
((SELECT id FROM municipios WHERE nombre = 'Lloró'),               (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'El Carmen de Atrato'), (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Atrato'),              (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Medio Atrato'),        (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Bagadó'),              (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Cértegui'),            (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Río Quito'),           (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Unión Panamericana'),  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato'));
