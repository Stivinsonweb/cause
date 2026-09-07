import { Component, Input } from '@angular/core';

import { AlertaActiva } from '../../models/cauce.models';
import { RIESGO_COLOR, RIESGO_ETIQUETA } from '../../models/riesgo-visual';

@Component({
  selector: 'app-alertas-activas',
  imports: [],
  templateUrl: './alertas-activas.html',
  styleUrl: './alertas-activas.css',
})
export class AlertasActivas {
  @Input() alertas: AlertaActiva[] | null = null;

  protected readonly color = RIESGO_COLOR;
  protected readonly etiqueta = RIESGO_ETIQUETA;

  protected nombreTipo(tipo: AlertaActiva['tipo_evento']): string {
    return tipo === 'inundacion' ? 'inundación' : tipo === 'deslizamiento' ? 'deslizamiento' : 'sequía';
  }
}
