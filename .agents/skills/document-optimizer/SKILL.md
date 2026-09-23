---
name: document-optimizer
description: >-
  Surgical Office & Document token optimization protocol for Excel (.xlsx, .xls, .csv), PDF (.pdf), Word (.docx), and PowerPoint (.pptx). Enforces schema-first inspections, targeted page-range extractions, pandas-driven queries, and clean Markdown conversions using doc-inspect and markitdown to prevent token bloat and save 85-98% of tokens.
---

# Protocolo Quirúrgico de Optimización Documental (Excel, PDF, Word, PowerPoint)

Este skill define el estándar obligatorio para inspeccionar, extraer información, analizar y consultar documentos de oficina y archivos binarios sin desperdiciar tokens en la ventana de contexto.

---

## 0. Regla de Oro (PROHIBIDO ABRIR EN CRUDO)
* **NUNCA** uses `view_file` directamente sobre archivos `.xlsx`, `.xls`, `.csv` pesados, `.pdf`, `.docx` o `.pptx`.
* Los archivos de oficina son contenedores binarios o ZIPs de XMLs. Abrirlos directamente causa errores de decodificación o consume cientos de miles de tokens inútilmente.
* Usa **SIEMPRE** la utilidad global `doc-inspect` o `markitdown`.

---

## 1. Hojas de Cálculo (Excel `.xlsx`, `.xls` y CSVs `.csv`)
* **Inspección de Esquema (Primera pasada obligatoria):**
  ```bash
  doc-inspect "ruta/al/archivo.xlsx" --summary
  ```
  * Muestra: Pestañas (sheets), número total de filas y columnas, nombres de columnas con sus tipos de datos y primeras 3 a 5 filas de muestra en Markdown.
  * Consumo: **~150 tokens** (en vez de 50,000+).
* **Consultas y Filtros Quirúrgicos:**
  * Si el usuario pide calcular, filtrar o buscar un dato específico, **NUNCA** vuelques la tabla entera al chat.
  * Ejecuta una consulta dirigida:
    ```bash
    doc-inspect "ruta/al/archivo.xlsx" --sheet "Ventas" --query "Total > 1000 and Region == 'Sur'" --head 5
    ```
  * O usa un script de Python con `pandas` para obtener solo el valor escalar o resumen estadístico solicitado.

---

## 2. Documentos PDF (`.pdf`)
* **Inspección de Índice y Metadatos (Primera pasada):**
  ```bash
  doc-inspect "ruta/al/archivo.pdf" --summary
  ```
  * Muestra: Total de páginas, título, autor, Tabla de Contenidos (TOC/bookmarks) y fragmento de la página 1.
* **Lectura por Rangos de Páginas:**
  * Lee únicamente las páginas necesarias:
    ```bash
    doc-inspect "ruta/al/archivo.pdf" --pages 1-3
    doc-inspect "ruta/al/archivo.pdf" --pages 12
    ```
* **Búsqueda Quirúrgica de Términos:**
  ```bash
  doc-inspect "ruta/al/archivo.pdf" --search "término_a_buscar"
  ```
* **Conversión completa a Markdown (solo para PDFs cortos < 10 págs):**
  ```bash
  markitdown "ruta/al/archivo.pdf"
  ```

---

## 3. Documentos Word (`.docx`)
* **Inspección de Estructura:**
  ```bash
  doc-inspect "ruta/al/documento.docx" --summary
  ```
  * Muestra: Conteo de párrafos, palabras, tablas y el esquema completo de títulos (`Heading 1`, `Heading 2`, etc.).
* **Búsqueda o Conversión a Markdown Limpio:**
  ```bash
  doc-inspect "ruta/al/documento.docx" --search "cláusula"
  markitdown "ruta/al/documento.docx"
  ```

---

## 4. Presentaciones PowerPoint (`.pptx`)
* **Inspección de Diapositivas:**
  ```bash
  doc-inspect "ruta/a/presentacion.pptx" --summary
  ```
  * Muestra: Total de diapositivas y el título de cada una (`Slide 1: ...`, `Slide 2: ...`).
* **Búsqueda y Extracción:**
  ```bash
  doc-inspect "ruta/a/presentacion.pptx" --search "Q3 Results"
  markitdown "ruta/a/presentacion.pptx"
  ```

---

## 5. Tabla de Comandos Rápidos

| Tarea | Comando CLI |
| :--- | :--- |
| **Resumen / Esquema (Cualquier doc)** | `doc-inspect "archivo"` |
| **Páginas específicas de PDF** | `doc-inspect "archivo.pdf" --pages 3-6` |
| **Filtrar filas de Excel** | `doc-inspect "archivo.xlsx" --sheet "Hoja1" --query "filtro"` |
| **Buscar palabra en cualquier doc** | `doc-inspect "archivo" --search "palabra"` |
| **Convertir doc a Markdown puro** | `markitdown "archivo"` |
