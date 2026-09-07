import { Component, Input } from '@angular/core';
import { LucideArrowRight } from '@lucide/angular';

import { AlertasActivas } from '../alertas-activas/alertas-activas';
import { AlertaActiva } from '../../models/cauce.models';

@Component({
  selector: 'app-hero',
  imports: [AlertasActivas, LucideArrowRight],
  templateUrl: './hero.html',
  styleUrl: './hero.css',
})
export class Hero {
  @Input() alertas: AlertaActiva[] | null = null;
}
