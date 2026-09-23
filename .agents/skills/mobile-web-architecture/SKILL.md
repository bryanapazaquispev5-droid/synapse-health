---
name: mobile-web-architecture
description: >-
  Master architecture, clean code standards, UI/UX zero redundancy, and OWASP security guidelines for web and mobile applications (React, Next.js, Vue, Flutter, Android, iOS, React Native, Node.js, Express, Python, Go). Use when starting, structuring, designing, refactoring, securing, or reviewing any frontend, backend, or mobile project.
---

# Manual Maestro de Arquitectura, Estándares de Código, UI/UX y Seguridad

Este skill proporciona directivas obligatorias para estructurar proyectos, escribir código limpio con tipado estricto, garantizar cero redundancia en interfaces/lógica/estado, y aplicar estándares de seguridad industrial (OWASP MASVS, BFF, almacenamiento seguro).

---

## 1. Repositorios Campeones (#1 por Categoría)

| Categoría | Repositorio Campeón (#1) | Enfoque Principal |
| :--- | :--- | :--- |
| 👑 **Universal / Clean Code** | [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) | Nombres con intención, funciones atómicas, early returns |
| 🛡️ **Seguridad Móvil y APIs** | [owasp-masvs](https://github.com/OWASP/owasp-masvs) | Estándar oficial de verificación y seguridad móvil |
| 🌐 **Frontend Web** | [bulletproof-react](https://github.com/alan2207/bulletproof-react) | Arquitectura *Feature-First*, separación de UI y Lógica |
| ⚙️ **Backend & APIs** | [nodebestpractices](https://github.com/goldbergyoni/nodebestpractices) | Arquitectura 3 capas, manejo centralizado de errores |
| 📱 **Apps Móviles** | [android/architecture-samples](https://github.com/android/architecture-samples) | Patrón MVVM oficial de Google (Data, Domain, Presentation) |

---

## 2. Arquitectura de Carpetas por Plataforma

### 2.1 Frontend Web (Feature-First / Modular)
```text
src/
├── app/                  # Rutas, páginas y proveedores globales
├── assets/               # Imágenes, fuentes e íconos estáticos globales
├── components/           # Componentes UI genéricos reutilizables (Botones, Modales, Inputs)
├── config/               # Variables de entorno y configuraciones globales
├── hooks/                # Custom hooks globales y transversales
├── lib/                  # Inicialización de librerías externas (Axios, Firebase, etc.)
├── features/             # Módulos de funcionalidad independientes
│   ├── auth/             # Módulo de Autenticación
│   │   ├── api/          # Llamadas a API específicas de auth
│   │   ├── components/   # Formularios de login, registro, etc.
│   │   ├── hooks/        # Hooks de autenticación (useAuth, useSession)
│   │   ├── types/        # Interfaces y tipos TypeScript de auth
│   │   └── utils/        # Validadores y helpers de auth
│   ├── dashboard/        # Módulo de Dashboard
│   └── products/         # Módulo de Productos
├── services/             # Clientes de API compartidos
├── stores/               # Estado global (Zustand, Redux, Pinia)
├── types/                # Tipos e interfaces globales compartidos
└── utils/                # Funciones utilitarias globales (fechas, formateadores)
```

### 2.2 Backend & APIs (3 Capas / Clean Architecture)
```text
src/
├── config/               # Variables de entorno, conexiones a Base de Datos
├── controllers/          # Manejadores de peticiones HTTP (req, res)
├── middlewares/          # Autenticación, validación de datos, manejo de errores
├── models/               # Esquemas/Entidades de Base de Datos (ORM/ODM)
├── routes/               # Definición de rutas y endpoints REST
├── services/             # LÓGICA DE NEGOCIO pura (reglas, cálculos)
├── repositories/         # Capa de acceso a datos (queries SQL / NoSQL)
├── utils/                # Helpers, encriptación, validadores
└── server.ts             # Punto de entrada de la aplicación
```

### 2.3 Aplicaciones Móviles (MVVM + Clean Architecture)
```text
lib/ (o src/)
├── core/                 # Elementos transversales
│   ├── constants/        # Constantes globales, rutas
│   ├── network/          # Cliente HTTP (Dio, Retrofit), interceptores, SSL Pinning
│   ├── errors/           # Excepciones y fallos personalizados
│   └── theme/            # Colores, tipografía y estilos
└── features/             # Módulos por funcionalidad
    ├── authentication/
    │   ├── data/         # Modelos DTO, DataSources (local/remoto), Repositorios
    │   ├── domain/       # Entidades puras, Casos de uso (Use Cases), Interfaces
    │   └── presentation/ # Pantallas (Views), Widgets, ViewModels (Bloc/Cubit/Notifier)
    └── home/
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 3. Estándares de Variables y Tipos de Datos

* **Regla de Oro:** El nombre debe describir **qué contiene** y su **intención**, sin prefijos de tipos técnicos (prohibida notación húngara como `strName` o `intEdad`).
* **Variables de Texto (`string`):** Nombres en singular y sustantivos contextuales (`userName`, `userEmail`, `errorMessage`).
* **Variables Numéricas:** Deben incluir la unidad de medida o indicar conteo (`priceInUsd`, `timeoutMs`, `retryCount`, `totalItems`).
* **Variables de Fecha y Tiempo:** Sufijos temporales obligatorios (`createdAt`, `expiresAt`, `birthDate`, `sessionDurationInMinutes`).
* **Variables Booleanas:** SIEMPRE con prefijos afirmativos (`isActive`, `hasAdminPermission`, `canEditDocument`, `shouldSendNotification`). Prohibido nombres negativos como `isNotValid`.
* **Colecciones y Listas:** Nombres en PLURAL sin añadir sufijos redundantes (`users`, `pendingOrders`, `selectedCategoryIds`).
* **Constantes y Enums:** Constantes inmutables en `UPPER_SNAKE_CASE`. Enums con nombres en `PascalCase` y miembros en `UPPER_SNAKE_CASE`.

---

## 4. Estándares de Funciones y Métodos

* **Fórmula:** `[VERBO] + [SUSTANTIVO / CONTEXTO]` (ej: `sendWelcomeEmail()`, `fetchPatientMedicalHistory()`).
* **Prefijos Estándar:**
  * `get...` / `fetch...` $\rightarrow$ Lectura de datos.
  * `set...` / `update...` $\rightarrow$ Modificación de estado.
  * `is...` / `has...` / `can...` $\rightarrow$ Retorno booleano (predicado).
  * `validate...` $\rightarrow$ Validación y verificación de reglas.
  * `format...` / `convert...` $\rightarrow$ Transformación de tipos de datos.
  * `handle...` / `on...` $\rightarrow$ Manejadores de eventos de usuario o sistema.
  * `create...` / `build...` $\rightarrow$ Creación/instanciación de entidades u objetos.
* **Buenas Prácticas:** Tipado estricto en parámetros y retorno, máximo 2-3 parámetros posicionales (si son más, usar DTO/Objeto), funciones atómicas (< 30 líneas) y retorno temprano (*early return*).

---

## 5. Directiva Integral Cero Redundancia (DRY Universal)

1. **Redundancia Visual (UI Clutter):**
   * Prohibido duplicar títulos: Si el Navbar ya muestra el título de la pantalla, no repetirlo en el cuerpo con `<h1>`.
   * Regla de Acción Primaria: Un único botón principal destacado por vista.
2. **Redundancia en Lógica de Negocio:**
   * Extraer cualquier lógica compartida en 2+ lugares a `utils/` o `shared/`.
   * Parametrizar funciones en vez de clonar código casi idéntico.
3. **Redundancia de Estado y Datos:**
   * *Single Source of Truth*: No duplicar datos del Store Global en estados locales (`useState`).
   * **Prohibido almacenar estados derivados:** Valores calculables al vuelo (como conteos, sumas o filtros) deben calcularse como constantes derivadas, nunca como estado adicional.
4. **Redundancia en Red:**
   * Deduplicar peticiones mediante caché (React Query, SWR, Dio Cache).
   * Diseñar un único endpoint canónico por recurso en backend (`GET /api/v1/users/:id`).

---

## 6. Seguridad en Aplicaciones Móviles y Web (Estándar OWASP)

1. **Almacenamiento Seguro (OWASP MASVS):**
   * **NUNCA** guardar tokens, contraseñas o datos personales (PII) en texto plano (`SharedPreferences`, `UserDefaults` o `LocalStorage`).
   * Utilizar **iOS Keychain Services**, **Android Keystore / EncryptedSharedPreferences**, `flutter_secure_storage` o `react-native-keychain`.
2. **Comunicaciones Seguras:**
   * HTTPS obligatorio (TLS 1.2+). Bloquear tráfico en texto claro (`clearTextTrafficPermitted="false"`).
   * Implementar **Certificate Pinning** en apps bancarias, médicas o de alta criticidad.
3. **Manejo Seguro de API Keys (Arquitectura BFF):**
   * **NUNCA** incrustar credenciales secretas de backend (`STRIPE_SECRET_KEY`, credenciales privadas de Firebase/BD) en el cliente móvil o web.
   * La app solo se comunica con su propio backend autenticado, y el backend gestiona las llaves privadas de terceros.
4. **Anti-Ingeniería Inversa y Detección de Integridad:**
   * Activar ofuscación (`minifyEnabled true`, `shrinkResources true` en Android R8/ProGuard).
   * Verificar integridad del dispositivo (detección de Root/Jailbreak) en operaciones sensibles.
   * Proteger pantallas en segundo plano (`FLAG_SECURE` en Android).
