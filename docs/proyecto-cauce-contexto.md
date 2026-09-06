# Cauce — Sistema de alerta temprana de desastres naturales, Chocó

Documento de contexto completo del proyecto. Está pensado para servir como referencia de trabajo en Claude Code: define qué se construye, cómo se diseña, cómo se estructuran los datos, cómo se protege la información y cómo se despliega, de modo que se pueda dividir en tareas concretas para ir ejecutando por fases.

---

## 1. Resumen del proyecto

**Problema:** el Chocó tiene una de las exposiciones más altas del país a inundaciones fluviales y deslizamientos, y no existe una herramienta pública, local y actualizada que traduzca los datos de lluvia y nivel de los ríos en una alerta comprensible para la comunidad y para las entidades de gestión del riesgo.

**Qué construye Cauce:** un sistema de estimación de riesgo (no de predicción exacta) que combina datos históricos y recientes de precipitación y caudal para clasificar el nivel de riesgo de inundación y deslizamiento por municipio, mostrado en un mapa interactivo con panel de detalle.

**Fenómenos del MVP:** inundación fluvial y deslizamiento de tierra. Comparten variables de entrada (lluvia acumulada, nivel de río, saturación de suelo, pendiente del terreno), así que el mismo pipeline de datos alimenta ambos modelos.

**Alcance geográfico del MVP:** seis municipios del Chocó (Quibdó, Istmina, Condoto, Tadó, Riosucio, Bojayá), escalable a los demás una vez validado.

**A quién sirve:**
- Ciudadano: quiere saber en segundos si su municipio está en riesgo hoy.
- Entidad de gestión del riesgo (alcaldías, UNGRD regional): necesita históricos, tendencias y detalle de las variables.
- Administrador del sistema: necesita ver el estado del pipeline de datos y la calidad de las predicciones.

---

## 2. Sistema de diseño

Basado en el mockup ya validado (`cauce-mockup.html`). Estos son los tokens y principios a mantener en la implementación Angular + Tailwind.

### Color
```
--swamp:        #0F2A2E   fondo oscuro (hero, secciones de énfasis)
--teal:         #1B4B4F   acento oscuro secundario
--teal-light:   #3F726E   líneas y detalles sobre fondo oscuro
--paper:        #EDEFE4   fondo claro general (no crema, verdoso neutro)
--paper-dim:    #E2E5D6   fondo claro secundario
--ink:          #16211F   texto principal
--ink-soft:     #46524C   texto secundario
--line:         #C8CDBC   bordes y divisores

--risk-bajo:     #4A7C4E
--risk-medio:    #C99A2E
--risk-alto:     #C4622D
--risk-critico:  #9B3A2C
```
Los colores de riesgo son deliberadamente terrosos, no un semáforo saturado — deben acompañarse siempre de texto/ícono, nunca solo color, por accesibilidad (daltonismo rojo-verde).

### Tipografía
- **Spectral** (serif) para titulares — tono editorial, de reporte de campo.
- **IBM Plex Sans** para interfaz y texto general.
- **IBM Plex Mono** para cifras de datos (mm de lluvia, metros de nivel de río) — refuerza la sensación de instrumento de medición real.

### Principios de diseño a mantener
- Un solo momento animado por vista (no animaciones dispersas en cada tarjeta).
- El mapa no va dentro de una tarjeta con sombra: se integra directo al fondo de la sección.
- Nada de semáforo de color puro sin texto de apoyo.
- Un único CTA principal por pantalla.
- Mostrar siempre la fuente del dato (IDEAM, Servicio Geológico Colombiano) en prosa, no como badge decorativo.
- Diseño offline-first / conexión débil: la app debe ser utilizable en redes lentas (PWA, carga progresiva).

### Componentes a construir en Angular
`HeroComponent`, `MapaCuencasComponent` (SVG interactivo o Leaflet según se decida), `PanelRiesgoComponent`, `LeyendaRiesgoComponent`, `HistoricoMunicipioComponent`, `NavbarComponent`, `FooterFuentesComponent`.

---

## 3. Arquitectura técnica

```
[ IDEAM API / SGC / archivos históricos ]
                |
                v
   [ Servicio de ingestión (Python, tarea programada) ]
                |
                v
        [ Base de datos MySQL ]
                |
                v
   [ API REST (Python + FastAPI) ]  <----  [ Modelo ML (scikit-learn / XGBoost) ]
                |
                v
   [ Frontend Angular + Tailwind (PWA) ]
```

**Backend recomendado:** Python + FastAPI. Vive en el mismo servicio la API REST y los modelos de machine learning (evita duplicar lógica en dos lenguajes). Si se prefiere mantener JavaScript en todo el stack, la alternativa es Node.js + Express, pero entonces el modelo ML se sirve aparte (microservicio Python) o se exporta a ONNX/TensorFlow.js.

