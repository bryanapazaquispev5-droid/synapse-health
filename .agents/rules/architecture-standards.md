# Directivas Maestras de Arquitectura, Código Limpio y Seguridad (Global)

Como Asistente de IA (Antigravity), debes seguir obligatoriamente todas las siguientes directivas en todo proyecto web o móvil:

## 1. Repositorios y Referencias Obligatorias
- **Universal / Clean Code:** [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) (Nombres con intención, funciones atómicas < 30 líneas, early returns).
- **Seguridad Móvil:** [OWASP MASVS](https://github.com/OWASP/owasp-masvs) y [OWASP MASTG](https://github.com/OWASP/owasp-mastg).
- **Frontend Web:** [bulletproof-react](https://github.com/alan2207/bulletproof-react) (Arquitectura Feature-First).
- **Backend & APIs:** [nodebestpractices](https://github.com/goldbergyoni/nodebestpractices) (3 Capas: Controllers, Services, Repositories).
- **Mobile Apps:** [android/architecture-samples](https://github.com/android/architecture-samples) (MVVM + Clean Architecture: Data, Domain, Presentation).

## 2. Arquitectura de Carpetas
- **Frontend Web:** `src/features/[feature]/` (`api/`, `components/`, `hooks/`, `types/`, `utils/`), `components/` globales, `stores/`, `services/`.
- **Backend:** `src/controllers/`, `src/services/` (lógica pura), `src/repositories/`, `src/middlewares/`, `src/models/`, `src/routes/`.
- **Mobile (Flutter / React Native / Android):** `core/` (red, errores, constantes) y `features/[feature]/` (`data/`, `domain/`, `presentation/`).

## 3. Nomenclatura y Tipado Estricto
- Variables con intención y sustantivas (`userName`, `userEmail`).
- Números con unidades explícitas (`priceInUsd`, `timeoutMs`, `retryCount`).
- Fechas con sufijos temporales (`createdAt`, `expiresAt`, `birthDate`).
- Booleanos SIEMPRE afirmativos (`isActive`, `hasPermission`, `canEdit`). Prohibido nombres negativos (`!isNotValid`).
- Colecciones en plural (`users`, `orders`).
- Funciones: `[VERBO] + [CONTEXTO]` (`fetchUserData`, `sendInvoiceEmail`).
- Tipado estricto en parámetros y retorno (`Promise<User>`, `void`, `number`).

## 4. Cero Redundancia (DRY Universal)
- **UI:** No repetir títulos de navegación dentro de la vista. Una sola acción primaria destacada por pantalla.
- **Lógica:** Extraer cualquier lógica repetida a utilitarios compartidos.
- **Estado:** *Single Source of Truth*. PROHIBIDO almacenar estados derivados (calcular al vuelo `userCount = users.length`).
- **Red:** Deduplicar peticiones HTTP con caché (React Query, SWR, Dio). Endpoints canónicos únicos en backend.

## 5. Seguridad Estricta (OWASP)
- **NUNCA** almacenar tokens JWT, contraseñas o PII en texto plano (`SharedPreferences`, `UserDefaults` o `LocalStorage`). Usar **iOS Keychain**, **Android Keystore / EncryptedSharedPreferences** o `flutter_secure_storage`.
- **NUNCA** incrustar API keys privadas ni secretos de backend en apps móviles o web. Usar arquitectura **Backend-For-Frontend (BFF)**.
- Tráfico HTTPS / TLS 1.2+ obligatorio. Bloquear HTTP en claro.
- Activar ofuscación (`minifyEnabled true`, `shrinkResources true`) y protección de pantalla (`FLAG_SECURE`).
