import { Component, Input, computed, signal } from '@angular/core';

import { AlertaActiva } from '../../models/cauce.models';
import { RIESGO_COLOR, RIESGO_ETIQUETA } from '../../models/riesgo-visual';

const ORDEN_SEVERIDAD = { critico: 0, alto: 1, medio: 2, bajo: 3 } as const;
const MAXIMO_VISIBLE = 3;

@Component({
  selector: 'app-alertas-activas',
  imports: [],
  templateUrl: './alertas-activas.html',
  styleUrl: './alertas-activas.css',
})
export class AlertasActivas {
  private readonly _alertas = signal<AlertaActiva[] | null>(null);

  @Input()
  set alertas(valor: AlertaActiva[] | null) {
    this._alertas.set(valor);
  }
  get alertas(): AlertaActiva[] | null {
    return this._alertas();
  }

  protected readonly color = RIESGO_COLOR;
  protected readonly etiqueta = RIESGO_ETIQUETA;

  protected readonly ordenadas = computed(
    () => [...(this._alertas() ?? [])].sort((a, b) => ORDEN_SEVERIDAD[a.nivel_riesgo] - ORDEN_SEVERIDAD[b.nivel_riesgo]),
  );

  protected readonly visibles = computed(() => this.ordenadas().slice(0, MAXIMO_VISIBLE));
  protected readonly restantes = computed(() => Math.max(0, this.ordenadas().length - MAXIMO_VISIBLE));

  protected nombreTipo(tipo: AlertaActiva['tipo_evento']): string {
    return tipo === 'inundacion' ? 'inundación' : tipo === 'deslizamiento' ? 'deslizamiento' : 'sequía';
  }
}
