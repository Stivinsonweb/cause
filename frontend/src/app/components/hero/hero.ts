import { Component, Input } from '@angular/core';

import { AlertasActivas } from '../alertas-activas/alertas-activas';
import { AlertaActiva } from '../../models/cauce.models';

@Component({
  selector: 'app-hero',
  imports: [AlertasActivas],
  templateUrl: './hero.html',
  styleUrl: './hero.css',
})
export class Hero {
  @Input() alertas: AlertaActiva[] | null = null;
}
