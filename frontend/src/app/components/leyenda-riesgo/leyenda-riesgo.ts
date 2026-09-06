import { Component } from '@angular/core';

import { NivelRiesgo } from '../../models/cauce.models';
import { RIESGO_COLOR, RIESGO_ETIQUETA } from '../../models/riesgo-visual';

@Component({
  selector: 'app-leyenda-riesgo',
  imports: [],
  templateUrl: './leyenda-riesgo.html',
  styleUrl: './leyenda-riesgo.css',
})
export class LeyendaRiesgo {
  protected readonly niveles: NivelRiesgo[] = ['bajo', 'medio', 'alto', 'critico'];
  protected readonly color = RIESGO_COLOR;
  protected readonly etiqueta = RIESGO_ETIQUETA;
}
