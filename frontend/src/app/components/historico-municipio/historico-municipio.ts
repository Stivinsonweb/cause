import { DatePipe } from '@angular/common';
import { Component, Input } from '@angular/core';

import { HistoricoMunicipio as HistoricoMunicipioDatos, Municipio } from '../../models/cauce.models';
import { RIESGO_COLOR } from '../../models/riesgo-visual';

@Component({
  selector: 'app-historico-municipio',
  imports: [DatePipe],
  templateUrl: './historico-municipio.html',
  styleUrl: './historico-municipio.css',
})
export class HistoricoMunicipio {
  @Input() municipio: Municipio | null = null;
  @Input() historico: HistoricoMunicipioDatos | null = null;
  @Input() cargando = false;

  protected readonly color = RIESGO_COLOR;
}
