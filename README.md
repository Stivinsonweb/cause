# Cauce

**Sistema de alerta temprana de desastres naturales para el Chocó, Colombia.**

Cauce traduce datos de lluvia, nivel de ríos y eventos históricos en un nivel de
riesgo comprensible por municipio —inundación fluvial, deslizamiento y sequía—
y lo muestra en un mapa interactivo con panel de detalle, pensado para redes
lentas y uso desde el celular.

El Chocó tiene una de las exposiciones más altas de Colombia a inundaciones y
deslizamientos, y no existía una herramienta pública, local y actualizada que
convirtiera esos datos en algo que la comunidad y las entidades de gestión del
riesgo pudieran leer en segundos. Eso es lo que Cauce intenta cubrir.

---

## Qué hace

- **Mapa de riesgo por municipio** — 30 municipios del Chocó con geometrías
  reales, coloreados por nivel de riesgo (bajo / medio / alto / crítico).
- **Tres fenómenos** — inundación fluvial, deslizamiento de tierra y sequía.
- **Panel de detalle** — las variables que explican cada estimación (lluvia
  acumulada, nivel del río), no solo el color.
- **Histórico por municipio** — eventos registrados y tendencia de mediciones.
- **Alertas activas** — listado de municipios que superan el umbral en este momento.
- **Canal de verificación comunitaria** — cualquier persona puede reportar un
  evento con foto y ubicación; los reportes pasan por moderación de una entidad
  antes de publicarse.
- **PWA** — funciona con conexión débil y se puede instalar en el teléfono.

### Transparencia sobre el modelo

El modelo de riesgo es un **prototipo de pipeline validado, no un clasificador de
producción**, y el código lo dice explícitamente en cada módulo:

- **Inundación** — Random Forest entrenado sobre 42 eventos reales documentados
  (prensa / OCHA / UNGRD) cruzados con precipitación histórica de NASA POWER.
  Validado con leave-one-out, la única validación cruzada razonable con un
  dataset de ese tamaño. Incluye ejemplos negativos sintéticos (fechas alejadas
  >45 días de cualquier evento), porque nadie reporta en prensa una lluvia que no
  causó daños y sin ellos el modelo predecía "crítico" incluso con 0 mm.
- **Deslizamiento** — solo 5 eventos verificados en todo el departamento, y 3
  fueron detonados por sismos, no por lluvia. Se usa el modelo de inundación como
  *proxy*, declarado como tal en `version_modelo` para que nadie lo confunda con
  un modelo propio.
- **Sequía** — 1 solo evento real (Quibdó, 2007). Se usa una heurística de umbral
  sobre lluvia acumulada de 15 días, con cobertura mínima de días medidos: sin ese
  requisito, un sistema recién desplegado disparaba "sequía crítica" en casi todos
  los municipios por falta de historial, no por sequía real.
- Los municipios sin ninguna estación IDEAM activa no reciben predicción, en vez
  de recibir una inventada.

**Esto no sustituye a los canales oficiales de gestión del riesgo** (UNGRD, IDEAM,
consejos municipales de gestión del riesgo). Es una herramienta de consulta y
visualización.

---

## Arquitectura

```
[ IDEAM · NASA POWER · OCHA/UNGRD · SGC ]
                 │
                 ▼
  [ Ingestión programada (APScheduler) ]
                 │
                 ▼
   [ PostgreSQL + PostGIS (Supabase) ]
                 │
                 ▼
   [ API REST — FastAPI ]  ◀──  [ Modelo de riesgo — scikit-learn ]
                 │
                 ▼
  [ Frontend Angular + Tailwind (PWA) ]
```

**Stack**

| Capa | Tecnología |
|---|---|
| Frontend | Angular 21, Tailwind CSS 4, Leaflet, Lucide, Service Worker (PWA) |
| Backend | Python 3.13, FastAPI, SQLAlchemy 2, Pydantic 2, SlowAPI (rate limiting) |
| Base de datos | PostgreSQL 15 + PostGIS (`geometry(Polygon, 4326)`, índices GIST) |
| Modelo | scikit-learn (Random Forest), pandas, joblib |
| Autenticación | JWT (`python-jose`), hash de contraseñas con bcrypt |
| Almacenamiento | Supabase Storage (fotos de reportes comunitarios) |
| Despliegue | Netlify (frontend), Render (backend), Supabase (base de datos) |

---

## Estructura del repositorio

```
cauce/
├── backend/
│   ├── app/
│   │   ├── main.py            FastAPI, CORS, rate limiting, lifespan
│   │   ├── routers/           municipios, alertas, auth, admin, reportes
│   │   ├── models/orm.py      modelo SQLAlchemy
│   │   ├── ml/                entrenamiento, predicción, features, heurística de sequía
│   │   ├── ingesta/           tarea programada de ingestión de datos
│   │   ├── security.py        JWT y control de roles
│   │   └── storage.py         subida de fotos a Supabase Storage
│   └── requirements.txt
├── frontend/
│   └── src/app/
│       ├── components/        hero, mapa-cuencas, panel-riesgo, leyenda-riesgo,
│       │                      historico-municipio, alertas-activas, estadisticas,
│       │                      slider-riesgo, reporte-comunitario, como-funciona,
│       │                      navbar, footer-fuentes
│       ├── pages/             inicio, moderacion
│       └── services/
├── database/
│   ├── schema.sql             esquema PostgreSQL/PostGIS vigente
│   ├── seeds/                 30 municipios, cuencas, estaciones, eventos históricos
│   └── migrations/            sequía, reportes comunitarios
├── docs/
│   ├── proyecto-cauce-contexto.md   contexto completo: diseño, datos, fases
│   └── despliegue.md                guía paso a paso de despliegue
├── netlify.toml
└── render.yaml
```

