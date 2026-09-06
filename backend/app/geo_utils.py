"""Conversión manual de WKT a GeoJSON.

No usamos ST_AsGeoJSON de MySQL: para SRID 4326 esa función no respeta el orden
[longitud, latitud] que exige RFC 7946 (invierte los ejes según el orden definido
por la autoridad EPSG, que para 4326 es latitud-longitud), mientras que ST_AsText
sí conserva el orden en que se insertó la geometría (longitud, latitud, tal como
la escribimos en los seeds). Por eso parseamos el WKT directamente.
"""

import re


def polygon_wkt_to_geojson(wkt: str) -> dict:
    """Convierte un WKT POLYGON((x y, x y, ...)) de un solo anillo a GeoJSON Polygon."""
    match = re.search(r"POLYGON\s*\(\((.*)\)\)", wkt, re.IGNORECASE)
    if not match:
        raise ValueError(f"WKT de polígono no reconocido: {wkt}")

    anillo = [
        [float(x), float(y)]
        for x, y in (par.strip().split() for par in match.group(1).split(","))
    ]
    return {"type": "Polygon", "coordinates": [anillo]}
