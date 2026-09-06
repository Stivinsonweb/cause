# Desplegar Cauce (Fase 5)

Estos pasos requieren que tú crees las cuentas — no se pueden automatizar desde
aquí. El repo ya tiene la configuración lista (`render.yaml`, `netlify.toml`) para
que cada paso sea lo más rápido posible.

## 1. Base de datos — Supabase (PostgreSQL + PostGIS)

El proyecto usa PostgreSQL (no MySQL) precisamente para poder desplegar en
Supabase, que es más confiable que las opciones gratuitas de MySQL.

1. Crea una cuenta en https://supabase.com ("Sign up with GitHub" es lo más
   simple).
2. **New project**: elige un nombre (ej. `cauce`), una contraseña para la base
   de datos (apúntala) y la región más cercana a Colombia disponible (ej.
   `us-east-1`). Espera 1-2 minutos a que se aprovisione.
3. Ve a **SQL Editor** (panel izquierdo) y ejecuta, pegando el contenido de cada
   archivo y dando "Run", en este orden: `database/schema.sql`, luego los 5
   archivos de `database/seeds/` en orden numérico (01 a 05). PostGIS ya viene
   habilitable con `CREATE EXTENSION IF NOT EXISTS postgis;` — esa línea ya está
   al inicio de `schema.sql`, no hace falta activarla aparte.
4. Ve a **Project Settings > Database > Connection string**, elige el modo
   **Session pooler** (puerto 6543 — mejor para Render en su plan free, que abre
   pocas conexiones concurrentes) y copia el connection string, cambiando el
   prefijo a `postgresql+psycopg2://` en vez de `postgresql://`:
   `postgresql+psycopg2://postgres.XXXX:TU_CONTRASEÑA@aws-0-xxxx.pooler.supabase.com:6543/postgres`

## 2. Backend — Render

1. Crea una cuenta en https://render.com (puedes usar "Sign up with GitHub" —
   un clic, usa la cuenta que ya conectamos).
2. En el dashboard: **New > Blueprint**, selecciona el repo `cause` — Render
   detecta automáticamente `render.yaml` en la raíz.
3. Antes de desplegar, Render te pedirá los valores marcados `sync: false`:
   - `DATABASE_URL`: el connection string de Supabase del paso 1 (con
     `postgresql+psycopg2://`).
   - `IDEAM_API_KEY`: déjalo vacío por ahora.
   - `CORS_ORIGINS`: pon un valor temporal (ej. `http://localhost:4200`) — lo
     actualizas en el paso 4 con la URL real de Netlify.
   - `JWT_SECRET_KEY` lo genera Render solo (`generateValue: true`).
4. Despliega. Cuando termine, copia la URL pública que te da Render (algo como
   `https://cauce-backend.onrender.com`).
5. Prueba que responde: `https://cauce-backend-XXXX.onrender.com/health` debe
   devolver `{"status":"ok"}`.

**Nota:** el plan free de Render "duerme" el servicio tras un rato sin tráfico —
la primera petición después de dormir tarda unos segundos. Normal para un MVP.

## 3. Frontend — Netlify

1. Antes de desplegar, edita
   `frontend/src/environments/environment.ts` y reemplaza el placeholder con la
   URL real de Render del paso 2:
   ```ts
   export const environment = {
     production: true,
     apiUrl: 'https://cauce-backend-XXXX.onrender.com',
   };
   ```
   Haz commit y push de ese cambio.
2. Crea una cuenta en https://netlify.com ("Sign up with GitHub").
3. **Add new site > Import an existing project**, elige el repo `cause` —
   Netlify detecta `netlify.toml` automáticamente (build command, carpeta de
   publicación y la regla de redirección para el router de Angular ya están
   configuradas ahí).
4. Despliega. Netlify te da una URL tipo `https://cauce-xxxx.netlify.app`.

## 4. Cerrar el círculo: CORS

1. Vuelve al dashboard de Render, entra a las variables de entorno del servicio
   `cauce-backend`, y actualiza `CORS_ORIGINS` con la URL real de Netlify del
   paso 3 (ej. `https://cauce-xxxx.netlify.app`). Guarda — Render redespliega solo.

## 5. Probar de punta a punta

Abre la URL de Netlify en el navegador: el mapa debe cargar los 6 municipios y,
al hacer clic en uno, el panel de riesgo e histórico deben poblarse con datos
reales desde el backend en Render.

## Dominio propio (opcional)

Mientras el proyecto sea un MVP/demo, el subdominio gratuito de Netlify
(`cauce-xxxx.netlify.app`) es suficiente. Ver sección 7 de
`docs/proyecto-cauce-contexto.md` para opciones de dominio propio cuando el
proyecto lo amerite.
