-- Eventos históricos reales de inundación/deslizamiento en los 6 municipios del MVP.
-- Fuentes citadas por evento (columna `fuente`, nombre corto — URL completa al final
-- de `descripcion` por límite de VARCHAR(100)): El Tiempo, OCHA Colombia, El
-- Colombiano, El Espectador, Infobae, Radio Nacional, Vanguardia, Minuto30/RCN.
-- Nota de transparencia: solo se encontró 1 deslizamiento verificable con fuente
-- específica para estos 6 municipios (Quibdó, 2022) — el resto son inundaciones del
-- Atrato/San Juan, mucho mejor documentadas en prensa que los deslizamientos.

-- QUIBDÓ
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'inundacion', '1996-08-06', 'alto', 'El Tiempo', 'Desbordamiento del río Atrato dejó 3.500 familias damnificadas en Quibdó, Lloró, Bojayá y Riosucio; 16 barrios de Quibdó inundados, la peor creciente desde diciembre de 1991. Fuente: https://www.eltiempo.com/archivo/documento/MAM-461890'),
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'inundacion', '2015-02-03', 'alto', 'OCHA Colombia', 'Inundaciones y remoción en masa por desbordamiento del Atrato y el Baudó afectaron 11.224 personas en Quibdó, Bojayá y Alto Baudó; viviendas destruidas y un menor herido. Fuente: https://www.unocha.org/publications/report/colombia/colombia-emergencia-por-inundaciones-en-quibd-bojay-y-alto-baud-choc-flash-update-no'),
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'deslizamiento', '2022-12-11', 'critico', 'Minuto30 / RCN', 'Alud de tierra por fuertes lluvias sepultó una vivienda en el barrio Flores de Buenaños, sector La Lucha, matando a 4 miembros de una familia; 2 niños sobrevivieron. Fuente: https://www.minuto30.com/familia-murio-deslizamiento-casa-quibdo/1387886/'),
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'inundacion', '2025-05-13', 'medio', 'Radio Nacional', 'El río Atrato superó niveles históricos en el asentamiento Ichó (Quibdó) en medio de una emergencia regional por lluvias que también causó un deslizamiento fatal en la vía a Medellín. Fuente: https://www.radionacional.co/noticias-colombia/choco-dos-muertes-derrumbes-y-lluvias'),
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'inundacion', '2025-10-28', 'alto', 'Infobae', 'Desbordamiento del Atrato tras tres días de lluvia inundó los barrios Playita, Niño Jesús, San Vicente y San Martín; más de 1.200 familias desplazadas en la región. Fuente: https://www.infobae.com/colombia/2025/10/28/emergencia-por-lluvias-en-choco-mas-de-1200-familias-damnificadas-y-15-municipios-afectados/');

-- ISTMINA
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Istmina'), 'inundacion', '2019-02-24', 'alto', 'Vanguardia', 'Desbordamiento de los ríos San Juan, Iró, Condoto, Cértegui y Quito; Istmina fue la más golpeada en el sector comercial, incluido el colapso de una vivienda, dentro de ~4.000 familias afectadas en la región. Fuente: https://www.vanguardia.com/colombia/2019/02/25/choco-bajo-el-agua-van-4-mil-damnificados-por-inundacion/'),
((SELECT id FROM municipios WHERE nombre = 'Istmina'), 'inundacion', '2024-10-28', 'critico', 'El Tiempo', 'Creciente del río San Juan afectó cerca de 1.000 familias ribereñas en Istmina, dentro de 15.000 personas afectadas en la región; murió ahogado un hombre indígena. Fuente: https://www.eltiempo.com/colombia/otras-ciudades/alerta-humanitaria-en-choco-15-000-personas-estan-damnificadas-por-la-creciente-del-rio-san-juan-3397785');

-- CONDOTO
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Condoto'), 'inundacion', '2019-02-24', 'alto', 'Vanguardia', 'Desbordamiento del río San Juan y afluentes inundó los barrios Comercio, Cabecera, Héroes, Salto Bolívar, Claret, Cascajero y San Pedro en Condoto, con miles de personas afectadas en la subregión. Fuente: https://www.vanguardia.com/colombia/2019/02/25/choco-bajo-el-agua-van-4-mil-damnificados-por-inundacion/');

-- TADÓ
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Tadó'), 'inundacion', '2019-02-24', 'medio', 'Vanguardia', 'Tadó fue uno de los municipios afectados por el desbordamiento de los ríos San Juan, Iró, Condoto y Cértegui durante la emergencia regional de febrero de 2019. Fuente: https://www.vanguardia.com/colombia/2019/02/25/choco-bajo-el-agua-van-4-mil-damnificados-por-inundacion/');

-- RIOSUCIO
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Riosucio'), 'inundacion', '1996-02-21', 'critico', 'El Tiempo', 'Desbordamiento del río Atrato afectó Montaño, La Grande, Turriquitadó, Vigía de Curvaradó, Domingodó, La Honda y Puente América; 20.000 damnificados según la alcaldía (hasta 36.000 según la Cruz Roja). Fuente: https://www.eltiempo.com/archivo/documento/MAM-274050'),
((SELECT id FROM municipios WHERE nombre = 'Riosucio'), 'inundacion', '2010-11-25', 'critico', 'El Colombiano', 'El Atrato subió 3 metros durante 30 días; más del 60% de las 1.200 viviendas fue evacuado, el hospital y la alcaldía se trasladaron a segundos pisos, y murieron ahogados 2 niños. Fuente: https://www.elcolombiano.com/historico/el_atrato_se_traga_a_riosucio-HDEC_113242'),
((SELECT id FROM municipios WHERE nombre = 'Riosucio'), 'inundacion', '2020-12-05', 'medio', 'El Espectador', 'Tras un incendio previo (28-nov-2020) que dejó 2 muertos, la creciente del Atrato destruyó 14 viviendas y amenazó 120 más, con pérdida de 5 calles por erosión. Fuente: https://www.elespectador.com/colombia/mas-regiones/riosucio-choco-primero-el-incendio-y-ahora-inundaciones-por-creciente-de-rio-atrato-article/');

-- BOJAYÁ
INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Bojayá'), 'inundacion', '1996-08-06', 'alto', 'El Tiempo', 'Desbordamiento del río Atrato afectó a Bojayá junto con Quibdó, Lloró y Riosucio; 3.500 familias damnificadas en la cuenca. Fuente: https://www.eltiempo.com/archivo/documento/MAM-461890'),
((SELECT id FROM municipios WHERE nombre = 'Bojayá'), 'inundacion', '2000-05-10', 'alto', 'El Tiempo', 'El río Atrato superó niveles críticos afectando a Bojayá, Atrato, Medio Atrato y Riosucio (además de Vigía del Fuerte y Murindó en Antioquia); 2.500 desplazados atendidos y ~7.000 familias más pendientes de censo. Fuente: https://www.eltiempo.com/archivo/documento/MAM-1272367'),
((SELECT id FROM municipios WHERE nombre = 'Bojayá'), 'inundacion', '2015-02-03', 'alto', 'OCHA Colombia', 'Inundaciones y remoción en masa afectaron a Bojayá dentro de la emergencia regional de 11.224 personas; las comunidades de Pogue (afro) y Lana (indígena) solicitaron reubicación por alto riesgo. Fuente: https://www.unocha.org/publications/report/colombia/colombia-emergencia-por-inundaciones-en-quibd-bojay-y-alto-baud-choc-flash-update-no');
