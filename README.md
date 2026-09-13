# Synapse Health 🩺

> Plataforma móvil de estudio ágil y de alto rendimiento clínico orientada a estudiantes de ciencias de la salud (Medicina Humana, Enfermería, Odontología, Obstetricia, etc.).

---

## 📱 Filosofía de Diseño: One UI Reachability & Apple HIG

Inspirado en los principios de diseño ergonómico de **Samsung One UI** y **Apple Human Interface Guidelines (HIG)** para garantizar el uso con una sola mano mediante la **Regla de los 2 Toques**:

1. **Zona Superior (70% de la pantalla)**: Zona de visualización, lectura de casos clínicos, Large Titles nativos y tarjetas médicas de alto rendimiento.
2. **Zona Inferior (30% de la pantalla)**: Zona de control ergonómica al alcance del pulgar mediante **Píldoras Flotantes** (`BottomFloatingPill`), eliminando la necesidad de estirar los dedos hacia la parte superior.
3. **Paleta de Color Minimalista (Tokens de Sistema)**:
   - **Fondo / Superficie**: `#F8FAFC` y `#FFFFFF` (Lienzo descansado de alta legibilidad).
   - **Texto Primario**: `#0F172A` (Grafito pizarra de alto contraste).
   - **Acento Clínico**: `#4F8EE6` (Azul médico para estados activos y confirmaciones).

---

## 🔒 Arquitectura de Seguridad: Cero Persistencia Médica Local

Para garantizar la protección de la propiedad intelectual médica y prevenir ingeniería inversa:

* **100% en la Nube en Tiempo Real**: Ni temas, ni chuletas, ni listas de especialidades, ni logotipos se guardan localmente en el dispositivo.
* **Persistencia en Disco Desactivada**: Configurado con `persistenceEnabled: false` en Firestore; el contenido clínico reside exclusivamente en memoria RAM mientras la aplicación esté activa con conexión a internet.
* **Detección Reactiva de Conectividad (`ConnectivityService`)**:
  - Monitoreo continuo de acceso a internet real mediante consultas DNS.
  - Si se pierde la conexión, el contenido médico desaparece inmediatamente de la pantalla y muestra una vista nativa de reconexión.
  - Al restaurarse la red, la biblioteca médica se vuelve a descargar automáticamente.
* **Caché Exclusivo de Perfil (`UserLocalProfileService`)**:
  - Almacena localmente de forma segura **únicamente** los datos del usuario (Nombre, Correo, Carrera, Género y foto en Base64).
  - Mantiene la sesión activa offline sin requerir volver a registrarse.

---

## 🗂️ Arquitectura Modular (Feature-First)

```text
lib/
├── core/                               <-- Componentes compartidos
│   ├── constants/
│   │   └── app_constants.dart          <-- Constantes, colecciones y llaves
│   ├── services/
│   │   ├── connectivity_service.dart   <-- Monitoreo de internet en tiempo real
│   │   └── user_local_profile_service.dart <-- Almacenamiento local de perfil
│   ├── theme/
│   │   └── app_theme.dart              <-- Tokens visuales y tipografías
│   └── widgets/
│       └── bottom_floating_pill.dart   <-- Píldora de navegación ergonómica
│
├── features/                           <-- Módulos desacoplados
│   ├── auth_login/                     <-- Autenticación, Google Sign-In y reCAPTCHA
│   │   ├── screens/                    (AuthScreen, CompleteProfileScreen, WelcomeScreen)
│   │   └── widgets/                    (AuthTextField, PasswordStrengthBar, RecaptchaCard)
│   ├── cheatsheets/                    <-- Biblioteca de chuletas y especialidades
│   │   ├── models/                     (MedicalAreaModel, TopicModel, CheatsheetModel)
│   │   ├── screens/                    (CheatsheetListScreen, AreaTopicsScreen, etc.)
│   │   └── services/                   (MedicalAreasService)
│   ├── user_profile/                   <-- Perfil del estudiante
│   │   └── screens/                    (ProfileScreen)
│   └── navigation/                     <-- Router principal y shell
│       └── screens/                    (MainNavigationWrapper)
│
└── main.dart                           <-- Punto de entrada y configuración de Firebase
```

---

## 🗄️ Esquema de Datos en Firebase Firestore

### 1. Perfil de Usuario (`users/{userId}`)
```json
{
  "uid": "USER_UID_STRING",
  "name": "Bryan Apaza",
  "email": "estudiante@gmail.com",
  "career": "Medicina Humana",
  "gender": "Hombre",
  "studyStreakDays": 0,
  "authProvider": "google.com",
  "createdAt": "SERVER_TIMESTAMP"
}
```

### 2. Áreas Médicas (`medical_areas/{areaId}`)
```json
{
  "name": "Anatomía Humana",
  "code": "ANATOMIA",
  "order": 1,
  "imageBase64": "DATA_STRING_OR_URL",
  "topicsCount": 12,
  "cheatsheetsCount": 35,
  "isAvailable": true
}
```

### 3. Temas Clínicos (`medical_areas/{areaId}/topics/{topicId}`)
```json
{
  "title": "Hueso Esfenoides",
  "description": "Cuerpo, alas menores, alas mayores y orificios de la base del cráneo.",
  "order": 1,
  "areaId": "anatomia",
  "cheatsheetsCount": 4
}
```

### 4. Chuletas de Alto Rendimiento (`medical_areas/{areaId}/topics/{topicId}/cheatsheets/{cheatsheetId}`)
```json
{
  "title": "Alas Mayores y Orificios de la Base",
  "summary": "Relaciones topográficas y elementos que atraviesan los orificios del esfenoides.",
  "sourceBook": "Rouvière - Anatomía Humana Tomo 1: Cabeza y Cuello (11.ª ed.)",
  "readMinutes": 2,
  "order": 1,
  "keyPoints": [
    "El agujero redondo mayor da paso al nervio maxilar (V2).",
    "El agujero oval transmite el nervio mandibular (V3) y la arteria meníngea accesoria.",
    "El agujero espinoso da paso a la arteria meníngea media."
  ],
  "mnemonics": [
    "ROSE: Redondo mayor (V2) | Óptico (II par) | Sphenoid fissure | Espinoso (A. Meníngea media)"
  ],
  "contentMarkdown": "### Descripción General\nLas alas mayores del hueso esfenoides..."
}
```

---

## 📋 Estándar de Commits (Conventional Commits)

Todos los commits deben redactarse en **inglés** bajo el formato estandarizado:

```text
<type>(<scope>): <short imperative summary>

- <detailed bullet point 1 explaining what was implemented>
- <detailed bullet point 2 explaining what was changed or fixed>
- <detailed bullet point 3 referencing files or modules affected>
```

* **Tipos**: `feat`, `fix`, `refactor`, `style`, `docs`, `chore`.
* **Ámbitos**: `core`, `auth`, `cheatsheets`, `quizzes`, `progress`, `profile`, `settings`.

---

## 🚀 Ejecución del Proyecto

1. Asegurar la instalación de Flutter 3.13+ y Android SDK / Conectar dispositivo físico.
2. Instalar paquetes:
   ```bash
   flutter pub get
   ```
3. Ejecutar análisis estático:
   ```bash
   flutter analyze
   ```
4. Iniciar la aplicación:
   ```bash
   flutter run
   ```