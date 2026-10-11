# Plan maestro de desarrollo — Synapse Health

## Contexto y repositorio
- Repositorio: `bryanapazaquispev5-droid/synapse-health`.
- Cuenta de la desarrolladora: `janelyapazasencia95-sketch`.
- Rama objetivo: `feat/janely-synapse-development`, crear solamente después de verificar permisos y estado local.
- Aplicación Flutter + Firebase. Mantener los flujos actuales de autenticación, fichas, quizzes, ranking y perfil.
- Este plan NO autoriza a implementar todas las fases de una sola vez.

## Reglas obligatorias de ejecución
1. Antes de modificar: inspeccionar el código real, `git status`, rama, remoto, pruebas y dependencias. No sobrescribir cambios locales.
2. Implementar una sola fase por solicitud expresa. Al terminar, detenerse y pedir revisión de la desarrolladora.
3. Usar el diseño actual (`AppTheme`, `AppColors`, tipografía, tarjetas, Floating Pill, Liquid Wave y componentes existentes). No crear una estética genérica de IA ni inventar datos.
4. No romper contratos Firestore ni índices de navegación; cualquier migración exige estrategia documentada.
5. Aplicar separación de responsabilidades, reutilización prudente, validación de entradas, errores explícitos, accesibilidad y estados de carga/vacío/error/offline.
6. Cada fase exige `flutter analyze`, pruebas relevantes y prueba en simulador cuando aplique. Para backend, ejecutar pruebas y verificaciones propias.
7. No publicar secretos, tokens ni credenciales. No desplegar Firestore ni AWS sin autorización. Antes de cambiar reglas Firestore, probar en emulador y verificar permisos por usuario/rol.
8. Autorización vigente de Janely: crear commits convencionales y ejecutar push automáticamente al cerrar cada fase validada, sin pedir aprobación adicional. Usar solo la rama objetivo; no publicar pruebas fallidas ni cambios ajenos sin revisar. Confirmar permisos y verificar SHA remoto.
9. Informar archivos modificados, motivo, pruebas ejecutadas y sus resultados, riesgos pendientes, hash del commit y siguiente paso.

## Fase 0 — Base reproducible y Git
- Revisar cambios locales, confirmar propietario del remoto, permisos y rama.
- Resolver conflictos entre versiones FlutterFire del SDK iOS en conjunto; comprobar `flutter pub get`, `flutter analyze`, `flutter test` y `flutter run` en simulador iOS.
- Registrar línea base de arquitectura, navegación y pruebas.
- Criterio de aceptación: compilación iOS verificable, sin cambios funcionales no relacionados.

## Fase 1 — Seguridad Firestore
- Sustituir `allow read, write: if true` por reglas específicas para contenido, perfiles, progreso, leaderboard y tokens FCM.
- Diseñar permisos de propietario y administración con mínimos privilegios. No confiar en estrellas o puntuaciones calculadas por el cliente.
- Agregar pruebas con Firebase Emulator Suite (accesos permitidos y denegados).
- No desplegar reglas hasta aprobarlas y verificar impacto en flujos actuales.

## Fase 2 — Estados UI reutilizables
- Auditar los estados existentes antes de crear nuevos widgets.
- Unificar loading, empty, error, offline, not found y under development sin confundir fallo de red con ausencia de datos.
- Asegurar reintentos, contraste, accesibilidad y uso consistente de AppTheme.

## Fase 3 — Home / Dashboard
- Diseñar a partir de pantallas y componentes actuales, sin cambiar arbitrariamente la navegación.
- Mostrar solo datos disponibles: nombre, continuación de estudio, accesos a fichas/quizzes, progreso real y actividad reciente cuando existan.
- No inventar estadísticas, rachas, recomendaciones ni contenidos.
- Proponer integración de navegación y obtener aprobación antes de cambiar índices de pestañas.

## Fase 4 — Progreso personal
- Crear pantalla propia separada de leaderboard, usando datos reales de `quiz_topics_progress`.
- Mostrar estadísticas sustentadas por el modelo: estrellas, avance por área/tema, intentos y otros indicadores solo si se pueden calcular correctamente.
- Conservar el ranking como función independiente y mantener compatibilidad con notificaciones.

## Fase 5 — Historial
- Mostrar intentos guardados con fechas y resultados reales, respetando la retención FIFO vigente.
- Evitar afirmar que existe historial global ilimitado si el esquema no lo soporta.
- Incluir estados vacíos y pruebas de serialización.

