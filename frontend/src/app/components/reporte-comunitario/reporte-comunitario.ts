import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Component, Input, OnChanges, SimpleChanges, inject, signal } from '@angular/core';
import { LucideEye, LucideImage, LucideX } from '@lucide/angular';

import { ReporteComunitario as ReporteComunitarioDatos, TipoEvento } from '../../models/cauce.models';
import { CauceApiService } from '../../services/cauce-api.service';

@Component({
  selector: 'app-reporte-comunitario',
  imports: [FormsModule, DatePipe, LucideEye, LucideImage, LucideX],
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
  protected foto: File | null = null;
  protected readonly fotoNombre = signal<string | null>(null);
  protected readonly errorFoto = signal<string | null>(null);

  private static readonly TIPOS_PERMITIDOS = ['image/jpeg', 'image/png', 'image/webp'];
  private static readonly TAMANO_MAXIMO = 5 * 1024 * 1024;

  protected seleccionarFoto(evento: Event): void {
    const input = evento.target as HTMLInputElement;
    const archivo = input.files?.[0] ?? null;
    this.errorFoto.set(null);

    if (!archivo) {
      this.foto = null;
      this.fotoNombre.set(null);
      return;
    }
    if (!ReporteComunitario.TIPOS_PERMITIDOS.includes(archivo.type)) {
      this.errorFoto.set('Solo se aceptan fotos en JPEG, PNG o WEBP.');
      input.value = '';
      return;
    }
    if (archivo.size > ReporteComunitario.TAMANO_MAXIMO) {
      this.errorFoto.set('La foto no puede superar 5MB.');
      input.value = '';
      return;
    }
    this.foto = archivo;
    this.fotoNombre.set(archivo.name);
  }

  protected quitarFoto(input: HTMLInputElement): void {
    this.foto = null;
    this.fotoNombre.set(null);
    this.errorFoto.set(null);
    input.value = '';
  }

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
      .crearReporte(
        {
          municipio_id: this.municipioId,
          tipo_evento: this.tipoEvento,
          descripcion: this.descripcion || undefined,
          zona_aproximada: this.zonaAproximada || undefined,
        },
        this.foto ?? undefined,
      )
      .subscribe({
        next: () => {
          this.enviando.set(false);
          this.enviado.set(true);
          this.mostrarFormulario.set(false);
          this.descripcion = '';
          this.zonaAproximada = '';
          this.foto = null;
          this.fotoNombre.set(null);
        },
        error: () => {
          this.enviando.set(false);
          this.error.set('No se pudo enviar el reporte. Intenta de nuevo en un momento.');
        },
      });
  }
}
