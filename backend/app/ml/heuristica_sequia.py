"""Heurística de riesgo de sequía — NO es un modelo entrenado.

Solo existe 1 evento real de sequía documentado en los 30 municipios del Chocó
(Quibdó, feb-2007, ver database/seeds/06_eventos_historicos_sequia.sql) — muy
poco para entrenar nada. Con ese único dato real disponible, se usa como
referencia de calibración en vez de un umbral inventado.

Dato real de ese evento (lluvia acumulada real, NASA POWER, hasta la fecha del
evento): 7d=1.66mm, 15d=3.92mm, 30d=41.62mm, 90d=379.97mm. El acumulado de 90
días estaba en rango NORMAL para la región — lo que realmente distinguió el
evento fue un corte agudo de lluvia de ~2 semanas (7d y 15d casi en cero), no
un déficit sostenido de varios meses. Por eso esta heurística mira lluvia_acum_15d,
no lluvia_acum_90d como cabría esperar para "sequía" en otros climas.

Esto es deliberadamente un umbral simple, no un clasificador — con n=1 no hay
manera honesta de hacer más que esto. Reemplazar en cuanto haya más eventos
reales de sequía documentados (o datos de DesInventar a nivel municipal que no
se pudieron consultar programáticamente, ver notas de la Fase 6).
"""

VERSION_HEURISTICA = "heur-sequia-v1"


def nivel_riesgo_sequia(lluvia_acum_15d: float) -> tuple[str, float]:
    """Devuelve (nivel_riesgo, "probabilidad" heurística — no es de un modelo
    probabilístico real, solo qué tan lejos está del umbral, para dar una
    referencia visual de intensidad)."""
    if lluvia_acum_15d < 5:
        return "critico", 0.6
    if lluvia_acum_15d < 15:
        return "alto", 0.55
    if lluvia_acum_15d < 40:
        return "medio", 0.5
    return "bajo", 0.6