**Base de datos:** PostgreSQL + PostGIS (desplegado en Supabase), con tipos espaciales (`geometry(Polygon, 4326)`, `geometry(Point, 4326)`) e índices GIST — suficiente para este alcance (ubicar municipios, calcular cercanía a ríos). *(Nota: el plan original de este documento proponía MySQL 8+ con migración a PostgreSQL solo si hiciera falta análisis espacial más complejo. En la implementación real se migró antes de lo previsto, por preferencia de hosting — Supabase da más garantías de continuidad que las opciones gratuitas de MySQL como db4free.net.)*

**Autenticación:** JWT para los perfiles de entidad/administrador. El ciudadano no necesita cuenta para consultar el mapa.

**Ingestión de datos:** tarea programada (APScheduler o Celery) que consulta periódicamente IDEAM/SGC, limpia los datos y los guarda en MySQL. Debe registrar cada corrida (éxito/fallo) para trazabilidad.

---

## 4. Modelo de datos

**El esquema real y vigente es `database/schema.sql` (PostgreSQL/PostGIS)** —
migrado desde el diseño original en MySQL que se muestra aquí abajo como
referencia histórica del modelado de datos (las tablas y relaciones son las
mismas; solo cambia la sintaxis: `AUTO_INCREMENT`→`SERIAL`, `ENUM`→`VARCHAR`
+ `CHECK`, `SPATIAL INDEX`→índice `GIST`, `DATETIME`→`TIMESTAMPTZ`).

```sql
CREATE TABLE municipios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL DEFAULT 'Chocó',
    geometria POLYGON NOT NULL SRID 4326,
    poblacion_estimada INT,
    SPATIAL INDEX(geometria)
);

CREATE TABLE cuencas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    rio_principal VARCHAR(100),
    geometria POLYGON NOT NULL SRID 4326,
    SPATIAL INDEX(geometria)
);

CREATE TABLE municipio_cuenca (
    municipio_id INT NOT NULL,
    cuenca_id INT NOT NULL,
    PRIMARY KEY (municipio_id, cuenca_id),
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    FOREIGN KEY (cuenca_id) REFERENCES cuencas(id)
);

CREATE TABLE estaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_ideam VARCHAR(50) UNIQUE,
    nombre VARCHAR(150),
    tipo ENUM('pluviometrica', 'hidrometrica', 'mixta') NOT NULL,
    ubicacion POINT NOT NULL SRID 4326,
    municipio_id INT,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    SPATIAL INDEX(ubicacion)
);

CREATE TABLE mediciones (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    estacion_id INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    lluvia_mm DECIMAL(6,2),
    nivel_rio_m DECIMAL(5,2),
    fuente VARCHAR(50) DEFAULT 'IDEAM',
    FOREIGN KEY (estacion_id) REFERENCES estaciones(id),
    INDEX idx_estacion_fecha (estacion_id, fecha_hora)
);

CREATE TABLE eventos_historicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    municipio_id INT NOT NULL,
    tipo_evento ENUM('inundacion', 'deslizamiento') NOT NULL,
    fecha DATE NOT NULL,
    severidad ENUM('bajo', 'medio', 'alto', 'critico') NOT NULL,
    fuente VARCHAR(100) DEFAULT 'UNGRD',
    descripcion TEXT,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id)
);

CREATE TABLE predicciones_riesgo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    municipio_id INT NOT NULL,
    tipo_evento ENUM('inundacion', 'deslizamiento') NOT NULL,
    fecha_calculo DATETIME NOT NULL,
    nivel_riesgo ENUM('bajo', 'medio', 'alto', 'critico') NOT NULL,
    probabilidad DECIMAL(5,4),
    variables_entrada JSON,
    version_modelo VARCHAR(20),
    FOREIGN KEY (municipio_id) REFERENCES municipios(id),
    INDEX idx_municipio_fecha (municipio_id, fecha_calculo)
);

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150),
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol ENUM('ciudadano', 'entidad', 'admin') NOT NULL DEFAULT 'entidad',
    municipio_id INT,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (municipio_id) REFERENCES municipios(id)
);

CREATE TABLE registro_ingestion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fuente VARCHAR(50),
    ejecutado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('exitoso', 'fallido', 'parcial') NOT NULL,
    detalle TEXT
);
```

Notas:
- `variables_entrada` en `predicciones_riesgo` guarda como JSON el snapshot de las variables que explican esa predicción (lluvia acumulada, nivel de río, etc.), para poder mostrar "por qué" en el panel de detalle sin recalcular.
- `usuarios.contrasena_hash` nunca almacena la contraseña en texto plano — usar bcrypt o argon2.
- Los campos espaciales (`POLYGON`, `POINT`) requieren MySQL 8+ para los índices `SPATIAL` con SRID definido.

