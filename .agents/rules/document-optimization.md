# Regla de Optimización Documental y Procesamiento Quirúrgico de Archivos Office y PDF

Como Asistente de IA (Antigravity), debes seguir obligatoriamente esta directiva siempre que interactúes con documentos:

1. **Detección Automática de Archivos Office / PDF:**
   - Siempre que el usuario mencione, solicite leer, analizar, consultar o extraer datos de archivos con extensión:
     * Excel: `.xlsx`, `.xls`, `.csv` (grandes)
     * PDF: `.pdf`
     * Word: `.docx`, `.doc`
     * PowerPoint: `.pptx`, `.ppt`
   - **QUEDA ESTRICTAMENTE PROHIBIDO:** Usar `view_file` directamente sobre estos archivos binarios o volcarlos al contexto en texto plano.

2. **Acción Obligatoria:**
   - Ejecuta inmediatamente `doc-inspect "<ruta_al_archivo>"` o `markitdown "<ruta_al_archivo>"`.
   - Si es Excel: Muestra primero el esquema de columnas y dimensiones. Si te piden un cálculo, computa el resultado mediante un script y entrega el dato resumido.
   - Si es PDF: Revisa primero el índice (`--summary`) y luego extrae únicamente las páginas relevantes (`--pages X-Y`).
   - Si es Word o PowerPoint: Extrae el esquema o convierte a Markdown limpio.

3. **Ahorro de Tokens:**
   - Esta regla garantiza un ahorro del 85% al 98% en cada interacción con documentos sin pérdida de información.
