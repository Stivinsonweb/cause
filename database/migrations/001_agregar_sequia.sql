-- Fase 6: agrega 'sequia' como tercer tipo_evento válido.
-- Ya aplicada manualmente en Supabase (producción) y en el Postgres local de
-- desarrollo el 2026-09-06. Este archivo documenta el cambio para cualquier
-- otra instancia (staging, otro entorno de desarrollo, etc.).

ALTER TABLE eventos_historicos DROP CONSTRAINT eventos_historicos_tipo_evento_check;
ALTER TABLE eventos_historicos ADD CONSTRAINT eventos_historicos_tipo_evento_check
  CHECK (tipo_evento IN ('inundacion', 'deslizamiento', 'sequia'));

ALTER TABLE predicciones_riesgo DROP CONSTRAINT predicciones_riesgo_tipo_evento_check;
ALTER TABLE predicciones_riesgo ADD CONSTRAINT predicciones_riesgo_tipo_evento_check
  CHECK (tipo_evento IN ('inundacion', 'deslizamiento', 'sequia'));