## Fase 6 — Búsqueda global
- Buscar fichas, áreas, temas y quizzes respetando estructura Firestore y límites de consultas.
- Definir indexación/consulta eficiente; no descargar toda la base indiscriminadamente.
- Estados de búsqueda, sin resultados, error y offline.

## Fase 7 — Favoritos
- Definir el modelo de favoritos por UID y reglas de acceso.
- Añadir guardar/quitar, lista de favoritos y estados vacíos; prevenir duplicados.
- Reutilizar tarjetas y componentes existentes.

## Fase 8 — Integración UI/UX
- Revisar rutas, back navigation, deep links/notificaciones, perfil y ajustes.
- Validar diseño en iOS/Android, diferentes tamaños, teclado, SafeArea, contraste y accesibilidad.
- Conservar la identidad visual actual, no imponer rediseño masivo.

## Fase 9 — Backend REST
- Proponer y justificar una arquitectura mínima compatible con Firebase Auth/Firestore.
- API Gateway + Lambda (Node.js/TypeScript) es una opción a evaluar, no una obligación sin aprobación.
- Endpoints iniciales: health, áreas/temas, quizzes, envío de respuestas, progreso, ranking y CRUD administrativo con roles.
- Validar ID tokens Firebase en servidor; no confiar en UID, puntuaciones o permisos enviados por cliente.
- Documentar OpenAPI, esquemas, HTTP 200/201/400/401/403/404/409/429/500, errores estables, paginación y validación.
- Variables de entorno y Secrets Manager para secretos. Nunca incluir credenciales en Git.

## Fase 10 — AWS
- Preparar ambiente y configuración reproducible (IaC cuando sea viable), permisos IAM mínimos, registros, monitoreo, presupuestos y límites.
- Evitar despliegue y costos sin autorización explícita.
- Probar primero en desarrollo; conservar integración Firebase.

## Fase 11 — Calidad y rendimiento
- Pruebas unitarias, widgets, integración, Firebase Emulator y backend.
- Pruebas de carga controladas equivalentes a 50–100 solicitudes/variables según requisito docente, solo en ambiente autorizado.
- Revisar concurrencia del progreso/ranking, escrituras atómicas, manejo de fallos y rate limiting del lado servidor.

## Fase 12 — Documentación y entrega
- README actualizado, guía de instalación, arquitectura, esquema de Firestore editable, diagrama de navegación y API OpenAPI.
- Registro de evidencias y capturas reales de ejecución.
- Verificación final de pruebas, seguridad, calidad y configuración de distribución.

## Plantilla de reporte al terminar cada fase
- Fase y alcance completado.
- Archivos creados/modificados y por qué.
- Funcionalidad comprobada en simulador o entorno autorizado.
- Comandos y resultados exactos de pruebas.
- Riesgos y pendientes.
- Commit convencional, SHA y enlace remoto después de pruebas aprobadas y push verificado.
- Próxima fase sugerida; esperar autorización antes de implementarla.


## Auditoría Fase 0 — 11 de octubre de 2026 (America/Lima)

### Estado y alcance
- Proyecto real: `/Users/janelyapaza/Documents/synapse-health`.
- Workspace inicial de Codex: repositorio vacío distinto, sin remotos; no se modificó.
- Rama inicial: `desarrollo-25`; HEAD `da55709c53b27f6e6d0ae6cd50ff5d9333f996be`.
- Cambios previos conservados: `pubspec.yaml` y `pubspec.lock`.
- HEAD coincide con main y testIv remotos; cero commits locales pendientes sobre origin/main al inicio.
- Rama local creada y publicada: `feat/janely-synapse-development`, upstream origin/feat/janely-synapse-development; no se crearon commits.
- git push --set-upstream origin feat/janely-synapse-development: éxito exit 0; referencia remota comprobada en da55709c53b27f6e6d0ae6cd50ff5d9333f996be. Cambios de Fase 0 siguen locales pendientes de aprobación.
- Remoto origin confirmado: `https://github.com/bryanapazaquispev5-droid/synapse-health.git`; no se cambió.
- GitHub connector y gh API autentican `janelyapazasencia95-sketch`; metadata del repositorio confirma push=true.
- Consulta específica de collaborator permission: HTTP 403 Resource not accessible by integration; metadata push y publicación son la comprobación alternativa.
- Identidad Git efectiva: `janelyapazasencia95-sketch`, `janelyapazasencia95@gmail.com`, proveniente de ~/.gitconfig existente; no se alteró configuración global.
- Ninguna fase posterior fue implementada; no se desplegó Firebase ni AWS.

