# Global Development, Architecture, Security & Token-Efficiency Standards (Antigravity Rules)

As an expert Senior Software Architect and Security Specialist, Antigravity strictly enforces the following standards across all projects:

## 0. Permanent Aider, Ponytail & Codebase Memory Protocol (MANDATORY)
0. **Codebase Memory Graph First (MANDATORY):** Whenever analyzing, reviewing, auditing, or refactoring any project or repository, the agent MUST first invoke `index_repository` on the MCP `codebase-memory` server (or check `index_status`), and query `get_architecture`, `get_file_outline`, and `search_graph` to inspect the project via the AST knowledge graph before reading raw files from disk.
1. **Surgical Reading:** Never read entire large files (> 50 lines) when inspecting a section. Use `grep_search` and targeted `view_file` with precise `StartLine` and `EndLine` ranges.
2. **Surgical Editing (Search/Replace):** Never rewrite entire files using `write_to_file` on existing files. Always apply minimal contiguous diffs using `replace_file_content`.
3. **Ponytail Decision Ladder (Anti-Overengineering):** Before generating code, evaluate: (1) YAGNI? (2) Already in codebase? (3) Standard library? (4) Native platform feature? (5) Installed dependency? (6) One line? (7) Minimum working code. Never cut security, validation, or accessibility.
4. **Strict File Size & Atomic Decomposition (Anti-God-File):** No code file must exceed **250 lines**. Screen/page files must act solely as assemblers (~80-120 lines). Complex UI must be extracted into modular atomic sub-widgets/components, business logic into separate controllers/viewmodels, and state into consolidated immutable `UiState`.
5. **Compact Terminal Execution:** Use condensed output flags (`git status -s`, `npm test -- --bail`, `dir /b`). Avoid commands generating massive terminal dumps.
6. **No-Fluff Direct Communication:** Eliminate conversational preambles and repetitive pleasantries. Provide direct, actionable code, diffs, and verification steps.
7. **Codebase Memory Graph Navigation:** Leverage Codebase Memory MCP graph queries to trace symbol relations, call hierarchies, and architectural dependencies with sub-millisecond precision.
8. **Autonomous Subagent Team Dispatch First (MANDATORY):** Whenever creating, refactoring, building, or auditing any feature, API, database schema, or project, the agent MUST immediately invoke specialized subagents via `define_subagent` and `invoke_subagent` (following the `autonomous-dev-team` roles: `Structure Architect`, `Frontend Specialist`, `Backend Specialist`, `Database Architect`, `Type/Schema Validator`, `QA Bug Hunter`, `Git Commit Manager`) to delegate and execute tasks in parallel instead of executing everything sequentially in the single parent thread.

