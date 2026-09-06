import { NivelRiesgo } from './cauce.models';

export const RIESGO_COLOR: Record<NivelRiesgo, string> = {
  bajo: '#4A7C4E',
  medio: '#C99A2E',
  alto: '#C4622D',
  critico: '#9B3A2C',
};

export const RIESGO_ETIQUETA: Record<NivelRiesgo, string> = {
  bajo: 'Riesgo bajo',
  medio: 'Riesgo medio',
  alto: 'Riesgo alto',
  critico: 'Riesgo crítico',
};

export const SIN_DATOS_COLOR = '#C8CDBC'; // --line: gris-verdoso neutro, nunca un color de riesgo