### Arquitectura y funcionalidades verificadas en código
- FSD existente: lib/features/auth_login, cheatsheets, quizzes, leaderboard, user_profile, navigation; api/model/ui/widgets y lib/core compartido.
- main.dart inicializa Firebase y puerta de acceso por authStateChanges; persistencia Firestore en disco desactivada.
- Auth: correo, Google, anónimo, registro, verificación, recuperación, perfil complementario y bloqueo local.
- Fichas: áreas → temas → fichas, Markdown, puntos clave, mnemotecnias, estados vacíos/offline.
- Quizzes: opción múltiple, asociaciones y ordenamiento, estrellas/tiempo, progreso por pregunta, reintentos e historial FIFO de tres intentos.
- Ranking: podio, posición personal, estrellas, desempates por tiempo y quizzes completados.
- Perfil: edición de nombre/carrera/género, ajustes de notificaciones, cierre de sesión.
- Navegación: Fichas, Quizzes, Progreso (actualmente ranking), Perfil; enrutamiento de notificaciones existente.
- Servicios: FCM, notificaciones locales, Crashlytics y Performance.
- No se identificó backend AWS ni pruebas Firebase Emulator/CI en el inventario.
- Estas observaciones describen código; no demuestran funcionamiento integrado contra Firebase real.

### Contrato visual a preservar
- AppTheme y AppColors: fondo #F2F2F7, superficie blanca, texto negro, acento #007AFF, colores semánticos iOS existentes.
- Tipografía .SF Pro Text/.SF Pro Display, títulos Cupertino 34/17.
- Reutilizar BottomFloatingPill, iconos GIF, LiquidWaveTransition, tarjetas, diálogos Cupertino y IosTopBanner.
- Transiciones existentes fade/slide 220 ms, retorno 180 ms; respetar espaciados de cada componente.
- No agregar paleta, degradados, sombras o sistema de componentes alternativo.
- No se modificó ningún archivo UI en esta fase.

### Dependencias y corrección mínima
- Flutter 3.47.3 stable; Dart 3.13.3; Xcode disponible; iOS deployment target 15.0.
- iOS utiliza Swift Package Manager; no tiene Podfile/Podfile.lock y no se agregaron.
- Conflicto anterior confirmado en Package.swift de caché: core 4.14.0/auth 6.6.1/firestore 6.9.0 exigían Firebase SDK exact 12.18.0.
- Crashlytics 5.4.0, Performance 0.11.6 y Messaging 16.7.0 exigen exact 12.19.0.
- Cambios locales previos conservados: core 4.15.0/auth 6.7.0/firestore 6.10.0; los seis plugins alineados en 12.19.0.
- Primer flutter test falló: firebase_auth 6.7.0 utiliza migrateCurrentUser, ausente en firebase_auth_platform_interface 9.0.7.
- Corrección adicional exclusivamente transitiva: flutter pub upgrade firebase_auth_platform_interface → 9.1.0; cambió una dependencia.
- No se editó caché de paquetes ni se aplicaron overrides; otras actualizaciones sugeridas se dejaron pendientes.

### Evidencias de verificación
| Comando | Resultado real |
|---|---|
| flutter pub get | Éxito, exit 0; 30 versiones nuevas informativas antes de la corrección transitiva. |
| flutter analyze inicial | Éxito, exit 0; No issues found, 3.8 s. |
| flutter test inicial | Fallo, exit 1; error migrateCurrentUser, 16 aprobadas y 4 errores de carga. |
| flutter pub upgrade firebase_auth_platform_interface | Éxito, exit 0; cambió exclusivamente 9.0.7 → 9.1.0. |
| flutter analyze después de corregir | Éxito, exit 0; No issues found, 4.3 s. |
| flutter test después de corregir | Éxito, exit 0; 26 pruebas aprobadas. |
| git diff --check | Éxito, exit 0, sin errores de espacios. |
| flutter run -d 0500CC3B-8D7C-4BD2-8651-215037FB5B2A | Compilación Xcode exitosa en 154,6 s, sincronización 409 ms, conexión Dart VM e inicio de sesión visible. |

