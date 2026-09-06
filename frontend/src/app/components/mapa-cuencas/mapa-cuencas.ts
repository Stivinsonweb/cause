import { AfterViewInit, Component, ElementRef, Input, OnChanges, OnDestroy, Output, EventEmitter, SimpleChanges, ViewChild } from '@angular/core';
import * as L from 'leaflet';

import { Municipio, NivelRiesgo } from '../../models/cauce.models';
import { RIESGO_COLOR, SIN_DATOS_COLOR } from '../../models/riesgo-visual';

@Component({
  selector: 'app-mapa-cuencas',
  imports: [],
  templateUrl: './mapa-cuencas.html',
  styleUrl: './mapa-cuencas.css',
})
export class MapaCuencas implements AfterViewInit, OnChanges, OnDestroy {
  @Input() municipios: Municipio[] = [];
  @Input() riesgoPorMunicipio: Map<number, NivelRiesgo | null> = new Map();
  @Input() municipioSeleccionadoId: number | null = null;
  @Output() municipioSeleccionado = new EventEmitter<number>();

  @ViewChild('contenedorMapa', { static: true }) contenedorMapa!: ElementRef<HTMLDivElement>;

  private mapa?: L.Map;
  private capasPorMunicipio = new Map<number, L.Polygon>();
  private vistaAjustada = false;

  ngAfterViewInit(): void {
    this.mapa = L.map(this.contenedorMapa.nativeElement, {
      scrollWheelZoom: false,
    }).setView([5.6, -76.9], 8);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; colaboradores de OpenStreetMap',
      maxZoom: 18,
    }).addTo(this.mapa);

    this.dibujarMunicipios();
  }

  ngOnChanges(cambios: SimpleChanges): void {
    if (!this.mapa) {
      return;
    }
    if (cambios['municipios'] || cambios['riesgoPorMunicipio']) {
      this.dibujarMunicipios();
    }
    if (cambios['municipioSeleccionadoId']) {
      this.resaltarSeleccionado();
    }
  }

  ngOnDestroy(): void {
    this.mapa?.remove();
  }

  private dibujarMunicipios(): void {
    if (!this.mapa) {
      return;
    }
    this.capasPorMunicipio.forEach((capa) => capa.remove());
    this.capasPorMunicipio.clear();

    for (const municipio of this.municipios) {
      if (!municipio.geometria) {
        continue;
      }
      const anillo = municipio.geometria.coordinates[0].map(([lon, lat]) => [lat, lon] as [number, number]);
      const nivel = this.riesgoPorMunicipio.get(municipio.id) ?? null;
      const color = nivel ? RIESGO_COLOR[nivel] : SIN_DATOS_COLOR;

      const poligono = L.polygon(anillo, {
        color: '#16211F',
        weight: 1,
        fillColor: color,
        fillOpacity: 0.55,
      }).addTo(this.mapa);

      poligono.bindTooltip(municipio.nombre, { sticky: true });
      poligono.on('click', () => this.municipioSeleccionado.emit(municipio.id));

      this.capasPorMunicipio.set(municipio.id, poligono);
    }

    if (!this.vistaAjustada && this.capasPorMunicipio.size > 0) {
      const grupo = L.featureGroup([...this.capasPorMunicipio.values()]);
      this.mapa.fitBounds(grupo.getBounds(), { padding: [20, 20] });
      this.vistaAjustada = true;
    }

    this.resaltarSeleccionado();
  }

  private resaltarSeleccionado(): void {
    this.capasPorMunicipio.forEach((capa, id) => {
      capa.setStyle({ weight: id === this.municipioSeleccionadoId ? 3 : 1 });
    });
  }
}
