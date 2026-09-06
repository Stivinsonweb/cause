INSERT INTO municipio_cuenca (municipio_id, cuenca_id) VALUES
((SELECT id FROM municipios WHERE nombre = 'Quibdó'),   (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Riosucio'), (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Bojayá'),   (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río Atrato')),
((SELECT id FROM municipios WHERE nombre = 'Istmina'),  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Condoto'),  (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan')),
((SELECT id FROM municipios WHERE nombre = 'Tadó'),     (SELECT id FROM cuencas WHERE nombre = 'Cuenca del río San Juan'));
