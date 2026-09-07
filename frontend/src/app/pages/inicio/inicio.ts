import { Component, OnInit, computed, signal } from '@angular/core';

import { ComoFunciona } from '../../components/como-funciona/como-funciona';
import { FooterFuentes } from '../../components/footer-fuentes/footer-fuentes';
import { Hero } from '../../components/hero/hero';
import { HistoricoMunicipio } from '../../components/historico-municipio/historico-municipio';
import { LeyendaRiesgo } from '../../components/leyenda-riesgo/leyenda-riesgo';
import { MapaCuencas } from '../../components/mapa-cuencas/mapa-cuencas';
import { Navbar } from '../../components/navbar/navbar';
import { PanelRiesgo } from '../../components/panel-riesgo/panel-riesgo';
import { Estadisticas } from '../../components/estadisticas/estadisticas';
import { ReporteComunitario } from '../../components/reporte-comunitario/reporte-comunitario';
import { MunicipioConRiesgo, SliderRiesgo } from '../../components/slider-riesgo/slider-riesgo';
import {
  AlertaActiva,
  Estadisticas as EstadisticasDatos,
  HistoricoMunicipio as HistoricoMunicipioDatos,
  Municipio,
  NivelRiesgo,
  RiesgoTipo,
  RiesgoMunicipio,
} from '../../models/cauce.models';
import { CauceApiService } from '../../services/cauce-api.service';

@Component({
  selector: 'app-inicio',
  imports: [
    Navbar,
    Hero,
    Estadisticas,
    MapaCuencas,
    LeyendaRiesgo,
    PanelRiesgo,
    ReporteComunitario,
    SliderRiesgo,
    ComoFunciona,
    HistoricoMunicipio,
    FooterFuentes,
  ],
  templateUrl: './inicio.html',
  styleUrl: './inicio.css',
})
export class Inicio implements OnInit {
  protected readonly municipios = signal<Municipio[]>([]);
  protected readonly riesgoPorMunicipio = signal<Map<number, NivelRiesgo | null>>(new Map());
  protected readonly riesgoInundacionPorMunicipio = signal<Map<number, RiesgoTipo | null>>(new Map());
  protected readonly estadisticas = signal<EstadisticasDatos | null>(null);
  protected readonly alertasActivas = signal<AlertaActiva[] | null>(null);

  protected readonly municipioSeleccionado = signal<Municipio | null>(null);
  protected readonly riesgoSeleccionado = signal<RiesgoMunicipio | null>(null);
  protected readonly historicoSeleccionado = signal<HistoricoMunicipioDatos | null>(null);
  protected readonly cargandoDetalle = signal(false);

  protected readonly itemsSlider = computed<MunicipioConRiesgo[]>(() =>
    this.municipios().map((municipio) => ({
      municipio,
      riesgo: this.riesgoInundacionPorMunicipio().get(municipio.id) ?? null,
    })),
  );

  constructor(private readonly api: CauceApiService) {}

  ngOnInit(): void {
    this.api.listarMunicipios().subscribe((municipios) => {
      this.municipios.set(municipios);
      this.cargarRiesgoParaMapa(municipios);
    });
    this.api.estadisticas().subscribe((datos) => this.estadisticas.set(datos));
    this.api.alertasActivas().subscribe((alertas) => this.alertasActivas.set(alertas));
  }

  private cargarRiesgoParaMapa(municipios: Municipio[]): void {
    for (const municipio of municipios) {
      this.api.obtenerRiesgo(municipio.id).subscribe((riesgo) => {
        const inundacion = riesgo.riesgos.find((r) => r.tipo_evento === 'inundacion') ?? null;

        const mapaNivel = new Map(this.riesgoPorMunicipio());
        mapaNivel.set(municipio.id, inundacion?.nivel_riesgo ?? null);
        this.riesgoPorMunicipio.set(mapaNivel);

        const mapaDetalle = new Map(this.riesgoInundacionPorMunicipio());
        mapaDetalle.set(municipio.id, inundacion);
        this.riesgoInundacionPorMunicipio.set(mapaDetalle);
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
