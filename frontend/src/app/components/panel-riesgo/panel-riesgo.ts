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

  protected nombreTipo(tipo: RiesgoTipo['tipo_evento']): string {
    return tipo === 'inundacion' ? 'Inundación' : 'Deslizamiento';
  }

  protected esProxy(riesgoTipo: RiesgoTipo): boolean {
    return riesgoTipo.tipo_evento === 'deslizamiento' && !!riesgoTipo.version_modelo?.endsWith('-pd');
  }
}
