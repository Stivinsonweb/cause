import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { environment } from '../../environments/environment';

const CLAVE_TOKEN = 'cauce_token';

interface TokenPayload {
  sub: string;
  usuario_id: number;
  rol: 'ciudadano' | 'entidad' | 'admin';
  municipio_id: number | null;
  exp: number;
}

interface LoginResponse {
  access_token: string;
  token_type: string;
  rol: string;
}

function decodificarPayload(token: string): TokenPayload | null {
  try {
    const [, payload] = token.split('.');
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return null;
  }
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl;

  private readonly tokenActual = signal<string | null>(this.leerTokenValido());

  readonly usuario = computed(() => {
    const token = this.tokenActual();
    return token ? decodificarPayload(token) : null;
  });

  private leerTokenValido(): string | null {
    let token: string | null = null;
    try {
      token = localStorage.getItem(CLAVE_TOKEN);
    } catch {
      return null;
    }
    if (!token) return null;
    const payload = decodificarPayload(token);
    if (!payload || payload.exp * 1000 < Date.now()) {
      try {
        localStorage.removeItem(CLAVE_TOKEN);
      } catch {
        /* almacenamiento no disponible (modo privado, etc.) */
      }
      return null;
    }
    return token;
  }

  login(correo: string, contrasena: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.baseUrl}/auth/login`, { correo, contrasena }).pipe(
      tap((respuesta) => {
        try {
          localStorage.setItem(CLAVE_TOKEN, respuesta.access_token);
        } catch {
          /* almacenamiento no disponible; la sesión no persiste al recargar */
        }
        this.tokenActual.set(respuesta.access_token);
      }),
    );
  }

  logout(): void {
    try {
      localStorage.removeItem(CLAVE_TOKEN);
    } catch {
      /* nada que limpiar */
    }
    this.tokenActual.set(null);
  }

  token(): string | null {
    return this.tokenActual();
  }

  puedeModerar(): boolean {
    const rol = this.usuario()?.rol;
    return rol === 'entidad' || rol === 'admin';
  }
}
