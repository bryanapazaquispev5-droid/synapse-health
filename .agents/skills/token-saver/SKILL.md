---
name: token-saver
description: >-
  Aider-based surgical token optimization, Codebase Memory graph-first navigation, and context management protocol. Enforces graph-based AST indexing, targeted line-range reading, minimal block diff editing, compact terminal outputs, and zero-fluff responses to minimize token consumption by 70-85% without sacrificing accuracy.
---

# Protocolo Aider de Eficiencia y Ahorro de Tokens (Surgical Protocol)

Este skill implementa el estándar de oro de [aider-chat/aider](https://github.com/aider-chat/aider) y [Codebase Memory MCP](https://github.com/DeusNexus/codebase-memory-mcp) para maximizar la velocidad, precisión y reducir el consumo de tokens entre un 70% y 85% en cada interacción.

---

## 0. Codebase Memory Graph First (OBLIGATORIO)
* **Indexación AST previa:** Al analizar o explorar cualquier proyecto nuevo o repositorio, ejecuta `index_repository` en el MCP `codebase-memory` (o comprueba `index_status`).
* **Navegación por Grafo:** Utiliza `get_architecture`, `get_file_outline`, `search_graph` y `query_graph` para entender la arquitectura, clases y dependencias antes de leer archivos raw de disco.

---

## 1. Lectura Quirúrgica de Archivos (*Surgical Reading*)
* **Prohibido volcar archivos completos:** Si un archivo tiene más de 50 líneas y solo se necesita consultar una función o bloque, **NUNCA** leas el archivo entero.
* **Búsqueda guiada:** Usa `grep_search` para localizar la función o símbolo exacto.
* **Rangos específicos:** Lee únicamente las líneas relevantes usando `StartLine` y `EndLine` con `view_file`.

---

## 2. Edición Quirúrgica por Bloques (*Search/Replace Diffs*)
* **Prohibido reescribir archivos enteros:** NUNCA uses `write_to_file` con `Overwrite: true` sobre archivos existentes de código salvo que sea un archivo nuevo de 0.
* **Edición diferencial:** Usa `replace_file_content` sobre el bloque contiguo mínimo que requiere la modificación.
* **Preservación de contexto:** Esto evita alucinaciones, previene borrado accidental de código y reduce el costo de salida de tokens a una fracción mínima.

---

## 3. Salidas de Terminal y Logs Compactos
* **Comandos con salida resumida:** Usa banderas que eviten saturar el historial de contexto:
  * Git: `git status -s`, `git diff --stat`, `git log -n 5 --oneline`.
  * Tests: `npm test -- --bail` o `pytest -x -q` para detenerse al primer error.
  * Listados: Evita `ls -la` o `dir /s` recursivos descontrolados; usa `find_by_name` con filtros o límites.

---

## 4. Respuestas Directas sin Relleno (*No-Fluff Communication*)
* **Cero preámbulos conversacionales:** Elimina introducciones innecesarias ("Claro, con gusto te ayudo a resolver el problema que mencionas...").
* **Estructura directa:**
  1. Breve confirmación del cambio/acción (1 o 2 líneas).
  2. Bloque de código / diff / comando exacto.
  3. Resultado de verificación conciso.