---

## API

Base: `https://cauce-backend.onrender.com` · documentación interactiva en `/docs`

| Método | Ruta | Acceso | Descripción |
|---|---|---|---|
| `GET` | `/health` | público | Estado del servicio |
| `GET` | `/municipios` | público | Lista de municipios con su riesgo actual |
| `GET` | `/municipios/estadisticas` | público | Cifras agregadas del departamento |
| `GET` | `/municipios/{id}/riesgo` | público | Riesgo por fenómeno y variables que lo explican |
| `GET` | `/municipios/{id}/historico` | público | Eventos y mediciones históricas |
| `GET` | `/municipios/{id}/reportes` | público | Reportes comunitarios aprobados |
| `GET` | `/alertas/activas` | público | Municipios en alerta en este momento |
| `POST` | `/reportes` | público | Crear reporte comunitario (con foto) |
| `GET` | `/reportes` | entidad, admin | Cola de moderación |
| `PATCH`| `/reportes/{id}` | entidad, admin | Aprobar o rechazar un reporte |
| `POST` | `/auth/login` | público | Obtener token JWT |
| `GET` | `/admin/ingestion` | admin | Trazabilidad del pipeline de ingestión |

El ciudadano no necesita cuenta para consultar el mapa. `entidad` modera reportes
y ve históricos; `admin` es el único que ve el estado del pipeline.

---

## Ejecutar en local

Requisitos: Python 3.13, Node 20+, y una base de datos PostgreSQL con PostGIS
(local o un proyecto de Supabase).

### 1. Base de datos

```bash
psql "$DATABASE_URL" -f database/schema.sql
for f in database/seeds/*.sql;      do psql "$DATABASE_URL" -f "$f"; done
for f in database/migrations/*.sql; do psql "$DATABASE_URL" -f "$f"; done
```

### 2. Backend

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env     # completa DATABASE_URL, JWT_SECRET_KEY, SUPABASE_*
uvicorn app.main:app --reload
```

API en `http://localhost:8000`, documentación en `http://localhost:8000/docs`.

### 3. Frontend

```bash
cd frontend
npm install
npm start
```

Sitio en `http://localhost:4200`, apuntando al backend local
(`src/environments/environment.ts`).

### 4. Entrenar el modelo (opcional)

```bash
cd backend && source .venv/bin/activate
python -m app.ml.train
```

Guarda `app/ml/modelo_riesgo_inundacion.joblib` y su `.meta.json` con las
métricas y supuestos de esa corrida.

---

## Variables de entorno

`backend/.env` (plantilla en `backend/.env.example`, **nunca se versiona**):

| Variable | Descripción |
|---|---|
| `DATABASE_URL` | `postgresql+psycopg2://…` — en Supabase, usar el *Session pooler* (puerto 6543) |
| `JWT_SECRET_KEY` | Secreto de firma de tokens |
| `JWT_EXPIRATION_MINUTES` | Vigencia del token (por defecto 60) |
| `IDEAM_API_KEY` | Opcional, mientras no haya acceso real a la API de IDEAM |
| `CORS_ORIGINS` | Orígenes permitidos, separados por coma |
| `SUPABASE_URL` | URL del proyecto de Supabase |
| `SUPABASE_SERVICE_KEY` | Clave `service_role` — secreta, nunca la publishable/anon |
| `ENTORNO` | `desarrollo` o `produccion` |

---

## Despliegue

`render.yaml` y `netlify.toml` ya están configurados. Los pasos exactos —crear el
proyecto de Supabase, cargar el esquema, desplegar el blueprint en Render,
conectar Netlify y cerrar CORS— están en **[`docs/despliegue.md`](docs/despliegue.md)**.

Nota: el plan gratuito de Render suspende el servicio tras un rato sin tráfico, así
que la primera petición después de una pausa tarda unos segundos.

---

## Diseño

Paleta deliberadamente terrosa, no un semáforo saturado, y **ningún color de riesgo
aparece sin texto o ícono que lo acompañe** (accesibilidad para daltonismo
rojo-verde). Tipografía: Spectral para titulares, IBM Plex Sans para interfaz, IBM
Plex Mono para cifras —refuerza la sensación de instrumento de medición real.

Principios que el proyecto mantiene: un solo momento animado por vista, un único
CTA principal por pantalla, el mapa integrado al fondo de la sección en vez de
encerrado en una tarjeta, y la fuente del dato siempre citada en prosa, no como
badge decorativo. Los tokens completos están en
[`docs/proyecto-cauce-contexto.md`](docs/proyecto-cauce-contexto.md).

---

## Privacidad y seguridad

Sujeto a la **Ley 1581 de 2012** y el Decreto 1377 de 2013 (protección de datos
personales, Colombia).

- Datos personales mínimos: nombre y correo de usuarios de entidad/admin. Consultar
  el mapa no requiere identificarse.
- Secretos solo en variables de entorno; `.env` está en `.gitignore` desde el
  primer commit.
- Contraseñas siempre con hash bcrypt, nunca en texto plano ni en logs.
- HTTPS en producción, rate limiting en la API y principio de mínimo privilegio por rol.
- Registro de auditoría del pipeline de ingestión (`registro_ingestion`).

---

## Fuentes de datos

- **IDEAM** — estaciones pluviométricas e hidrométricas, precipitación y nivel de ríos.
- **NASA POWER** — precipitación histórica para las fechas de los eventos de entrenamiento.
- **OCHA / UNGRD** — eventos de desastre históricos documentados.
- **Servicio Geológico Colombiano** — contexto de amenaza por movimientos en masa.
- **Reportes comunitarios** — verificados por moderación antes de publicarse.
