import { Component, OnInit, signal } from '@angular/core';

import { FooterFuentes } from './components/footer-fuentes/footer-fuentes';
import { Hero } from './components/hero/hero';
import { HistoricoMunicipio } from './components/historico-municipio/historico-municipio';
import { LeyendaRiesgo } from './components/leyenda-riesgo/leyenda-riesgo';
import { MapaCuencas } from './components/mapa-cuencas/mapa-cuencas';
import { Navbar } from './components/navbar/navbar';
import { PanelRiesgo } from './components/panel-riesgo/panel-riesgo';
import {
  HistoricoMunicipio as HistoricoMunicipioDatos,
  Municipio,
  NivelRiesgo,
  RiesgoMunicipio,
} from './models/cauce.models';
import { CauceApiService } from './services/cauce-api.service';

@Component({
  selector: 'app-root',
  imports: [Navbar, Hero, MapaCuencas, LeyendaRiesgo, PanelRiesgo, HistoricoMunicipio, FooterFuentes],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  protected readonly municipios = signal<Municipio[]>([]);
  protected readonly riesgoPorMunicipio = signal<Map<number, NivelRiesgo | null>>(new Map());

  protected readonly municipioSeleccionado = signal<Municipio | null>(null);
  protected readonly riesgoSeleccionado = signal<RiesgoMunicipio | null>(null);
  protected readonly historicoSeleccionado = signal<HistoricoMunicipioDatos | null>(null);
  protected readonly cargandoDetalle = signal(false);

  constructor(private readonly api: CauceApiService) {}

  ngOnInit(): void {
    this.api.listarMunicipios().subscribe((municipios) => {
      this.municipios.set(municipios);
      this.cargarRiesgoParaMapa(municipios);
    });
  }

  private cargarRiesgoParaMapa(municipios: Municipio[]): void {
    for (const municipio of municipios) {
      this.api.obtenerRiesgo(municipio.id).subscribe((riesgo) => {
        const inundacion = riesgo.riesgos.find((r) => r.tipo_evento === 'inundacion');
        const mapa = new Map(this.riesgoPorMunicipio());
        mapa.set(municipio.id, inundacion?.nivel_riesgo ?? null);
        this.riesgoPorMunicipio.set(mapa);
      });
    }
  }

  protected seleccionarMunicipio(municipioId: number): void {
    const municipio = this.municipios().find((m) => m.id === municipioId) ?? null;
    this.municipioSeleccionado.set(municipio);
    this.riesgoSeleccionado.set(null);
    this.historicoSeleccionado.set(null);
    this.cargandoDetalle.set(true);

    this.api.obtenerRiesgo(municipioId).subscribe((riesgo) => {
      this.riesgoSeleccionado.set(riesgo);
      this.cargandoDetalle.set(false);
    });
    this.api.obtenerHistorico(municipioId).subscribe((historico) => {
      this.historicoSeleccionado.set(historico);
    });
  }
}