- Xcode 26.6 (17F113). Ambos Package.resolved generados fijan Firebase SDK 12.19.0, revisión 27eaab3918e0bf78711cf1abf240577176326432; sin credenciales en URLs.
- Arranque real verificado visualmente: diálogo de notificaciones rechazado en simulador, luego pantalla Iniciar Sesión renderizada. Sin autenticación ni creación de datos de usuario.
- Captura real: `/private/tmp/synapse-health-fase0-iphone17.png`; no contiene datos personales.
- Aviso en ejecución: FLTGoogleSignInPlugin usa eventos de ciclo de vida obsoletos; falta soporte UIScene para una futura versión Flutter. No bloquea esta compilación.
- No se comprobaron login Google, recepción APNs/FCM ni persistencia contra Firebase mediante una cuenta real.
- Archivos finales: pubspec.yaml (cambios previos), pubspec.lock (cambios previos más interfaz Auth 9.1.0), este documento, ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved y ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved (generados por Xcode).
- Simulador elegido: iPhone 17, iOS 26.5, UUID 0500CC3B-8D7C-4BD2-8651-215037FB5B2A; boot ejecutado correctamente.
- Primer intento flutter run fue interrumpido durante descarga SPM para aplicar corrección transitiva; no cuenta como compilación exitosa.
- sandbox inicial impidió acceso a CoreSimulator (Connection invalid/Operation not permitted) y red gh; ejecuciones autorizadas fuera del sandbox resolvieron ambos accesos.
- codebase-memory requerido por AGENTS.md no está disponible entre las herramientas; se usó auditoría por archivos y dos subagentes de solo lectura.

### Revisión de secretos antes de publicación
- Patrones de claves privadas, tokens GitHub, claves AWS y cuentas de servicio: sin coincidencias en archivos versionados actuales.
- 100 commits históricos revisados con patrones de claves privadas, tokens GitHub/AWS y marcadores service_account: sin coincidencias.
- Es una búsqueda por patrones, no una garantía exhaustiva ni validación de restricciones de claves en Google Cloud.
- android/app/google-services.json ya está versionado pese al ignore; inspección muestra configuración cliente Firebase sin private_key/client_secret.
- lib/firebase_options.dart es configuración cliente existente; no se imprimieron valores de claves/tokens.
- Mantener .env, cuentas de servicio y certificados privados fuera de Git. No se agregó ningún archivo privado.

### Pendientes priorizados y aceptación
| Prioridad | Pendiente real | Criterio de aceptación para fase autorizada |
|---|---|---|
| P0 | firestore.rules:4-6 permite read/write if true. Estado desplegado no verificado. | Reglas por usuario/rol, pruebas permitidas/denegadas con emulador, revisión de impacto y aprobación antes de desplegar. |
| P1 | Ranking/progreso actualizados desde cliente mediante get/set sin transacción. | Integridad y concurrencia comprobadas; no confiar en puntuación enviada por cliente. |
| P1 | Sesión finaliza sin esperar persistencia y servicios absorben errores. | Confirmación explícita de guardado, fallo visible y reintento sin duplicación. |
| P1 | Datos de perfil Google y copia de token FCM en SharedPreferences. | Inventario de datos y almacenamiento seguro conforme al uso; no exponer tokens. |
| P1 | CAPTCHA local sin verificación servidor. | Protección antiabuso real verificada; no presentarlo como CAPTCHA servidor. |
| P1 | Configuración Google Sign-In/APNs/iOS no comprobada. | Validación de URL scheme, configuración Firebase y permisos; prueba funcional en entorno autorizado. |
| P2 | Ranking escucha toda colección y limita en memoria. | Consulta/paginación con límite servidor y coste de lectura verificado. |
| P2 | Racha inicializada en cero sin actualización localizada. | Mostrar solo racha calculada y persistida con datos reales. |
| P2 | Estados comunes, dashboard, progreso propio, historial visible, búsqueda y favoritos. | Aplicar fases 2–7 con modelos reales, estados carga/vacío/error y pruebas pertinentes. |
| P2 | Integración navegación, notificaciones y accesibilidad. | Preservar contratos e índices actuales; validar rutas y UI iOS/Android. |
| P3 | Backend REST/AWS aún no implementado. | Justificación de necesidad y aprobación separada de arquitectura/costos/despliegue. |

