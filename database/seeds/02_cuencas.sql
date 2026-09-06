-- Cuencas hidrográficas de los 6 municipios del MVP: río Atrato (Quibdó, Riosucio,
-- Bojayá) y río San Juan (Istmina, Condoto, Tadó).
--
-- LIMITACIÓN CONOCIDA: no se encontró una fuente pública fácilmente consumible con
-- el polígono oficial de subzona hidrográfica IDEAM/CAR. Como aproximación honesta
-- para el MVP, la geometría de cada cuenca es la ENVOLVENTE CONVEXA de los polígonos
-- de sus municipios miembro (calculada localmente con el algoritmo de Andrew,
-- monotone chain, sobre los vértices reales de 01_municipios.sql) — es decir, un
-- polígono simple que contiene a los 3 municipios de esa cuenca, no el área de
-- drenaje hidrológico real (que es más extensa e irregular). Reemplazar por datos
-- oficiales de IDEAM (subzonas hidrográficas) cuando estén disponibles.

INSERT INTO cuencas (nombre, rio_principal, geometria) VALUES
('Cuenca del río Atrato', 'Río Atrato', ST_PolygonFromText('POLYGON((-77.7486621 7.6156163, -77.7152917 7.4438161, -77.6824231 7.2783561, -77.5292752 6.8013523, -77.2858861 6.0835246, -76.9047285 5.6751349, -76.5773307 5.6535836, -76.4663142 5.6911451, -76.3833557 5.7306859, -76.1739266 5.9699911, -76.2011712 6.1384065, -77.0948716 7.9177725, -77.1483583 7.9434814, -77.2623172 7.9168115, -77.3051391 7.9002304, -77.7486621 7.6156163))', 4326)),
('Cuenca del río San Juan', 'Río San Juan', ST_PolygonFromText('POLYGON((-77.1610903 4.5230191, -77.053485 4.4500352, -77.0113677 4.4396529, -76.6770705 4.3937618, -76.1741822 5.1726042, -76.1974547 5.4109805, -76.4606696 5.346784, -76.7424907 5.268456, -76.8495049 5.2338883, -77.1610903 4.5230191))', 4326));
