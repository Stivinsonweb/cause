import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { LucideCheck, LucideClock, LucideLogOut, LucideX } from '@lucide/angular';

import { Navbar } from '../../components/navbar/navbar';
import { EstadoReporte, ReporteComunitario } from '../../models/cauce.models';
import { AuthService } from '../../services/auth.service';
import { CauceApiService } from '../../services/cauce-api.service';

@Component({
  selector: 'app-moderacion',
  imports: [FormsModule, DatePipe, Navbar, LucideCheck, LucideClock, LucideLogOut, LucideX],
  templateUrl: './moderacion.html',
  styleUrl: './moderacion.css',
})
export class Moderacion implements OnInit {
  private readonly api = inject(CauceApiService);
  protected readonly auth = inject(AuthService);

  ngOnInit(): void {
    if (this.auth.puedeModerar()) {
      this.cargarReportes();
    }
  }

  protected correo = '';
  protected contrasena = '';
  protected readonly ingresando = signal(false);
  protected readonly errorLogin = signal<string | null>(null);

  protected readonly filtro = signal<EstadoReporte>('pendiente');
  protected readonly reportes = signal<ReporteComunitario[]>([]);
  protected readonly cargandoReportes = signal(false);

  protected readonly autorizado = computed(() => this.auth.puedeModerar());

  protected ingresar(): void {
    this.ingresando.set(true);
    this.errorLogin.set(null);
    this.auth.login(this.correo, this.contrasena).subscribe({
      next: () => {
        this.ingresando.set(false);
        this.contrasena = '';
        if (this.auth.puedeModerar()) {
          this.cargarReportes();
        }
      },
      error: () => {
        this.ingresando.set(false);
        this.errorLogin.set('Correo o contraseña incorrectos.');
      },
    });
  }

  protected salir(): void {
    this.auth.logout();
    this.reportes.set([]);
  }

  protected cambiarFiltro(estado: EstadoReporte): void {
    this.filtro.set(estado);
    this.cargarReportes();
  }

  protected cargarReportes(): void {
    this.cargandoReportes.set(true);
    this.api.reportesModeracion(this.filtro()).subscribe({
      next: (reportes) => {
        this.reportes.set(reportes);
        this.cargandoReportes.set(false);
      },
      error: () => this.cargandoReportes.set(false),
    });
  }

  protected moderar(reporte: ReporteComunitario, estado: EstadoReporte): void {
    this.api.moderarReporte(reporte.id, estado).subscribe(() => this.cargarReportes());
  }

  protected nombreTipo(tipo: ReporteComunitario['tipo_evento']): string {
    return tipo === 'inundacion' ? 'Inundación' : tipo === 'deslizamiento' ? 'Deslizamiento' : 'Sequía';
  }
}
