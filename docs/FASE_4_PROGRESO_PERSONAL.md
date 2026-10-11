# Fase 4: Progreso Personal

Estado: implementado, probado y publicado en feat/janely-synapse-development. Commits de código: 57ef9f77a7c3932944629b5165a2393b6b7debea y 20989359a2f932609fb3684271fe4e208f44b76f, verificados en la API GitHub y git ls-remote. Documentación y capturas se publican con esta actualización.

## Alcance y navegación

La pestaña Progreso (índice 2) presenta datos privados del estudiante autenticado. La acción visible «Ranking global» abre el LeaderboardScreen existente con una barra de regreso. Se conservan podio, clasificaciones y ordenaciones del ranking, la navegación flotante, transiciones y AppTheme. No se implementó la Fase 3 ni se avanzó a otra fase.

Se reutilizan los estados de la Fase 2 para carga, errores, ausencia de datos y conexión. Los errores no se convierten en estadísticas cero; la pérdida de permisos invalida contenido privado. Al cambiar de usuario se destruye el cuerpo asociado al UID anterior. Las tarjetas se adaptan a texto grande y ancho reducido.

## Datos y fórmulas

Fuente: QuizProgressService.getAllTopicsProgressStream, colección users/{uid}/quiz_topics_progress. MedicalAreasService aporta nombres reales de áreas y temas del catálogo existente. PersonalProgressRepository comprueba el UID activo antes de consultar y en cada evento; no recibe UID ajenos de la interfaz. Los modelos de resumen son derivados en memoria, sin nuevos campos o colecciones persistidos.

| Indicador | Definición |
| --- | --- |
| Estrellas actuales | Suma de totalEarnedStars de intentos activos con respuestas; agregados negativos heredados no se presentan como estrellas ganadas. |
| Quizzes únicos respondidos | Unión de claves de respuestas isAnswered por área y tema, dentro del intento activo e historial conservado. |
| Aciertos actuales | 100 × respuestas correctas / respuestas contestadas de intentos activos; sin denominador se muestra No disponible. |
| Intentos conservados | Intentos con al menos una respuesta: activo más los últimos tres históricos, sin duplicar attemptNumber. |
| Rendimiento por área | Las mismas fórmulas agrupadas por areaId; nombres ausentes muestran Área no disponible. |
| Evolución por tema | Al menos dos intentos con respuestas y answeredAt en todas ellas; barras discretas de porcentaje correcto y fecha de última respuesta, convertida a hora local. |

Los reintentos mantienen el comportamiento previo: las estrellas corresponden al intento activo y el historial conserva hasta tres entradas FIFO. No se acumulan estrellas de reintentos como un total vitalicio. Un registro de pregunta contestada no demuestra haber completado todo el tema. Por ello se usa «respondidos» y no se inventa una cifra de sesiones completadas.

## Persistencia y privacidad

recordQuestionAnswer y retryTopic usan transacciones de Firestore para evitar que escrituras concurrentes pierdan respuestas. Se conservan fórmulas de puntuación, historial y estructura. Los errores se registran y propagan; la sesión de quiz muestra un aviso comprensible si falla el guardado. No se migran resultados existentes.

No se duplican consultas en cada rebuild: streams estables, cálculo memoizado por entrada y una consulta de temas por área cuando hay evolución suficiente. Las suscripciones terminan al desmontar el widget. Se conserva el contenido disponible al perder conexión, sin prometer persistencia tras reiniciar: Firestore continúa con persistencia en disco desactivada. Las transacciones requieren conexión y no se prometen guardados offline.

La autorización real depende también de reglas desplegadas. Se verificaron las reglas locales con Emulator Suite; esta fase no despliega reglas a producción ni certifica su estado remoto. Las métricas de práctica privada no son una evaluación académica certificada ni un origen autorizado de puntuación global.

## Validación ejecutada

- flutter pub get: correcto, sin añadir dependencias.
- flutter analyze: sin incidencias, 2,7 segundos.
- flutter test: 100 pruebas aprobadas; 45 específicas nuevas de cálculo, repositorio, widgets y persistencia.
- Firebase Emulator Suite: 19 pruebas de seguridad aprobadas, proyecto demo local, sin producción.
- flutter run lib/main.dart: iPhone 17 / iOS 26.5; Xcode build 19,9 segundos, sincronización 111 ms y VM activa, login visible.
- Vista local vacía ejecutada en el simulador: build 23,8 s, sincronización 138 ms; entrada temporal externa, sin Firebase ni registros inventados. Captura revisada visualmente.
- git diff --check: correcto. Revisión de diferencias y archivos de la fase antes del commit.

Las pruebas cubren respuestas parciales, porcentajes, únicos frente a intentos, FIFO, evolución sin fechas ficticias, UID incorrecto/cambio de sesión, errores, conservación offline, acceso y retorno del ranking, texto grande y escrituras concurrentes. Los dobles de FlutterFire están aislados en test; la excepción del lint de clases selladas se limita a ese archivo de prueba.

## Limitaciones y riesgos existentes

- No existen duraciones fiables guardadas: tiempo promedio no disponible.
- No hay denominador de catálogo verificado para calcular avance total por área.
- Historial limitado a tres intentos anteriores: únicos e intentos son cifras conservadas, no totales de toda la vida.
- startedAt puede ser sintetizado por el modelo y completedAt se asigna al reintentar incluso con actividad parcial; ninguno se usa como prueba de finalización o duración.
- La clave de documento actual es topicId. Si se reutilizase entre áreas podría colisionar; corregirlo requiere una migración separada, no realizada aquí.
- No se probaron sesiones reales de estudiantes autenticados en producción. El login real del simulador y el módulo mediante pruebas automatizadas sí se ejecutaron.
- Persiste el aviso previo de Google Sign-In sobre ciclo de vida UIScene obsoleto.

## Archivos

Nuevos: lib/features/personal_progress/{api,model,utils,ui}, test/features/personal_progress y dos archivos de pruebas de persistencia en test/features/quizzes.
Modificados: main_navigation_wrapper.dart, quiz_progress_service.dart, quiz_session_screen.dart y docs/PLAN_DESARROLLO_JANELY.md. Capturas en docs/evidence/phase4; la vista vacía está identificada como prueba local, sin actividad ni cuenta real.

El arranque real lib/main.dart quedó restaurado después de la comprobación visual: build 19,6 s y sincronización 88 ms. La herramienta de memoria del código indicada por AGENTS.md no estaba disponible; la inspección se hizo directamente con Git y búsquedas acotadas.