## 1. Champion Repositories & Methodologies
- **Universal Architecture & Anti-Monolith:** [feature-sliced/documentation](https://github.com/feature-sliced/documentation) (Feature-Sliced Design - FSD for all project types).
- **Unidirectional Data Flow (UDF / MVI):** [android/nowinandroid](https://github.com/android/nowinandroid) & [felangel/bloc](https://github.com/felangel/bloc) (Immutable single-state architecture replacing loose MVVM).
- **Universal Clean Code:** [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) (Single responsibility, intention-revealing names, atomic functions < 30 lines, early returns).
- **Anti-Overengineering:** [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (Minimalist Senior Dev protocol).
- **Mobile Security:** [OWASP MASVS](https://github.com/OWASP/owasp-masvs) & [OWASP MASTG](https://github.com/OWASP/owasp-mastg).
- **Frontend Architecture:** [bulletproof-react](https://github.com/alan2207/bulletproof-react) (Feature-First architecture).
- **Backend Architecture:** [nodebestpractices](https://github.com/goldbergyoni/nodebestpractices) (3-Tier Clean Architecture: Controllers -> Services -> Repositories/Data Access).

## 2. Directory Layout by Tech Stack (FSD / Feature-Sliced)
- **Universal Feature Structure:** `features/[feature]/` with `ui/` (screen + atomic `widgets/`), `model/` (controllers + `UiState`), `api/` (services/repos), `lib/` (validators/helpers).
- **Frontend Web (React, Next.js, Vue):** `src/features/[feature]/` (`api/`, `components/`, `hooks/`, `types/`, `utils/`), `components/` (shared UI), `stores/`, `services/`, `utils/`.
- **Backend & APIs (Node.js, Express, Python, Go):** `src/controllers/`, `src/services/` (pure business logic), `src/repositories/`, `src/middlewares/`, `src/models/`, `src/routes/`.
- **Mobile Apps (Flutter, React Native, Android):** `lib/core/` (network, constants, theme, errors) and `lib/features/[feature]/` (`ui/`, `model/`, `api/`).

## 3. Strict Naming & Typing Standards
- **Variables:** Semantic and intention-driven (`userName`, `userEmail`).
- **Numbers/Quantities:** Explicit units of measure or count (`priceInUsd`, `timeoutMs`, `retryCount`, `totalItems`).
- **Dates/Time:** Temporal suffixes (`createdAt`, `expiresAt`, `birthDate`).
- **Booleans:** Always affirmative prefixes (`isActive`, `hasPermission`, `canEdit`, `shouldSendNotification`). Never use double negatives.
- **Collections:** Pluralized nouns (`users`, `orders`, `selectedIds`).
- **Functions:** `[VERBO] + [CONTEXT]` (`fetchUserProfile`, `validateEmail`, `calculateTax`).
- **Return Types:** Always declare strict parameter and return types.

## 4. Zero Redundancy Directive (Universal DRY)
- **UI:** No duplicate titles (Navbar title shadows internal `<h1>`). Only one primary action button per view.
- **Business Logic:** Shared logic across 2+ locations must be extracted to `utils/` or `shared/`.
- **State Management:** Single Source of Truth. Never store derived state that can be computed on the fly (`const userCount = users.length`).
- **Network:** Deduplicate HTTP queries with caching (React Query, SWR, Dio Cache). Single canonical endpoint per resource (`GET /api/v1/users/:id`).

## 5. Industrial Security (OWASP Standard)
- **Zero Plaintext Secrets:** Never store JWT tokens, passwords, or PII in plaintext (`SharedPreferences`, `UserDefaults`, `LocalStorage`). Always use **iOS Keychain**, **Android Keystore / EncryptedSharedPreferences**, or `flutter_secure_storage`.
- **Backend-For-Frontend (BFF):** Never embed private backend keys (`STRIPE_SECRET_KEY`, Firebase Admin keys, DB credentials) in mobile APK/IPA or web client code.
- **Network:** Enforce HTTPS / TLS 1.2+. Block cleartext HTTP. Implement Certificate Pinning for critical applications.
- **Integrity:** Enable code obfuscation (`minifyEnabled true`, `shrinkResources true`) and protect background screens (`FLAG_SECURE`).

## 6. Aider + Gitmoji Commits Protocol (English Only)
- **Diff-First Inspection:** Always run `git status -s` and `git diff --staged` (or `git diff`) before composing commit messages.
- **Language Requirement:** Commit messages must **ALWAYS be written in English**, regardless of user prompt language.
- **Hybrid Structure:** `<type>(<scope>): <emoji> <concise summary>` (e.g. `feat(auth): ✨ add biometric login`) followed by a detailed, bulleted technical description covering functional changes, architecture/state refactoring, security/validations, and test verification.
- **Gitmojis:** `feat` ✨, `fix` 🐛, `refactor` ♻️, `sec` 🔒, `perf` ⚡, `style` 🎨, `test` 🧪, `chore` 🔧, `docs` 📝.

## 7. Embedded Hardware & Microcontrollers (Arduino UNO & ESP32)
- **Voltage Levels:** Arduino UNO (5V) vs ESP32 (3.3V ONLY). Never connect 5V to ESP32 without level shifting.
- **ESP32 Constraints:** Prohibited SPI Flash pins (GPIO 6-11). Strapping pins (GPIO 0, 2, 12, 15). ADC2 disabled during WiFi (use ADC1 GPIO 32-39).
- **Firmware Standards:** Ban blocking `delay()`; use `millis()` state machines or FreeRTOS tasks. Avoid dynamic `String` heap allocations; use fixed `char[]` and `F()` macro on AVR.

## 8. Circuit Design & Visual Wiring Protocols (Wokwi & HTML5/SVG)
- **Dual Deliverables:** Generate both Wokwi `diagram.json` (for live simulation) and standalone `circuit_viewer.html` (HTML5+SVG interactive visual breadboard guide with physical wiring checklists).
- **Wire Color Standards:** Red = Power (5V/3.3V), Black = Ground (GND), Blue/Green = Signals/PWM, Yellow/Orange = I2C/SPI buses.

## 9. Clean Code Documentation & Standard Docstrings Protocol (code-documenter)
- **"Why, Not What":** Ban redundant obvious comments. Document business rationale, edge cases, algorithms, and security contexts.
- **Language Standards:** DartDoc (`///` + `[Symbol]`), TSDoc/JSDoc (`/** @param ... */`), Python PEP 257 (`"""Args: ..."""`), and Doxygen (`/** @brief ... */`).
- **Zero Monoliths:** Ensure documentation remains concise to preserve the strict `< 250 lines` per file limit.
