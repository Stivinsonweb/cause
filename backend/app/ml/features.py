"""Features de lluvia acumulada para el modelo de riesgo.

Para entrenamiento usamos precipitación histórica real de la API pública de NASA
POWER (reanálisis satelital, sin necesidad de API key) en el centroide de cada
municipio, porque IDEAM/DHIME no tiene una API pública accesible sin registro y no
tenemos series históricas reales de las estaciones. Para inferencia en vivo usamos
la tabla `mediciones` (alimentada hoy por la ingestión simulada de Fase 2, a la
espera de integrar la API real de IDEAM).
"""

import re
from datetime import date, timedelta

import requests
from sqlalchemy import text
from sqlalchemy.orm import Session

NASA_POWER_URL = "https://power.larc.nasa.gov/api/temporal/daily/point"


def centroide_municipio(db: Session, municipio_id: int) -> tuple[float, float]:
    """Centroide simple (promedio de vértices) del polígono del municipio. Devuelve (lon, lat)."""
    wkt = db.execute(
        text("SELECT ST_AsText(geometria) FROM municipios WHERE id = :id"),
        {"id": municipio_id},
    ).scalar()
    match = re.search(r"POLYGON\s*\(\((.*)\)\)", wkt, re.IGNORECASE)
    puntos = [tuple(map(float, p.strip().split())) for p in match.group(1).split(",")]
    lon = sum(p[0] for p in puntos) / len(puntos)
    lat = sum(p[1] for p in puntos) / len(puntos)
    return lon, lat


def lluvia_historica_nasa_power(lon: float, lat: float, fecha_fin: date, dias: int = 30) -> dict[date, float]:
    """Precipitación diaria (mm) real de NASA POWER para los `dias` que terminan en `fecha_fin`."""
    fecha_inicio = fecha_fin - timedelta(days=dias - 1)
    params = {
        "parameters": "PRECTOTCORR",
        "community": "AG",
        "longitude": lon,
        "latitude": lat,
        "start": fecha_inicio.strftime("%Y%m%d"),
        "end": fecha_fin.strftime("%Y%m%d"),
        "format": "JSON",
    }
    resp = requests.get(NASA_POWER_URL, params=params, timeout=30)
    resp.raise_for_status()
    serie = resp.json()["properties"]["parameter"]["PRECTOTCORR"]
    return {
        date(int(k[:4]), int(k[4:6]), int(k[6:8])): (v if v >= 0 else 0.0)  # -999 = dato faltante
        for k, v in serie.items()
    }


def acumulados_desde_serie(serie: dict[date, float], fecha_ref: date) -> dict[str, float]:
    def suma_ultimos(dias: int) -> float:
        return round(
            sum(v for f, v in serie.items() if fecha_ref - timedelta(days=dias - 1) <= f <= fecha_ref), 2
        )

    return {
        "lluvia_acum_7d": suma_ultimos(7),
        "lluvia_acum_15d": suma_ultimos(15),
        "lluvia_acum_30d": suma_ultimos(30),
    }


def acumulados_actuales_municipio(db: Session, municipio_id: int) -> dict[str, float]:
    """Lluvia acumulada reciente a partir de `mediciones` de las estaciones del municipio."""
    filas = db.execute(
        text(
            """
            SELECT m.fecha_hora::date AS fecha, AVG(m.lluvia_mm) AS lluvia_mm
            FROM mediciones m
            JOIN estaciones e ON e.id = m.estacion_id
            WHERE e.municipio_id = :municipio_id
              AND m.fecha_hora >= NOW() - INTERVAL '30 days'
            GROUP BY m.fecha_hora::date
            """
        ),
        {"municipio_id": municipio_id},
    ).mappings().all()

    serie = {fila["fecha"]: float(fila["lluvia_mm"] or 0) for fila in filas}
    hoy = date.today()
    return acumulados_desde_serie(serie, hoy)
