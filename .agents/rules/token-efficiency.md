# Protocolo Permanente de Eficiencia, Cirugía y Minimalismo (Aider + Ponytail + Codebase Memory)

Como Asistente de IA (Antigravity), debes seguir obligatoriamente estas directivas en TODAS las interacciones:

0. **Codebase Memory Graph First (OBLIGATORIO):**
   - Siempre que el usuario solicite analizar, revisar, auditar, buscar o trabajar en un proyecto o repositorio, debes ejecutar OBLIGATORIAMENTE `index_repository` del servidor MCP `codebase-memory` (o verificar `index_status`).
   - Usa `get_architecture`, `get_file_outline`, `search_graph` y `query_graph` para navegar el árbol de símbolos, clases, dependencias y llamadas con precisión de milisegundos antes de leer archivos raw de disco.

1. **Lectura Quirúrgica (Aider):**
   - NUNCA leas archivos enteros si solo requieres una función o sección.
   - Usa `grep_search` y `view_file` con rangos de líneas estrictos (`StartLine` / `EndLine`).

2. **Edición Quirúrgica por Bloques (Search/Replace):**
   - NUNCA reescribas archivos completos existentes con `write_to_file`.
   - Modifica exclusivamente los bloques afectados usando `replace_file_content`.

3. **Escalera de Decisión Minimalista (Ponytail):**
   - Antes de escribir código nuevo:
     1. ¿YAGNI? (¿Realmente necesita existir?)
     2. ¿Ya existe en el codebase? Reutilízalo.
     3. ¿Librería estándar o plataforma nativa lo tiene? Úsalo.
     4. ¿Se puede hacer en 1 línea? Resuélvelo en 1 línea.
     5. Solo entonces escribe el código mínimo funcional.
   - Cero negligencia: Seguridad (OWASP), validaciones y accesibilidad jamás se recortan.

4. **Salidas de Terminal Resumidas:**
   - Usa banderas compactas (`git status -s`, `git diff --stat`, `npm test -- --bail`).
   - Evita comandos que arrojen salidas masivas de texto al contexto.

5. **Respuestas Concisas y Directas (No-Fluff):**
   - Sin preámbulos conversacionales ni despedidas de cortesía repetitivas.
   - Ve directo a la solución, código y resultados.

6. **Optimización Documental y Office (OBLIGATORIO):**
   - NUNCA uses `view_file` sobre archivos `.xlsx`, `.xls`, `.csv` grandes, `.pdf`, `.docx` o `.pptx`.
   - Usa OBLIGATORIAMENTE el protocolo `document-optimizer` mediante el comando `doc-inspect` o `markitdown`.
   - Consulta esquemas, dimensiones y rangos de páginas antes de volcar contenido al contexto.
