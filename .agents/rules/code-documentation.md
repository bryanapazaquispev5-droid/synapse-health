# Code Documentation, Commenting & Standard Docstrings Rules (Clean Code Standard)

When commenting, documenting, generating docstrings, or annotating code across any workspace or project:

## 1. Golden Rule: "Why, Not What"
- **Strictly Ban Obvious Noise:** Never add comments that merely repeat what the code syntax already states.
- **Document Intent & Business Logic:** Explain why a decision was made, why specific thresholds or parameters were chosen, and what business problem it solves.
- **Edge Cases & Workarounds:** Explicitly document race conditions, OS workarounds, retry policies, or fallbacks.
- **Security Context (OWASP):** Note encryption, sensitive token handling, or sanitization rationales.

## 2. Mandatory Tech Stack Standards
- **Dart / Flutter:** Use DartDoc `///` with `[Symbol]` references, parameter descriptions, return values, and usage examples.
- **TypeScript / JavaScript:** Use TSDoc / JSDoc `/** ... */` with `@param`, `@returns`, `@throws`.
- **Python:** Use PEP 257 / Google Style Docstrings (`"""Args: ... Returns: ..."""`).
- **C++ / Arduino / ESP32:** Use Doxygen `/** @brief ... @param ... @return */`.

## 3. Strict Size & Integrity Enforcement
- Comments must be concise to respect the project's **< 250 lines per file** limit.
- **Never alter the underlying business logic** or execution flow when adding documentation.