---

## 5. Privacidad y seguridad de datos

**Marco legal aplicable:** Ley 1581 de 2012 (Régimen General de Protección de Datos Personales, Colombia) y su decreto reglamentario 1377 de 2013. Si el sistema llega a registrar usuarios (entidades, ciudadanos con cuenta), aplica: aviso de privacidad claro, finalidad específica del dato recolectado, y posibilidad de que el usuario solicite consulta, corrección o eliminación de sus datos.

**Qué datos personales maneja el sistema (mínimos):** correo y nombre de usuarios registrados (entidades/admin). El consumo público del mapa de riesgo no requiere identificar a la persona.

**Prácticas concretas a implementar:**
- Nunca versionar credenciales: todo secreto (contraseña de base de datos, claves JWT, API keys de IDEAM si aplica) va en variables de entorno (`.env`), y `.env` va en `.gitignore` desde el primer commit.
- Contraseñas de usuarios siempre con hash (bcrypt/argon2), nunca en texto plano ni siquiera en logs.
- HTTPS obligatorio en producción (los hostings gratuitos recomendados más abajo lo dan por defecto).
- Principio de mínimo privilegio: el rol `ciudadano` solo lee datos públicos de riesgo; `entidad` puede ver históricos de su municipio; `admin` es el único que ve el estado del pipeline de ingestión.
- Rate limiting en la API para evitar scraping masivo o abuso.
- Registro de auditoría (`registro_ingestion` y, si se agrega, un log de accesos administrativos) sin registrar datos sensibles en texto plano.
- Política de retención: definir cuánto tiempo se conservan las mediciones crudas vs. los agregados históricos, para no crecer la base de datos indefinidamente en un hosting gratuito con límite de almacenamiento.

---

## 6. Configuración del proyecto

Estructura de carpetas sugerida (monorepo):

```
cauce/
├── frontend/              (Angular + Tailwind)
│   ├── src/
│   └── environments/
│       ├── environment.ts
│       └── environment.prod.ts
├── backend/               (Python + FastAPI)
│   ├── app/
│   │   ├── main.py
│   │   ├── models/
│   │   ├── routers/
│   │   ├── ml/
│   │   └── ingesta/
│   ├── requirements.txt
│   └── .env.example
├── database/
│   ├── schema.sql
│   └── seeds/
└── docs/
    └── proyecto-cauce-contexto.md   (este archivo)
```

Variables de entorno mínimas (`backend/.env.example`, sin valores reales):
```
DATABASE_URL=postgresql+psycopg2://usuario:contrasena@host:puerto/nombre_bd
JWT_SECRET_KEY=
JWT_EXPIRATION_MINUTES=60
IDEAM_API_KEY=
ENTORNO=desarrollo
```

En el frontend, `environment.prod.ts` apunta a la URL pública del backend desplegado; `environment.ts` apunta a `localhost` para desarrollo.

---

## 7. Hosting y dominio gratuitos (opciones verificadas para 2026)

No existe un solo proveedor que dé gratis, para siempre, frontend + backend + MySQL + dominio propio con buena reputación — hay que combinar piezas. Aquí las opciones reales, no las que ya desaparecieron (Freenom, por ejemplo, está descontinuado):

**Frontend (Angular compilado, estático):**
- Vercel, Netlify o Cloudflare Pages — los tres son gratuitos de forma indefinida para proyectos personales, dan subdominio propio (`cauce.vercel.app`, etc.) y HTTPS automático. Cualquiera de los tres sirve; Netlify tiene la integración más simple con Angular vía `ng build`.

**Backend (Python + FastAPI):**
- Render (plan free): funciona bien, la limitación real es que el servicio "duerme" tras un rato de inactividad y tarda unos segundos en despertar en la siguiente petición — aceptable para un MVP/demo académica, no para un sistema de alerta 24/7 real.
- Fly.io: tiene una capa gratuita pequeña, pide tarjeta de crédito para verificar la cuenta aunque no cobre si te mantienes dentro del límite.

**Base de datos — decisión final: PostgreSQL en Supabase.** El plan original de
este documento recomendaba MySQL (db4free.net como opción gratuita más directa,
con la advertencia explícita de que es solo para pruebas/educación, no
producción). En la implementación real se optó por migrar a PostgreSQL/PostGIS
y desplegar en **Supabase**, que tiene un plan gratuito genuinamente más
confiable que db4free.net y soporte nativo de datos espaciales. Ver
`docs/despliegue.md` para los pasos exactos. (Alternativas si Supabase no
conviniera: Neon, también PostgreSQL gratuito; Clever Cloud si se prefiriera
quedarse en MySQL.)

