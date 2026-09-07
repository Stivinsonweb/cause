import { DecimalPipe } from '@angular/common';
import { Component, Input } from '@angular/core';
import { LucideMapPinned, LucideUsers, LucideRadioTower, LucideHistory } from '@lucide/angular';

import { Estadisticas as EstadisticasDatos } from '../../models/cauce.models';

@Component({
  selector: 'app-estadisticas',
  imports: [DecimalPipe, LucideMapPinned, LucideUsers, LucideRadioTower, LucideHistory],
  templateUrl: './estadisticas.html',
  styleUrl: './estadisticas.css',
})
export class Estadisticas {
  @Input() datos: EstadisticasDatos | null = null;
}