### Condiciones de cierre y reglas futuras
- Preservar modificaciones locales y trabajar solo en feat/janely-synapse-development.
- No refactorizar ni cambiar lógica funcional durante Fase 0; correcciones limitadas a incompatibilidades comprobadas.
- Usar commits convencionales pequeños y publicar cada fase validada según autorización vigente; no avanzar de fase sin instrucción.
- La publicación de una rama basada en HEAD no publica los cambios locales sin commit.
- Detenerse tras Fase 0; no iniciar Fase 1 sin autorización explícita.
- Criterio técnico de Fase 0 comprobado: dependencias resueltas, análisis sin incidencias, pruebas aprobadas, compilación y arranque real en iPhone 17. Cambios aprobados y publicados en el cierre posterior.


## Fase 1 — Validada, aprobada y publicada en GitHub
- Fecha: 11 de octubre de 2026, America/Lima. Rama feat/janely-synapse-development; remoto sin cambios.
- Alcance: autorización Firestore, validación de perfiles/progreso/tokens, administración mínima de contenido y pruebas Emulator Suite.
- Estado previo conservado; la base de Fase 0 se publicó en un commit separado antes del commit de seguridad.
- Reglas por UID para perfil, progreso y FCM; listado de perfiles prohibido; rutas desconocidas denegadas.
- Contenido académico y quizzes legacy: lectura autenticada, incluyendo invitados Firebase; escritura solo con claim contentAdmin confiable.
- createdAt de perfiles protegido; UID/email/tipos y campos permitidos validados; racha/proveedor protegidos.
- Recuperación de contraseña usa Auth directamente y mensaje uniforme, sin enumerar perfiles. Registro ya no consulta ni borra perfiles ajenos.
- Ranking queda solo lectura para clientes: se retiraron sus métodos de escritura y la publicación al completar quizzes.
- Efecto funcional deliberado: nuevos quizzes no incrementan ranking; resultados y progreso personal mantienen práctica/reintentos.
- Motivo: no existe evidencia verificable en recordCompletedQuiz; aceptar estrellas cliente contradice el requisito de seguridad.
- Ranking histórico no fue verificado; requiere revisión antes de tratarlo como confiable. No se creó backend ni se fabricaron métricas.
- Progreso privado es autodeclarado; validación estructural no verifica respuestas ni existencia de tema, y no valida exhaustivamente questionAnswers.
- Perfiles legacy incompatibles requieren inventario y migración administrativa previa al despliegue; no se modificaron datos reales.
- Scripts seed REST sin autenticación dejarán de funcionar con estas reglas; migrar a proceso administrativo autorizado antes de usarlos.
- Configuración aislada firebase.emulators.json, proyecto demo-synapse-health, host 127.0.0.1:8080; sin conexión ni despliegue de producción.
- Java 25.0.2 existente en Android Studio; CLI Firebase 15.30.1 y Firestore Emulator 1.22.0. Node 26.9.0 instalado.
- npm install terminó correctamente; aviso engine de superstatic (admite Node 20/22/24); se recomienda Node 22/24 para reproducir.
- Primera suite: 15 pruebas aprobadas; suite final ampliada: 19 pruebas de seguridad aprobadas, cero fallos/omitidas, 2,886 s, exit 0 (incluye invitado sin claim email, Google, cuentas vinculadas y FIFO).
- flutter test: 29 aprobadas (26 existentes y 3 nuevas sobre recuperación y errores); exit 0.
- flutter analyze inicial falló por seis errores en plantillas Dart de security/node_modules; exclusión específica añadida, repetición sin incidencias (2,1 s), exit 0.
- flutter run en iPhone 17 iOS 26.5: Xcode compiló en 19,7 s; sincronización 142 ms, VM conectada y login renderizado.
- Aviso Google Sign-In UIScene obsoleto persiste; no impide compilación. No se probaron usuarios reales, entrega de correos ni APNs.
- Captura: /private/tmp/synapse-health-fase1-iphone17.png. Evidencia de emulador: /private/tmp/synapse-phase1-emulator-final.log.
- Archivos Fase 1: firestore.rules, firebase.emulators.json, .gitignore, analysis_options.yaml, AuthService, CompleteProfileScreen, AuthForgotPasswordSheet, LeaderboardService, QuizSessionScreen, security/package.json y lockfile, cuatro módulos de pruebas, security/README.md, test/features/auth_login/auth_password_reset_test.dart y este documento.
- git diff revisado y git diff --check exit 0; revisión por patrones en 22 archivos candidatos sin secretos detectados. Lockfiles sin credenciales en URLs; logs/node_modules/configuraciones privadas excluidos.
- Commit Fase 1 publicado: bb4bda7b16d9f26f5a25e58251fb8187255feeb0, fix(firestore): 🔒 enforce owner authorization and secure ranking writes.
- Commit Fase 0 publicado: 7808c15b47203703010b8cc565b47253170cae31, fix(firebase): 🐛 align FlutterFire and iOS SDK dependencies.
- Ambas fases técnicas incluidas en origin/feat/janely-synapse-development; push da55709 → bb4bda7 verificado con git ls-remote y API GitHub.
- Detenerse aquí: no iniciar Fase 2 ni desplegar reglas. Manual, matriz de acceso y condiciones de migración: security/README.md.


