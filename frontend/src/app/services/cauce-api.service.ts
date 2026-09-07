import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import {
  AlertaActiva,
  EstadoReporte,
  Estadisticas,
  HistoricoMunicipio,
  Municipio,
  ReporteComunitario,
  ReporteComunitarioCrear,
  RiesgoMunicipio,
} from '../models/cauce.models';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class CauceApiService {
  private readonly http = inject(HttpClient);
  private readonly auth = inject(AuthService);
  private readonly baseUrl = environment.apiUrl;

  private cabecerasAuth(): HttpHeaders {
    const token = this.auth.token();
    return token ? new HttpHeaders({ Authorization: `Bearer ${token}` }) : new HttpHeaders();
  }

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

  estadisticas(): Observable<Estadisticas> {
    return this.http.get<Estadisticas>(`${this.baseUrl}/municipios/estadisticas`);
  }

  reportesVerificados(municipioId: number): Observable<ReporteComunitario[]> {
    return this.http.get<ReporteComunitario[]>(`${this.baseUrl}/municipios/${municipioId}/reportes`);
  }

  crearReporte(datos: ReporteComunitarioCrear): Observable<ReporteComunitario> {
    return this.http.post<ReporteComunitario>(`${this.baseUrl}/reportes`, datos);
  }

  reportesModeracion(estado?: EstadoReporte): Observable<ReporteComunitario[]> {
    let params = new HttpParams();
    if (estado) params = params.set('estado', estado);
    return this.http.get<ReporteComunitario[]>(`${this.baseUrl}/reportes`, {
      headers: this.cabecerasAuth(),
      params,
    });
  }

  moderarReporte(id: number, estado: EstadoReporte): Observable<ReporteComunitario> {
    return this.http.patch<ReporteComunitario>(
      `${this.baseUrl}/reportes/${id}`,
      { estado },
      { headers: this.cabecerasAuth() },
    );
  }
}
