export type NivelRiesgo = 'bajo' | 'medio' | 'alto' | 'critico';
export type TipoEvento = 'inundacion' | 'deslizamiento';

export interface GeoJsonPolygon {
  type: 'Polygon';
  coordinates: number[][][]; // [ [ [lon, lat], ... ] ]
}

export interface Municipio {
  id: number;
  nombre: string;
  departamento: string;
  poblacion_estimada: number | null;
  geometria: GeoJsonPolygon | null;
}

export interface RiesgoTipo {
  tipo_evento: TipoEvento;
  nivel_riesgo: NivelRiesgo | null;
  probabilidad: number | null;
  fecha_calculo: string | null;
  variables_entrada: Record<string, number> | null;
  version_modelo: string | null;
}

export interface RiesgoMunicipio {
  municipio_id: number;
  riesgos: RiesgoTipo[];
}

export interface EventoHistorico {
  id: number;
  tipo_evento: TipoEvento;
  fecha: string;
  severidad: NivelRiesgo;
  fuente: string;
  descripcion: string | null;
}

export interface MedicionDiaria {
  fecha: string;
  lluvia_mm_promedio: number | null;
  nivel_rio_m_promedio: number | null;
}

export interface HistoricoMunicipio {
  municipio_id: number;
  eventos: EventoHistorico[];
  mediciones_diarias: MedicionDiaria[];
}

export interface AlertaActiva {
  municipio_id: number;
  municipio_nombre: string;
  tipo_evento: TipoEvento;
  nivel_riesgo: NivelRiesgo;
  fecha_calculo: string;
}
