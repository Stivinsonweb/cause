"""Calcula el riesgo actual de un municipio y lo persiste en `predicciones_riesgo`.

Inundación: usa el modelo entrenado en app/ml/train.py (ver ese módulo para las
limitaciones conocidas — n=42 eventos reales tras la ampliación a los 30
municipios del Chocó, mejor que el "primer modelo" con n=14, pero sigue siendo
un prototipo de pipeline validado con LOOCV, no un clasificador de producción).

Deslizamiento: 5 eventos reales verificados en todo el departamento (Bahía
Solano 2017, Quibdó 2022, El Carmen de Atrato 2024, San José del Palmar 2026,
Bajo Baudó 2026) — sigue siendo poco para entrenar un modelo propio, y además
3 de los 5 fueron detonados por sismos, no por lluvia, así que mezclarlos con
el input de lluvia acumulada sería metodológicamente peor que la alternativa
actual. Como el diseño del proyecto asume que ambos fenómenos comparten las
mismas variables de entrada, se usa el modelo de inundación como aproximación
(proxy), dejándolo explícito en `version_modelo` para que nadie lo confunda con
un modelo real de deslizamiento.

Sequía: solo 1 evento real (Quibdó, 2007) en los 30 municipios. No se reutiliza
el modelo de inundación aquí porque la señal es la opuesta (poca lluvia, no
mucha) — se usa una heurística de umbral simple sobre lluvia_acum_15d, ver
app/ml/heuristica_sequia.py para la calibración contra ese único evento real.
Requiere al menos COBERTURA_MINIMA_DIAS de los últimos 15 días con mediciones
reales — con menos, la "suma de 15 días" en realidad solo refleja los pocos
días que la ingestión alcanzó a capturar (ej. recién desplegado el sistema),
y como el Chocó nunca tiene 15 días reales de lluvia casi nula, eso disparaba
"sequía crítica" en casi todos los municipios apenas por falta de historial,
no por sequía real. Se descubrió viendo el propio sitio en producción.

Municipios sin ninguna estación IDEAM activa (por ahora: Alto Baudó, Bagadó,
Bajo Baudó, Juradó, Medio Baudó, Sipí) no reciben predicción — un input de puro
0mm nunca está representado en el entrenamiento real (en el Chocó nunca llueve
0mm en 90 días) y el modelo extrapolaría sin ningún fundamento. Mejor "sin
datos" honesto que un nivel de riesgo inventado.
"""

import json
from datetime import datetime, timezone
from pathlib import Path

import joblib
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.ml.features import acumulados_actuales_municipio
from app.ml.heuristica_sequia import VERSION_HEURISTICA, nivel_riesgo_sequia
from app.ml.train import FEATURES, MODEL_PATH, META_PATH, ORDINAL_SEVERIDAD
from app.models.orm import PrediccionRiesgo

_modelo = None
_meta = None

COBERTURA_MINIMA_DIAS = 8  # de 15 — por debajo de esto, la heurística de sequía no es confiable


def _cargar_modelo():
    global _modelo, _meta
    if _modelo is None:
        if not MODEL_PATH.exists():
            raise RuntimeError("Modelo no entrenado todavía. Ejecuta: python -m app.ml.train")
        _modelo = joblib.load(MODEL_PATH)
        _meta = json.loads(META_PATH.read_text())
    return _modelo, _meta


def calcular_riesgo_municipio(db: Session, municipio_id: int) -> list[PrediccionRiesgo]:
    modelo, meta = _cargar_modelo()
    variables = acumulados_actuales_municipio(db, municipio_id)

    if variables["lluvia_acum_90d"] == 0:
        # Sin ninguna medición real en 90 días (municipio sin estaciones activas
        # que la ingestión pueda alimentar) — un input de puro cero nunca está
        # bien representado en el entrenamiento (en el Chocó nunca llueve
        # exactamente 0mm en 90 días) y el modelo puede extrapolar mal. Mejor
        # dejarlo explícitamente sin predicción que inventar un nivel de riesgo
        # sobre datos inexistentes; la API ya maneja la ausencia como "sin datos".
        return []

    X = [[variables[c] for c in FEATURES]]

    clase_predicha = modelo.predict(X)[0]
    probabilidades = modelo.predict_proba(X)[0]
    nivel_riesgo_inundacion = ORDINAL_SEVERIDAD[clase_predicha]
    probabilidad_inundacion = float(max(probabilidades))

    predicciones_a_crear = [
        ("inundacion", nivel_riesgo_inundacion, probabilidad_inundacion, meta["version_modelo"]),
        ("deslizamiento", nivel_riesgo_inundacion, probabilidad_inundacion, meta["version_modelo"] + "-pd"),
    ]
    if variables["dias_con_datos_15d"] >= COBERTURA_MINIMA_DIAS:
        nivel_sequia, probabilidad_sequia = nivel_riesgo_sequia(variables["lluvia_acum_15d"])
        predicciones_a_crear.append(("sequia", nivel_sequia, probabilidad_sequia, VERSION_HEURISTICA))
    # si no hay cobertura mínima, sequía queda sin predicción ("sin datos aún")

    ahora = datetime.now(timezone.utc)
    resultados = []
    for tipo_evento, nivel, probabilidad, version in predicciones_a_crear:
        prediccion = PrediccionRiesgo(
            municipio_id=municipio_id,
            tipo_evento=tipo_evento,
            fecha_calculo=ahora,
            nivel_riesgo=nivel,
            probabilidad=round(probabilidad, 4),
            variables_entrada=variables,
            version_modelo=version,
        )
        db.add(prediccion)
        resultados.append(prediccion)
    return resultados


def calcular_riesgo_todos_los_municipios(db: Session) -> int:
    ids = [fila[0] for fila in db.execute(text("SELECT id FROM municipios")).all()]
    total = 0
    for municipio_id in ids:
        calcular_riesgo_municipio(db, municipio_id)
        total += 1
    db.commit()
    return total
