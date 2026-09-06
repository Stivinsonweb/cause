import { DecimalPipe } from '@angular/common';
import { Component, Input } from '@angular/core';

import { Estadisticas as EstadisticasDatos } from '../../models/cauce.models';

@Component({
  selector: 'app-estadisticas',
  imports: [DecimalPipe],
  templateUrl: './estadisticas.html',
  styleUrl: './estadisticas.css',
})
export class Estadisticas {
  @Input() datos: EstadisticasDatos | null = null;
}
