# Synapse Health

Aplicación móvil Flutter para estudiar contenidos de ciencias de la salud mediante áreas médicas, temas, notas de estudio, quizzes y seguimiento personal.

## Estado y alcance

- La app usa Amazon Cognito para registro, inicio de sesión y sesiones de usuario.
- Los datos de catálogo y usuario se consultan mediante una API en Amazon API Gateway y AWS Lambda.
- Amazon DynamoDB almacena las áreas, temas, quizzes, notas de estudio, perfiles, progreso, ranking y límites de solicitudes.
- La autenticación social con Google y las notificaciones push remotas no forman parte de la app actual. Las notificaciones locales se generan en el dispositivo.
- `AppTable` y `user-devices` son recursos antiguos retenidos en AWS. El runtime actual no los usa ni elimina sus datos.
- La app y los recursos AWS no se despliegan al ejecutar los comandos locales de este README.

## Funciones de la app

- Registro e inicio de sesión con correo y contraseña, recuperación de contraseña y verificación de correo desde el perfil.
- Catálogo de áreas médicas, temas, notas de estudio y preguntas de quizzes.
- Evaluaciones de opción múltiple, emparejamiento y ordenamiento cuando esos tipos están presentes en el contenido.
- Guardado de respuestas y progreso, historial académico, perfil, ranking y preferencias locales.
- Selección de carrera desde las opciones disponibles en el formulario.

## Arquitectura

```text
Flutter app
  ├── Amazon Cognito: identidad y tokens
  └── HTTPS API
        └── API Gateway HTTP API
              └── AWS Lambda (Node.js)
                    ├── DynamoDB: catálogo y datos de usuario
                    └── CloudWatch: logs operativos
```

El código móvil se organiza bajo `lib/core/` y `lib/features/`. El backend AWS que consume la app está en `backend/src/aws/`; la infraestructura como código se define en `backend/infra/`

## API disponible

Las rutas de salud son públicas. Las demás rutas requieren un token de acceso válido de Cognito.

| Método | Ruta | Uso |
| --- | --- | --- |
| `GET` | `/health`, `/api/v1/health` | Estado de la API |
| `GET` | `/api/v1/auth/session` | Identidad autenticada |
| `GET`, `PUT`, `PATCH` | `/v1/me/profile` | Consultar y actualizar el perfil propio |
| `GET` | `/api/v1/areas` | Listar áreas médicas |
| `GET` | `/api/v1/areas/{areaId}/topics` | Listar temas de un área |
| `GET` | `/api/v1/areas/{areaId}/quizzes` | Consultar quizzes de un área |
| `GET` | `/api/v1/areas/{areaId}/topics/{topicId}/quizzes` | Consultar quizzes de un tema |
| `GET` | `/api/v1/areas/{areaId}/topics/{topicId}/study-notes` | Consultar notas de estudio |
| `GET` | `/api/v1/progress/me` | Consultar progreso propio |
| `POST` | `/api/v1/progress/{topicId}/answer` | Guardar una respuesta |
| `POST` | `/api/v1/progress/{topicId}/retry` | Reiniciar un intento |
| `GET` | `/api/v1/history`, `/api/v1/history/{id}` | Consultar historial propio |
| `GET` | `/api/v1/leaderboard` | Consultar ranking |

Los métodos, validaciones y formatos de las respuestas están documentados en [`backend/AWS.md`](backend/AWS.md).

## Tablas DynamoDB

| Tabla | Información principal |
| --- | --- |
| `medical-areas` | Áreas médicas |
| `topics` | Temas asociados a un área |
| `quizzes` | Preguntas, alternativas y respuestas |
| `study-notes` | Notas de estudio por tema |
| `user-profiles` | Perfil vinculado al identificador `sub` de Cognito |
| `user-progress` | Intentos y respuestas del usuario por tema |
| `leaderboard` | Resultado de ranking calculado por el backend |
| `rate-limits` | Contadores temporales de solicitudes |

Las relaciones y claves se detallan en `backend/AWS.md`. La tabla heredada `AppTable` se conserva; no se usa como tabla activa de la API.

## Requisitos

- Flutter y Dart compatibles con `pubspec.yaml`.
- Node.js 22 o posterior para el backend.
- AWS CLI configurado con una sesión autorizada para ejecutar el backend AWS.
- Android Studio/Xcode y SDK de plataforma para compilar en un dispositivo o emulador.

## Configuración y ejecución local

### App móvil

La plantilla raíz `.env.example` está en formato JSON para Flutter `--dart-define-from-file`. Sus valores son identificadores públicos de configuración, no credenciales AWS.

```powershell
flutter pub get
Copy-Item .env.example .env
flutter run --dart-define-from-file=.env
```

Para compilar un APK debug:

```powershell
flutter build apk --debug --dart-define-from-file=.env
```

### Backend AWS

```powershell
cd backend
npm ci
npm run build
npm test
```

Para ejecutar la API local con credenciales AWS de la cadena estándar de AWS CLI, configura las variables indicadas en `backend/.env.example` en el entorno del proceso y ejecuta:

```powershell
npm start
```

## Pruebas

- Flutter: `flutter test` ejecuta la suite móvil.
- Backend: `npm test` ejecuta la compilación de verificación y las pruebas Node.js.
- Pruebas de carga: los scripts de `test/load/` usan k6. La prueba de login envía solicitudes a Cognito con credenciales ficticias; la de registro crea cuentas persistentes y no las elimina. Revisa sus variables y el impacto antes de confirmar una ejecución real.

Las pruebas locales no demuestran por sí solas el estado de una implementación AWS ni reemplazan una prueba controlada contra el entorno desplegado.

## Infraestructura, seguridad y costos

La plantilla CloudFormation de `backend/infra/` define API Gateway, Lambda, Cognito, DynamoDB y CloudWatch. Consulta [`backend/AWS.md`](backend/AWS.md) antes de desplegar: incluye permisos, configuración, costes/riesgos y pasos de migración del catálogo. Los despliegues pueden generar cargos; verifica plan, créditos, región y cambios de CloudFormation antes de ejecutarlos.

La app no contiene claves de acceso AWS. Lambda obtiene permisos mediante su rol de ejecución; el cliente móvil usa Cognito y HTTPS. No guardes contraseñas, tokens ni datos reales de salud en el repositorio, capturas o fixtures.

## Documentación

- [`backend/AWS.md`](backend/AWS.md): arquitectura AWS, endpoints, esquema DynamoDB, permisos, costes y despliegue.
- [`docs/Synapse_Health_Project_Documentation.docx`](docs/Synapse_Health_Project_Documentation.docx): documentación de la aplicación y su arquitectura.