## Registro de publicación autorizada — 11 de octubre de 2026
- Janely autorizó crear commits y ejecutar push de todos los cambios validados sin confirmación adicional; autorización vigente para cierres futuros.
- Cuenta GitHub comprobada: janelyapazasencia95-sketch; permiso push=true; remoto original sin modificar.
- Verificación repetida antes de publicar: flutter analyze sin incidencias (3,8 s), flutter test 29 aprobadas y Emulator Suite 19 aprobadas (3,367 s); todos exit 0.
- Compilación iOS de Fase 1 previamente ejecutada y verificada en iPhone 17 (19,7 s); no hubo nuevos cambios de código tras esa evidencia.
- Commits técnicos publicados y comprobados en el remoto. Este documento se publica en un tercer commit de documentación.
- Enlace: https://github.com/bryanapazaquispev5-droid/synapse-health/tree/feat/janely-synapse-development
- main y testIv permanecen en da55709c53b27f6e6d0ae6cd50ff5d9333f996be; no force push, no despliegue Firebase/AWS y no inicio de Fase 2.


## Fase 2 — Implementada, validada y publicada en GitHub
- Fecha: 11 de octubre de 2026, America/Lima; rama feat/janely-synapse-development.
- Alcance: Loading, Empty, Error y Offline compartidos con estilo existente; wrappers de fichas reutilizados.
- Integración en nueve pantallas existentes de fichas, quizzes y ranking; búsqueda vacía contextual y acciones de reintento.
- Suscripciones estables y contenido conservado en memoria; avisos parciales offline/error/recarga sin desmontar listas.
- Errores de acceso tienen prioridad sobre offline y descartan datos revocados; errores no se convierten en vacío.
- Progreso en carga/fallo no se interpreta como cero; intentos dependientes esperan datos válidos, sin cambiar reglas funcionales.
- Se retiraron valores de presentación ficticios: contador provisional de áreas y fallback20 cuando falta el número/máximo de quizzes.
- Sondeo HTTPS sin nuevas dependencias, agrupación de comprobaciones y separación de alcance de red vs disponibilidad del servidor.
- Persistencia Firestore en disco permanece desactivada; no se promete contenido disponible tras reiniciar.
- No se añadieron pantallas NotFound/UnderDevelopment sin flujo real, ni funciones de Fase 3.
- flutter analyze: sin incidencias, exit0 (3,2 s); flutter test: 55 aprobadas, exit0 (29 existentes y 26 nuevas).
- flutter run lib/main.dart en iPhone17/iOS26.5: compilación19,9 s, sincronización198 ms, VM y login visible.
- QA visual adicional de componentes aislados y botones; entrada temporal externa al repositorio, luego restaurada la app real.
- Aviso Google Sign-In UIScene previo persiste; flujos autenticados reales no se probaron en esta fase.
- Informe, archivos, limitaciones y capturas: docs/FASE_2_ESTADOS_UI.md.
- Commit de componentes y pruebas publicado: 340daacd8daf082329d63b445740ac46a74dd612.
- Commit de integración y pruebas de tarjetas publicado: a6a01e596a79ebe82d83d335a07892dbbdb3b2fa.
- Push 02de0b3 → a6a01e5 verificado por git ls-remote y API GitHub; documentación y capturas se publican en commit separado.
- Rama: https://github.com/bryanapazaquispev5-droid/synapse-health/tree/feat/janely-synapse-development
- Revisión de 31 archivos de la fase sin secretos detectados; archivos Dart modificados menores de 250 líneas.
- Detenerse aquí: Fase 3 sin iniciar; no despliegues ni cambios en main/testIv.
