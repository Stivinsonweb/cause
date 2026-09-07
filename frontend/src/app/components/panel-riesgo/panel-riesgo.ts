import { DatePipe, DecimalPipe } from '@angular/common';
import { Component, Input } from '@angular/core';

import { Municipio, RiesgoMunicipio, RiesgoTipo } from '../../models/cauce.models';
import { RIESGO_COLOR, RIESGO_ETIQUETA } from '../../models/riesgo-visual';

@Component({
  selector: 'app-panel-riesgo',
  imports: [DatePipe, DecimalPipe],
  templateUrl: './panel-riesgo.html',
  styleUrl: './panel-riesgo.css',
})
export class PanelRiesgo {
  @Input() municipio: Municipio | null = null;
  @Input() riesgo: RiesgoMunicipio | null = null;
  @Input() cargando = false;

  protected readonly color = RIESGO_COLOR;
  protected readonly etiqueta = RIESGO_ETIQUETA;

  private static readonly NOMBRES_TIPO: Record<RiesgoTipo['tipo_evento'], string> = {
    inundacion: 'Inundación',
    deslizamiento: 'Deslizamiento',
    sequia: 'Sequía',
  };

  protected nombreTipo(tipo: RiesgoTipo['tipo_evento']): string {
    return PanelRiesgo.NOMBRES_TIPO[tipo];
  }

  protected avisoMetodologico(riesgoTipo: RiesgoTipo): string | null {
    if (riesgoTipo.tipo_evento === 'deslizamiento' && riesgoTipo.version_modelo?.endsWith('-pd')) {
      return 'Estimado por aproximación del modelo de inundación — no hay suficientes deslizamientos documentados en este municipio para un modelo propio.';
    }
    if (riesgoTipo.tipo_evento === 'sequia') {
      return 'Estimado con un umbral simple sobre la lluvia acumulada — no es un modelo entrenado. Solo hay 1 evento de sequía documentado en la región, insuficiente para más que eso.';
    }
    return null;
  }
}
