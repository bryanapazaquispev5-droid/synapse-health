# Synapse Health 🩺
### Plataforma Móvil de Alto Rendimiento y Gamificación Médica

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Android](https://img.shields.io/badge/Android-API%2036%20Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![OWASP MASVS](https://img.shields.io/badge/Security-OWASP%20MASVS-007AFF?style=for-the-badge&logo=shield&logoColor=white)](https://mas.owasp.org/)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--Sliced%20Design-5856D6?style=for-the-badge)](https://feature-sliced.design)

---

## 📑 Tabla de Contenidos
- [1. Descripción General](#1-descripción-general)
- [2. Filosofía de Diseño & Ergonomía (One UI & Apple HIG)](#2-filosofía-de-diseño--ergonomía-one-ui--apple-hig)
- [3. Sistema de Diseño (Design System)](#3-sistema-de-diseño-design-system)
  - [3.1 Paleta de Color y Tokens Visuales](#31-paleta-de-color-y-tokens-visuales)
  - [3.2 Tipografía y Espaciado](#32-tipografía-y-espaciado)
- [4. Funcionalidades Principales](#4-funcionalidades-principales)
  - [4.1 Autenticación & Seguridad Anti-Bots](#41-autenticación--seguridad-anti-bots)
  - [4.2 Biblioteca de Fichas Médicas (Cheatsheets)](#42-biblioteca-de-fichas-médicas-cheatsheets)
  - [4.3 Simuladores Clínicos y Gamificación (Quizzes)](#43-simuladores-clínicos-y-gamificación-quizzes)
  - [4.4 Perfil Médico y Seguimiento de Estudio](#44-perfil-médico-y-seguimiento-de-estudio)
- [5. Arquitectura de Software (Feature-Sliced Design)](#5-arquitectura-de-software-feature-sliced-design)
  - [5.1 Estructura del Código](#51-estructura-del-código)
  - [5.2 Principio Anti-God-File y Descomposición Atómica](#52-principio-anti-god-file-y-descomposición-atómica)
- [6. Seguridad Industrial & Cero Persistencia (OWASP)](#6-seguridad-industrial--cero-persistencia-owasp)
- [7. Esquema de Base de Datos (Cloud Firestore)](#7-esquema-de-base-de-datos-cloud-firestore)
- [8. Requisitos y Guía de Instalación](#8-requisitos-y-guía-de-instalación)

---

## 1. Descripción General

**Synapse Health** es una aplicación móvil nativa desarrollada en Flutter orientada a estudiantes y profesionales de ciencias de la salud (*Medicina Humana, Enfermería, Odontología, Obstetricia y Tecnología Médica*). 

La plataforma fusiona una biblioteca médica de alto rendimiento estructurada a partir de literatura anatómica canónica (*Rouvière, Latarjet, Netter*) con un motor de evaluación gamificado que incluye casos clínicos, minijuegos de emparejamiento topográfico y ordenamiento de secuencias funcionales.

---

## 2. Filosofía de Diseño & Ergonomía (One UI & Apple HIG)

Inspirado en la ergonomía de **Samsung One UI** y las guías de interfaz humana de **Apple (HIG)**, Synapse Health implementa la **Regla de los 2 Toques** orientada al uso fluido con una sola mano:

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│               ZONA DE VISUALIZACIÓN                    │
│                        (70%)                           │
│  - Large Titles nativos y cabeceras dinámicas          │
│  - Lectura de casos clínicos y fichas médicas          │
│  - Tarjetas de mnemotecnias y puntos clave             │
│                                                        │
├────────────────────────────────────────────────────────┤
│                                                        │
│               ZONA DE CONTROL ERGONÓMICA               │
│                        (30%)                           │
│  - Píldora Flotante Inferior (BottomFloatingPill)      │
│  - Botones de acción primaria al alcance del pulgar    │
│  - Modales Cupertino Action Sheets inferiores          │
│                                                        │
└────────────────────────────────────────────────────────┘
```

* **Cero Esfuerzo Digital:** Elimina la necesidad de estirar el pulgar hacia las esquinas superiores de la pantalla.
* **Transiciones Hápticas:** Integración de vibraciones sutiles (`HapticFeedback.selectionClick` y `lightImpact`) en botones, modales e interacciones de quizzes.

---

## 3. Sistema de Diseño (Design System)

### 3.1 Paleta de Color y Tokens Visuales

El sistema de tokens de color está centralizado en [`AppColors`](file:///lib/core/theme/app_theme.dart), optimizado para una lectura clínica descansada y de alto contraste:

| Token | Código HEX | Muestra | Propósito y Aplicación |
| :--- | :---: | :---: | :--- |
| `primary` | `#0F172A` | `■` | Títulos principales, texto de alta jerarquía y énfasis (Slate 900). |
| `background` | `#F8FAFC` | `■` | Fondo global de la aplicación, descansado y de baja fatiga visual (Slate 50). |
| `surface` | `#FFFFFF` | `■` | Superficie de tarjetas médicas, campos de entrada y contenedores. |
| `accent` | `#4F8EE6` | `■` | Azul médico para botones primarios, selecciones activas e indicadores. |
| `accentDark` | `#3365A6` | `■` | Estados presionados y bordes destacados. |
| `success` | `#34C759` | `■` | Respuestas correctas en quizzes, verificaciones e insignias activas. |
| `destructive` | `#FF3B30` | `■` | Respuestas incorrectas, alertas de bloqueo y acciones de cierre de sesión. |
| `warning` | `#FF9500` | `■` | Indicadores de advertencia, mnemotecnias y alertas temporales. |
| `border` | `#E2E8F0` | `■` | Delimitadores sutiles de contenedores y divisores (Slate 200). |
| `textMuted` | `#64748B` | `■` | Subtítulos, metadatos, fuentes de libros y descripciones secundarias. |

### 3.2 Tipografía y Espaciado

* **Familia Tipográfica:** Inter / San Francisco Pro (con tipografía nativa del sistema según plataforma).
* **Radios de Curvatura:** `12px` (etiquetas), `16px` (tarjetas), `24px` (modales y hojas inferiores), `999px` (píldoras flotantes).
* **Sombras Suaves:** Elevaciones de luz ambiental `Color(0x06000000)` con radio de desenfoque de 10px a 18px.

---

## 4. Funcionalidades Principales

### 4.1 Autenticación & Seguridad Anti-Bots

* **Multi-Proveedor:** Soporte para inicio de sesión por Correo/Contraseña, Google OAuth nativo y Acceso como Invitado médico temporal.
* **Hoja de Cuentas Google (Cupertino):** Detección interactiva de cuentas configuradas en el dispositivo (`CupertinoGoogleAccountSheet`).
* **Protección Anti-Bot (reCAPTCHA Grid Challenge):** Desafío interactivo de verificación visual de 9 cuadrículas generado dinámicamente si el dispositivo registra múltiples cuentas consecutivas.
* **Defensa Brute-Force (Lockout Exponencial):** Temporizador de bloqueo incremental ante intentos fallidos consecutivos de inicio de sesión gestionado por `AuthLockoutManager`.
* **Indicador de Fortaleza de Contraseña:** Análisis en vivo de entropía de contraseñas (`Weak`, `Medium`, `Strong`, `Secure`).

### 4.2 Biblioteca de Fichas Médicas (Cheatsheets)

* **Estructura Jerárquica:** Organizada en 4 Tomos Anatómicos de referencia médica (Rouvière / Latarjet):
  - *Tomo 1:* Cabeza y Cuello (Osteología, Miología, Vascularización e Inervación).
  - *Tomo 2:* Tronco y Tórax (Columna, Caja torácica, Mediastino, Corazón y Pulmones).
  - *Tomo 3:* Miembro Superior (Hombro, Brazo, Antebrazo, Mano y Plexo Braquial).
  - *Tomo 4:* Miembro Inferior, Abdomen y Pelvis.
* **Tarjetas de Puntos Clave (`KeyPoints`):** Resúmenes de alto rendimiento para repaso rápido antes de rondas clínicas o exámenes.
* **Mnemotecnias Clínicas (`Mnemonics`):** Reglas nemotécnicas estandarizadas para memorización de pares craneales, orificios de la base del cráneo y ramas arteriales.
* **Renderizado Markdown:** Formateo tipográfico enriquecido con soporte para tablas, listas y jerarquías médicas.

### 4.3 Simuladores Clínicos y Gamificación (Quizzes)

* **Modalidades de Evaluación:**
  1. **Opción Múltiple (Multiple Choice):** 4-5 alternativas con fundamentación fisiopatológica inmediata.
  2. **Emparejamiento Topográfico (Matching Pairs):** Conexión interactiva de dos columnas (órgano-función, estructura-inervación) con código de colores iOS.
  3. **Ordenamiento Secuencial (Ordering):** Reordenamiento arrastrable de secuencias biológicas (ej. *Trayecto de la vía piramidal*, *Circulación coronaria*).
* **Examen General vs. Exámenes por Tema:** Capacidad de rendir bancos de preguntas por especialidad o simulacros combinados de toda el área.
* **Retroalimentación Formativa:** Rationale clínico detallado tras cada respuesta indicando por qué la opción es correcta o incorrecta.

### 4.4 Perfil Médico y Seguimiento de Estudio

* **Gestión de Carrera:** Selector dinámico de disciplina médica (*Medicina Humana, Enfermería, Odontología, Farmacia, Obstetricia, Fisioterapia*).
* **Racha de Estudio (`Study Streak`):** Contador de días consecutivos de actividad clínica.
* **Personalización de Avatar:** Soporte para fotografías y avatares médicos nativos.

---

## 5. Arquitectura de Software (Feature-Sliced Design)

Synapse Health sigue una arquitectura **Feature-Sliced Design (FSD)** estricta combinada con **Unidirectional Data Flow (UDF)**:

### 5.1 Estructura del Código

```text
lib/
├── core/                                   # Capa compartida (Cross-Cutting)
│   ├── constants/                          # Constantes globales y nombres de colecciones
│   │   └── app_constants.dart
│   ├── services/                           # Servicios de infraestructura
│   │   ├── connectivity_service.dart       # Monitoreo de conectividad a internet
│   │   └── user_local_profile_service.dart # Almacenamiento seguro de perfil
│   ├── theme/                              # Tokens visuales y colores
│   │   └── app_theme.dart
│   └── widgets/                            # Widgets globales reutilizables
│       ├── bottom_floating_pill.dart       # Barra de navegación flotante One UI
│       └── bottom_pill_item.dart
│
├── features/                               # Capa de funcionalidades aisladas (FSD)
│   ├── auth_login/                         # Módulo de Autenticación & Registro
│   │   ├── api/                            # Servicios de red y Firebase Auth
│   │   │   ├── auth_service.dart
│   │   │   ├── auth_lockout_manager.dart
│   │   │   └── auth_oauth_helper.dart
│   │   ├── model/                          # Controladores y modelos de captcha
│   │   │   ├── auth_flow_handler.dart
│   │   │   ├── captcha_models.dart
│   │   │   └── captcha_challenges_data.dart
│   │   ├── ui/                             # Pantallas ensambladoras
│   │   │   ├── auth_screen.dart
│   │   │   ├── complete_profile_screen.dart
│   │   │   ├── welcome_screen.dart
│   │   │   └── widgets/                    # 19 sub-widgets atómicos
│   │   └── utils/                          # Validadores y helpers de UI
│   │       ├── auth_validators.dart
│   │       └── auth_snackbar_helper.dart
│   │
│   ├── cheatsheets/                        # Módulo de Fichas Médicas
│   │   ├── api/                            # Consultas a Firestore (MedicalAreasService)
│   │   ├── model/                          # Modelos inmutables (Area, Topic, Cheatsheet)
│   │   └── ui/                             # Pantallas (Áreas, Temas, Detalle) y sub-widgets
│   │
│   ├── quizzes/                            # Módulo de Quizzes & Gamificación
│   │   ├── api/                            # Consultas y carga de exámenes (QuizService)
│   │   ├── model/                          # Modelos (QuizModel, MatchingPair)
│   │   ├── ui/                             # Vistas de sesión, resultados y áreas
│   │   │   └── widgets/                    # Widgets interactivos de matching/ordering
│   │   └── utils/                          # Lógica de cálculo y helpers
│   │       ├── matching_state_helper.dart
│   │       └── quiz_fallback_parser.dart
│   │
│   ├── user_profile/                       # Módulo de Perfil del Usuario
│   │   ├── api/                            # Sincronización en la nube (ProfileApiService)
│   │   └── ui/                             # Pantalla de perfil y sheets de edición
│   │
│   └── navigation/                         # Shell y Router de la aplicación
│       └── ui/
│           ├── main_navigation_wrapper.dart
│           └── widgets/
│
└── main.dart                               # Punto de entrada y bootstrap de Firebase
```

### 5.2 Principio Anti-God-File y Descomposición Atómica

* **Límite Estricto de Archivo:** Ningún archivo de código supera las **250 líneas**.
* **Pantallas Ensambladoras:** Las pantallas (`ui/*_screen.dart`) se limitan a orquestar el layout (~80-160 líneas), delegando la presentación a componentes atómicos en `widgets/` y la lógica de negocio a controladores en `api/` o `model/`.

---

## 6. Seguridad Industrial & Cero Persistencia (OWASP)

Synapse Health cumple con las directivas de seguridad de **OWASP Mobile Application Security (MASVS)**:

1. **Cero Persistencia de Contenido Clínico en Disco:**
   - Firestore opera con `persistenceEnabled: false`. La literatura médica y los exámenes residen **únicamente en memoria RAM** mientras la aplicación está activa, previniendo el volcado o extracción de propiedad intelectual médica.
2. **Desalojo Reactivo por Desconexión (`ConnectivityService`):**
   - Si se interrumpe el acceso a internet, el contenido clínico se desmonta inmediatamente de la pantalla y la memoria, mostrando un estado nativo de reconexión.
3. **Almacenamiento Cifrado en Hardware:**
   - La sesión del usuario y credenciales se guardan mediante `flutter_secure_storage` respaldado por **Android Keystore / EncryptedSharedPreferences** en Android y **Apple Keychain** en iOS.
4. **Ofuscación y Reducción R8 / ProGuard:**
   - Compilación en modo Release configurada con `minifyEnabled true` y `shrinkResources true` en Android para prevenir ingeniería inversa del bytecode.

---

## 7. Esquema de Base de Datos (Cloud Firestore)

```
firestore/
├── users/ {userId}
│   ├── name: string
│   ├── email: string
│   ├── career: string
│   ├── gender: string
│   ├── studyStreakDays: number
│   └── createdAt: timestamp
│
└── medical_areas/ {areaId}
    ├── name: string
    ├── code: string
    ├── order: number
    ├── imageBase64: string
    ├── topicsCount: number
    ├── cheatsheetsCount: number
    │
    ├── topics/ {topicId}
    │   ├── title: string
    │   ├── description: string
    │   ├── order: number
    │   │
    │   └── cheatsheets/ {cheatsheetId}
    │       ├── title: string
    │       ├── summary: string
    │       ├── sourceBook: string
    │       ├── readMinutes: number
    │       ├── keyPoints: string[]
    │       ├── mnemonics: string[]
    │       └── contentMarkdown: string
    │
    └── quizzes/ {quizId}
        ├── type: "multiple_choice" | "matching" | "ordering"
        ├── question: string
        ├── options: string[]
        ├── correctIndex: number
        ├── matchingPairs: [{left: string, right: string}]
        ├── orderingSequence: string[]
        ├── rationale: string
        ├── sourceBook: string
        └── topicId: string
```

---

## 8. Requisitos y Guía de Instalación

### Requisitos Previos
* **Flutter SDK:** `>= 3.19.0`
* **Dart SDK:** `>= 3.3.0`
* **Android Studio / Xcode** con Android SDK API 34+
* **Dispositivo Físico o Emulador**

### Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/bryanapazaquispev5-droid/synapse-health.git
   cd synapse_health
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar verificación de análisis estático:**
   ```bash
   flutter analyze
   ```

4. **Compilar y ejecutar en tu dispositivo:**
   ```bash
   flutter run
   ```

---

<div align="center">
  <sub>Desarrollado con dedicación para la comunidad médica y estudiantes de ciencias de la salud.</sub>
</div>