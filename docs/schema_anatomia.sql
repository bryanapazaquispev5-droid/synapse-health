-- ================================================================================
-- PROYECTO: SYNAPSE HEALTH - MODELADO DE BASE DE DATOS (ANATOMÍA HUMANA)
-- ARQUITECTURA RELACIONAL: ESTRICTAMENTE 1:N (CERO RELACIONES MUCHOS A MUCHOS)
-- ================================================================================
-- Justificación de Arquitectura:
-- Para optimizar el rendimiento móvil, garantizar la integridad referencial y
-- simplificar las consultas de alta velocidad en la app ("Regla de los 2 toques"),
-- se prohíben las tablas intermedias y las relaciones Muchos a Muchos (N:M).
--
-- Toda la jerarquía es estrictamente padre-hijo (1 a Muchos):
--   [medical_areas] 1 ────< N [topics] 1 ────< N [cheatsheets]
-- ================================================================================

-- 1. TABLA: ÁREAS MÉDICAS (medical_areas)
-- Representa las grandes ramas de estudio (ej. Anatomía Humana, Farmacología).
CREATE TABLE IF NOT EXISTS medical_areas (
    id VARCHAR(50) PRIMARY KEY,               -- Identificador único (ej. 'anatomia')
    name VARCHAR(100) NOT NULL,              -- Nombre visible (ej. 'Anatomía Humana')
    code VARCHAR(20) NOT NULL UNIQUE,         -- Código de referencia (ej. 'ANATOMIA')
    order_index INT NOT NULL DEFAULT 1,       -- Orden de visualización en la interfaz
    topics_count INT NOT NULL DEFAULT 0,      -- Contador desnormalizado para visualización rápida
    cheatsheets_count INT NOT NULL DEFAULT 0, -- Total de chuletas disponibles
    quizzes_count INT NOT NULL DEFAULT 0,     -- Total de preguntas de quiz
    is_available BOOLEAN NOT NULL DEFAULT TRUE, -- Bandera de disponibilidad
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLA: TEMAS CLÍNICOS (topics)
-- Relación 1:N estricta: Cada tema pertenece a UNA y sólo una área médica.
CREATE TABLE IF NOT EXISTS topics (
    id VARCHAR(50) PRIMARY KEY,               -- Identificador único (ej. 'osteologia_craneo')
    area_id VARCHAR(50) NOT NULL,             -- Clave Foránea 1:N hacia medical_areas
    title VARCHAR(150) NOT NULL,             -- Título del tema (ej. 'Osteología del Cráneo')
    description TEXT,                         -- Breve descripción introductoria
    order_index INT NOT NULL DEFAULT 1,       -- Orden dentro del área
    cheatsheets_count INT NOT NULL DEFAULT 0, -- Chuletas en este tema
    quizzes_count INT NOT NULL DEFAULT 0,     -- Quizzes en este tema
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_topics_area FOREIGN KEY (area_id) 
        REFERENCES medical_areas(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Índice para optimizar consultas de temas por área
CREATE INDEX IF NOT EXISTS idx_topics_area_id ON topics(area_id);

-- 3. TABLA: CHULETAS DE ALTO RENDIMIENTO (cheatsheets)
-- Relación 1:N estricta: Cada chuleta pertenece a UN tema específico.
-- NO existe relación muchos a muchos: Una chuleta no se comparte entre temas independientes.
CREATE TABLE IF NOT EXISTS cheatsheets (
    id VARCHAR(50) PRIMARY KEY,               -- Identificador único (ej. 'esfenoides_orificios')
    topic_id VARCHAR(50) NOT NULL,            -- Clave Foránea 1:N hacia topics
    area_id VARCHAR(50) NOT NULL,             -- Clave de alcance directo 1:N hacia medical_areas
    title VARCHAR(150) NOT NULL,             -- Título de la chuleta
    summary VARCHAR(255) NOT NULL,           -- Resumen clínico conciso (1 a 2 líneas)
    content_markdown TEXT NOT NULL,          -- Contenido estructurado en Markdown
    key_points_json TEXT NOT NULL,           -- Puntos clave de alto rendimiento (Array JSON)
    mnemonics_json TEXT NOT NULL,            -- Reglas mnemotécnicas asociadas (Array JSON)
    read_minutes INT NOT NULL DEFAULT 2,     -- Tiempo estimado de lectura rápida (minutos)
    is_premium BOOLEAN NOT NULL DEFAULT FALSE,-- Control de acceso Freemium
    source_book VARCHAR(150) NOT NULL,       -- Libro fuente (ej. 'Rouvière Tomo 1: Cabeza y Cuello')
    order_index INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cheatsheets_topic FOREIGN KEY (topic_id) 
        REFERENCES topics(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_cheatsheets_area FOREIGN KEY (area_id) 
        REFERENCES medical_areas(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Índices de consulta rápida
CREATE INDEX IF NOT EXISTS idx_cheatsheets_topic_id ON cheatsheets(topic_id);
CREATE INDEX IF NOT EXISTS idx_cheatsheets_area_id ON cheatsheets(area_id);
