---
name: atomic-architecture
description: >-
  Universal Feature-Sliced Design (FSD), Unidirectional Data Flow (UDF), and Atomic Decomposition protocol for all project types (Mobile, Web, Backend, Desktop). Enforces a strict 200-250 line limit per file, decomposes monolithic 'God Files', separates UI into atomic widgets, and isolates state into immutable controllers.
---

# Universal Atomic Architecture & Anti-Monolith Protocol (FSD + UDF)

Basado en los estándares de [feature-sliced/documentation](https://github.com/feature-sliced/documentation), [android/nowinandroid](https://github.com/android/nowinandroid) y [felangel/bloc](https://github.com/felangel/bloc), este skill sustituye a MVVM clásico por una arquitectura modular superior y elimina para siempre los archivos monolíticos gigantes.

---

## 1. Regla Inviolable de Tamaño de Archivo (Límite 200 - 250 Líneas)

* **Prohibido el antipatrón "God File":** Ningún archivo de código debe superar las **250 líneas**. Si un archivo se acerca a 200 líneas, debe descomponerse obligatoriamente.
* **El archivo Screen/Page es solo un ensamblador:** Una pantalla principal solo debe contener ~80-120 líneas estructurando los bloques visuales, nunca implementando formularios o tarjetas gigantes en el mismo archivo.

---

## 2. La Regla de las 3 Extracciones Atómicas (FSD)

Cuando un archivo crece, se descompone automáticamente en capas FSD:

```text
features/[modulo]/
├── ui/                     → VISTA (Max 100-150 líneas)
│   ├── [feature]_screen.dart/tsx  (Solo ensambla los widgets hijos)
│   └── widgets/            → SUB-COMPONENTES ATÓMICOS (Cada uno en su archivo separado)
│       ├── auth_header_widget.dart
│       ├── login_form_widget.dart
│       └── social_auth_buttons_widget.dart
├── model/ (o state/)       → UDF / CONTROLADOR (Lógica aislada)
│   ├── [feature]_controller.dart  (Maneja eventos, llamadas y validaciones)
│   └── [feature]_state.dart       (Estado único e inmutable: UiState)
├── api/ (o data/)          → ACCESO A DATOS (Servicios y repositorios)
│   └── [feature]_api_service.dart
└── lib/ (o utils/)         → HELPERS PUROS Y VALIDADORES
    └── [feature]_validators.dart
```

---

## 3. Flujo Unidireccional de Datos (UDF / MVI) Superior a MVVM

En lugar de variables sueltas (`isLoading`, `error`, `data`) que se desincronizan:

1. **Estado Único Inmutable (`UiState`):** La pantalla solo escucha un único objeto de estado consolidado.
2. **Eventos Explícitos (`UiEvent`):** La pantalla solo emite intenciones (ej: `SubmitLogin(email, pass)`).
3. **Controlador Puro:** El controlador recibe el evento, ejecuta la lógica y emite un nuevo `UiState` inmutable.

---

## 4. Matriz de Descomposición por Tipo de Proyecto

| Tipo de Proyecto | Capa UI (Max 150 lns) | Capa Lógica / Estado | Capa Datos / Servicios |
| :--- | :--- | :--- | :--- |
| 📱 **Flutter / Dart** | `widgets/` (StatelessWidgets atómicos) | `cubit/` / `bloc/` / `notifier/` | `repositories/` / `datasources/` |
| 🌐 **React / Next.js** | `components/` (Componentes atómicos) | `hooks/use[Feature].ts` | `api/` (TanStack Query / Axios) |
| ⚙️ **Backend (Node / Python)**| `routes/` (Solo mapea URLs) | `services/` (Lógica de negocio pura) | `repositories/` / `models/` |
