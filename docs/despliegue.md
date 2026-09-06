# Desplegar Cauce (Fase 5)

Estos pasos requieren que tú crees las cuentas — no se pueden automatizar desde
aquí. El repo ya tiene la configuración lista (`render.yaml`, `netlify.toml`) para
que cada paso sea lo más rápido posible.

## 1. Base de datos — db4free.net

1. Crea una cuenta gratis en https://www.db4free.net/signup.php (elige un nombre
   de base de datos, ej. `cauce_prod`, y usuario/contraseña — apúntalos).
2. Espera el correo de confirmación (puede tardar unos minutos) y actívala.
3. Entra a phpMyAdmin desde tu panel de db4free.net y ejecuta, en este orden:
   `database/schema.sql`, luego los 5 archivos de `database/seeds/` en orden
   numérico (01 a 05).
4. Con eso tienes el connection string:
   `mysql+pymysql://TU_USUARIO:TU_CONTRASEÑA@db4free.net:3306/TU_BASE_DE_DATOS`

**Advertencia (ya está en el contexto del proyecto):** db4free.net es un servicio
de pruebas/educación, no da garantías de continuidad. Sirve perfecto para el MVP
y la sustentación; para producción real con comunidades dependiendo del sistema,
migrar a una base de datos administrada.

## 2. Backend — Render

1. Crea una cuenta en https://render.com (puedes usar "Sign up with GitHub" —
   un clic, usa la cuenta que ya conectamos).
2. En el dashboard: **New > Blueprint**, selecciona el repo `cause` — Render
   detecta automáticamente `render.yaml` en la raíz.
3. Antes de desplegar, Render te pedirá los valores marcados `sync: false`:
   - `DATABASE_URL`: el connection string de db4free.net del paso 1.
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