**Dominio:**
- Un dominio propio (`.com`, `.co`) completamente gratis y para siempre, de un registrador serio, prácticamente no existe ya en 2026. Las rutas reales:
  - Usar el subdominio gratuito que da Vercel/Netlify/Cloudflare Pages (`cauce.pages.dev`, por ejemplo) — cero costo, indefinido, y suficiente para una demo o tesis.
  - **DigitalPlat FreeDomain** ofrece dominios propios gratuitos (extensiones menos comunes) pensados justo para proyectos experimentales.
  - **EU.org** da subdominios gratuitos sin fecha de expiración (`cauce.eu.org`), gratis para siempre.
  - Si estás matriculado activamente en la maestría y tu institución es reconocida por GitHub, el **GitHub Student Developer Pack** incluye dominios gratis por un año (`.me`, `.tech`) — vale la pena revisar si aplicas.

**Recomendación concreta para tu caso (MVP/tesis, sin presupuesto) — decisión final:** Netlify para el frontend, Render free para el backend, Supabase para PostgreSQL, y el subdominio que te da el propio Netlify como dominio. Cuando el proyecto pase de demo a algo que la comunidad vaya a usar de verdad, ahí sí vale la pena pagar un dominio `.co` (son baratos, unos pocos dólares al año) y evaluar un plan pago de Supabase si el uso real supera los límites del plan gratuito.

---

## 8. Video del hero

Bancos de video gratuitos y libres de derechos donde buscar metraje de inundaciones/ríos/selva que se ajuste al tono editorial del diseño (evitar clips genéricos de "lluvia cayendo" sin contexto):
- Pexels Videos y Pixabay Videos — ambos con licencia libre de uso comercial, sin atribución obligatoria, buen filtro por palabras clave ("river flood", "tropical rain", "flooded street").
- Videezy — más variado, revisar la licencia de cada clip individual (algunos piden atribución).

Si no aparece metraje específico de Chocó, prioriza clips de selva tropical/ríos caudalosos de Latinoamérica antes que clips genéricos de tormentas en ciudades del hemisferio norte, para mantener la coherencia visual con el contexto real del proyecto.

---

## 9. Plan de construcción por fases

Pensado para ejecutarse en Claude Code, fase por fase, verificando con build/tests antes de avanzar a la siguiente.

**Fase 0 — Configuración base**
- Crear la carpeta del proyecto directamente en el escritorio.
- Dentro de esa carpeta, crear la estructura de carpetas del monorepo (sección 6).
- Inicializar Angular (con Tailwind) en `frontend/`.
- Inicializar FastAPI en `backend/`, con `.env.example` y conexión a MySQL de prueba.
- `.gitignore` cubriendo `.env`, `node_modules`, `__pycache__`, artefactos de build.

**Fase 1 — Base de datos**
- Ejecutar el esquema de la sección 4 contra PostgreSQL (local o Supabase).
- Poblar `municipios` y `cuencas` con los seis municipios del MVP (geometrías reales, no las formas ilustrativas del mockup).
- Cargar datos históricos disponibles de IDEAM/SGC en `mediciones` y `eventos_historicos`.

**Fase 2 — Backend / API**
- Endpoints: `GET /municipios`, `GET /municipios/{id}/riesgo`, `GET /municipios/{id}/historico`, `GET /alertas/activas`.
- Autenticación JWT para rutas de entidad/admin.
- Tarea programada de ingestión (aunque sea simulada al inicio si la API de IDEAM tiene fricción de acceso).

**Fase 3 — Modelo de riesgo**
- Entrenar un primer modelo (random forest o XGBoost) con las variables de lluvia acumulada y nivel de río contra los eventos históricos.
- Exponerlo como función que el backend llama para poblar `predicciones_riesgo`.
- Validar contra eventos históricos reales (backtesting) antes de confiar en el output.

**Fase 4 — Frontend**
- Construir los componentes definidos en la sección 2, replicando los tokens de diseño del mockup (`cauce-mockup.html` como referencia visual exacta).
- Conectar el mapa y el panel lateral a la API real en vez de datos hardcodeados.
- Configurar como PWA para tolerar conexión débil.

**Fase 5 — Despliegue**
- Desplegar frontend en Netlify, backend en Render, base de datos en Supabase (ver sección 7 y `docs/despliegue.md`).
- Configurar variables de entorno de producción.
- Probar el flujo completo de punta a punta con el dominio/subdominio elegido.

**Fase 6 — Iteración**
- Agregar sequía como tercer fenómeno (reutiliza la mayoría del pipeline).
- Notificaciones push/email cuando el riesgo suba de nivel.
- Ampliar a más municipios del Chocó.
