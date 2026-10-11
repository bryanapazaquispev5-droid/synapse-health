# Firestore — Fase 1

Reglas y pruebas locales. No se ha realizado ningún despliegue.

## Ejecutar

Requisitos: Node.js 22 o 24 recomendado, npm, Java 21 o superior y puerto 8080 libre.

```sh
cd security
npm ci --ignore-scripts
npm test
```

En este equipo se utilizó el Java existente de Android Studio:

```sh
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" npm test
```

CLI Firebase 15.30.1, SDK JS 13.0.0 y rules-unit-testing 6.0.0 están fijados en package-lock.json.
El emulador oficial Firestore se descarga la primera vez. No se necesita iniciar sesión en Firebase.
El comando fija demo-synapse-health y ../firebase.emulators.json; los tests exigen
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080. Autenticación se simula con claims en rules-unit-testing.
Los datos de prueba son fixtures aislados; no son información de estudiantes ni contenido médico de producción.
Las suites se ejecutan serialmente porque comparten proyecto y limpian datos entre casos.
PERMISSION_DENIED en solicitudes adversariales es esperado: assertFails comprueba su rechazo.

## Matriz de acceso

| Ruta | Lectura | Escritura |
|---|---|---|
| users/{uid} | Solo get por propietario; list prohibido | Crear/editar campos permitidos propios; delete prohibido |
| users/{uid}/quiz_topics_progress/{topicId} | Propietario | Crear/editar práctica propia; delete prohibido |
| users/{uid}/fcm_tokens/{token} | Propietario | Crear/actualizar/eliminar propio con token y tipos válidos |
| medical_areas, topics, cheatsheets, quizzes explícitos | Autenticados, incluidos invitados Firebase | Solo claim contentAdmin booleano true |
| leaderboard/{uid} | Autenticados | Ningún cliente; requiere servidor autorizado por IAM |
| Rutas no declaradas | Denegada | Denegada |

contentAdmin se emite mediante Firebase Admin SDK por administración confiable.
No se lee de users, no se asigna desde la app y no concede acceso a perfiles/tokens ajenos.
No se ha provisionado ningún rol real. Los scripts actuales de seed realizan REST sin autenticación;
al desplegar estas reglas serán rechazados y deberán migrarse a un proceso administrativo autorizado.
No ejecutar scripts de seed contra producción durante estas pruebas.

## Contratos y limitaciones

- UID ligado al documento, email ligado al token Auth (o correo fijo del invitado), createdAt protegido.
- Campos desconocidos y privilegios enviados en perfiles se rechazan. authProvider y racha son inmutables desde cliente.
- Perfiles existentes pueden conservar una racha previamente calculada; no hay cálculo nuevo de rachas.
- Progreso conserva fechas ISO, intentos y máximo tres históricos. Se validan agregados y cada intento del historial.
- questionAnswers es un mapa variable: no se afirma verificación exhaustiva de cada respuesta ni que las estrellas sean auténticas.
- El progreso es práctica autodeclarada privada. No puede alimentar un ranking confiable directamente.
- El cliente deja de publicar métricas en leaderboard. Lectura, ordenación y pantalla existentes se conservan.
- Ranking histórico no ha sido verificado. Queda sin nuevas actualizaciones del cliente, incluyendo metadatos públicos.
- No se creó el proceso servidor de puntuación: requiere diseño y autorización posterior; no se agregó backend paralelo.
- Recuperación usa Firebase Auth y mensaje uniforme; no consulta perfiles. La configuración de protección
  contra enumeración de emails de Firebase Auth en producción todavía debe verificarse.
- La ejecución del simulador verifica compilación y pantalla inicial; no comprueba estas reglas desplegadas,
  login real, entrega de correo ni notificaciones remotas. Estas reglas se probaron en Emulator Suite.

## Antes de aprobar un despliegue separado

1. Revisar las diferencias y su impacto sobre ranking e importaciones de contenido.
2. Inventariar perfiles existentes: campos adicionales, UID/email, género y fechas. Los documentos
   incompatibles se rechazan en futuras ediciones; preparar migración administrativa sin borrar datos.
3. Revisar/migrar ranking histórico y diseñar puntuación confiable antes de reactivar publicaciones.
4. Provisionar contentAdmin solo a identidades autorizadas; revisar IAM de procesos Admin SDK.
5. Verificar reglas actuales desplegadas, clientes antiguos, recuperación Auth y flujos con cuentas autorizadas.
6. Repetir npm ci/npm test y obtener autorización explícita para despliegue. No cambiar producción desde esta fase.

Fuentes oficiales:
- [Pruebas de reglas con Emulator Suite](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Validación de campos y diferencias](https://firebase.google.com/docs/firestore/security/rules-fields)
- [Custom claims administrados](https://firebase.google.com/docs/auth/admin/custom-claims)
