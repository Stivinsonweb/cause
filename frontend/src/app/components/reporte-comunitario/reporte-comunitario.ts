import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Component, Input, OnChanges, SimpleChanges, inject, signal } from '@angular/core';

import { ReporteComunitario as ReporteComunitarioDatos, TipoEvento } from '../../models/cauce.models';
import { CauceApiService } from '../../services/cauce-api.service';

@Component({
  selector: 'app-reporte-comunitario',
  imports: [FormsModule, DatePipe],
  templateUrl: './reporte-comunitario.html',
  styleUrl: './reporte-comunitario.css',
})
export class ReporteComunitario implements OnChanges {
  @Input() municipioId: number | null = null;
  @Input() municipioNombre: string | null = null;

  private readonly api = inject(CauceApiService);

  protected readonly reportesVerificados = signal<ReporteComunitarioDatos[]>([]);
  protected readonly mostrarFormulario = signal(false);
  protected readonly enviando = signal(false);
  protected readonly enviado = signal(false);
  protected readonly error = signal<string | null>(null);

  protected tipoEvento: TipoEvento = 'inundacion';
  protected descripcion = '';
  protected zonaAproximada = '';

  ngOnChanges(cambios: SimpleChanges): void {
    if (cambios['municipioId']) {
      this.mostrarFormulario.set(false);
      this.enviado.set(false);
      this.reportesVerificados.set([]);
      if (this.municipioId !== null) {
        this.api.reportesVerificados(this.municipioId).subscribe((reportes) => this.reportesVerificados.set(reportes));
      }
    }
  }

  protected nombreTipo(tipo: TipoEvento): string {
    return tipo === 'inundacion' ? 'Inundación' : tipo === 'deslizamiento' ? 'Deslizamiento' : 'Sequía';
  }

  protected enviar(): void {
    if (this.municipioId === null) return;
    this.enviando.set(true);
    this.error.set(null);
    this.api
      .crearReporte({
        municipio_id: this.municipioId,
        tipo_evento: this.tipoEvento,
        descripcion: this.descripcion || undefined,
        zona_aproximada: this.zonaAproximada || undefined,
      })
      .subscribe({
        next: () => {
          this.enviando.set(false);
          this.enviado.set(true);
          this.mostrarFormulario.set(false);
          this.descripcion = '';
          this.zonaAproximada = '';
        },
        error: () => {
          this.enviando.set(false);
          this.error.set('No se pudo enviar el reporte. Intenta de nuevo en un momento.');
        },
      });
  }
}
