-- Evento real de sequía (Fase 6). Búsqueda exhaustiva en DesInventar, UNGRD,
-- prensa colombiana e IDEAM: este es el ÚNICO evento de sequía verificable con
-- fuente citable en los 6 municipios del MVP. El Chocó es una de las regiones
-- más lluviosas del planeta, así que la ausencia de más eventos es consistente
-- con el clima de la zona, no un vacío de búsqueda.

INSERT INTO eventos_historicos (municipio_id, tipo_evento, fecha, severidad, fuente, descripcion) VALUES
((SELECT id FROM municipios WHERE nombre = 'Quibdó'), 'sequia', '2007-02-14', 'medio', 'El Tiempo', 'Ausencia de lluvia significativa durante 13-17 días (inusual en Quibdó) bajó los ríos Cabí y Atrato a mínimos históricos, agravando el déficit del acueducto (26% de cobertura formal). ~2.000 personas protestaron; ~100.000 habitantes afectados; 13 días sin servicio de agua; carrotanques cobrando tarifas infladas. Fuentes: https://www.eltiempo.com/archivo/documento/CMS-3439245 y https://www.eltiempo.com/archivo/documento/MAM-2388075');
