import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import { AlertaActiva, HistoricoMunicipio, Municipio, RiesgoMunicipio } from '../models/cauce.models';

@Injectable({ providedIn: 'root' })
export class CauceApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl;

  listarMunicipios(): Observable<Municipio[]> {
    return this.http.get<Municipio[]>(`${this.baseUrl}/municipios`);
  }

  obtenerRiesgo(municipioId: number): Observable<RiesgoMunicipio> {
    return this.http.get<RiesgoMunicipio>(`${this.baseUrl}/municipios/${municipioId}/riesgo`);
  }

  obtenerHistorico(municipioId: number): Observable<HistoricoMunicipio> {
    return this.http.get<HistoricoMunicipio>(`${this.baseUrl}/municipios/${municipioId}/historico`);
  }

  alertasActivas(): Observable<AlertaActiva[]> {
    return this.http.get<AlertaActiva[]>(`${this.baseUrl}/alertas/activas`);
  }
}
