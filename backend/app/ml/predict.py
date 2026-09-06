"""Calcula el riesgo actual de un municipio y lo persiste en `predicciones_riesgo`.

Inundación: usa el modelo entrenado en app/ml/train.py (ver ese módulo para las
limitaciones conocidas del "primer modelo" — backtesting con n=14 no supera un
baseline trivial, así que esto es un prototipo de pipeline, no un clasificador
confiable todavía).

Deslizamiento: solo hay 1 evento real verificado en los 6 municipios (Quibdó,
2022), insuficiente para entrenar nada. Como el propio diseño del proyecto asume
que ambos fenómenos comparten las mismas variables de entrada (lluvia acumulada),
usamos el modelo de inundación como aproximación (proxy) también para
deslizamiento, dejándolo explícito en `version_modelo` para que nadie lo confunda
con un modelo real de deslizamiento.
"""

import json
from datetime import datetime, timezone
from pathlib import Path

import joblib
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.ml.features import acumulados_actuales_municipio
from app.ml.train import FEATURES, MODEL_PATH, META_PATH, ORDINAL_SEVERIDAD
from app.models.orm import PrediccionRiesgo

_modelo = None
_meta = None


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
    X = [[variables[c] for c in FEATURES]]

    clase_predicha = modelo.predict(X)[0]
    probabilidades = modelo.predict_proba(X)[0]
    nivel_riesgo = ORDINAL_SEVERIDAD[clase_predicha]
    probabilidad = float(max(probabilidades))

    ahora = datetime.now(timezone.utc)
    resultados = []
    for tipo_evento, version in (
        ("inundacion", meta["version_modelo"]),
        ("deslizamiento", meta["version_modelo"] + "-pd"),  # pd = proxy deslizamiento; ver docstring del módulo
    ):
        prediccion = PrediccionRiesgo(
            municipio_id=municipio_id,
            tipo_evento=tipo_evento,
            fecha_calculo=ahora,
            nivel_riesgo=nivel_riesgo,
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
