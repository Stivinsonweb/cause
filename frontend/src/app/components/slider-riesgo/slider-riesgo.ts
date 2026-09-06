import { DecimalPipe } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';

import { Municipio, NivelRiesgo, RiesgoTipo } from '../../models/cauce.models';
import { RIESGO_COLOR, RIESGO_ETIQUETA, SIN_DATOS_COLOR } from '../../models/riesgo-visual';

export interface MunicipioConRiesgo {
  municipio: Municipio;
  riesgo: RiesgoTipo | null;
}

@Component({
  selector: 'app-slider-riesgo',
  imports: [DecimalPipe],
  templateUrl: './slider-riesgo.html',
  styleUrl: './slider-riesgo.css',
})
export class SliderRiesgo {
  @Input() items: MunicipioConRiesgo[] = [];
  @Input() seleccionadoId: number | null = null;
  @Output() seleccionar = new EventEmitter<number>();

  private readonly color = RIESGO_COLOR;
  private readonly etiqueta = RIESGO_ETIQUETA;

  protected nivelDe(item: MunicipioConRiesgo): NivelRiesgo | null {
    return item.riesgo?.nivel_riesgo ?? null;
  }

  protected colorDe(item: MunicipioConRiesgo): string {
    const nivel = this.nivelDe(item);
    return nivel ? this.color[nivel] : SIN_DATOS_COLOR;
  }

  protected etiquetaDe(item: MunicipioConRiesgo): string {
    const nivel = this.nivelDe(item);
    return nivel ? this.etiqueta[nivel] : 'Sin datos';
  }
}
