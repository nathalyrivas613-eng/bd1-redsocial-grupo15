-- ============================================================================
-- PROYECTO: Red social estudiantil pascualina 
-- AUTORA: Nathaly Rivas Aristizábal
-- ARCHIVO: DDL_arquitectura_hibrida.sql
-- ============================================================================

SET client_min_messages TO WARNING;

-- ----------------------------------------------------------------------------
-- SECCIÓN 1: NÚCLEO RELACIONAL Y PERFILES SEMIESTRUCTURADOS 
-- ----------------------------------------------------------------------------
-- Tabla maestra de credenciales institucionales
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    correo_institucional VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Perfil académico con preferencias flexibles almacenadas en formato JSONB
CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    semestre INT CHECK (semestre > 0),
    preferencias_intereses JSONB
);
-- Catálogo maestro de áreas de interés académico y tecnológico
CREATE TABLE interes (
    id_interes SERIAL PRIMARY KEY,
    nombre_interes VARCHAR(100) NOT NULL,
    descripcion TEXT
);
-- Catálogo maestro de habilidades técnicas y blandas
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(100) NOT NULL,
    categoria VARCHAR(50)
);
-- Publicaciones estudiantiles con metadatos multimedia y hashtags en JSONB
CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    tipo_publicacion VARCHAR(30) CHECK (tipo_publicacion IN ('Pregunta', 'Recurso', 'Noticia', 'Meme')),
    metadatos_multimedia JSONB,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Comentarios asociados a publicaciones
CREATE TABLE comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Reacciones rápidas (Me gusta, Me encanta) sobre publicaciones
CREATE TABLE reaccion (
    id_reaccion SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    tipo_reaccion VARCHAR(20)
);
-- Comunidades, semilleros de investigación y grupos estudiantiles
CREATE TABLE grupo (
    id_grupo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(30)
);
-- Eventos académicos con geolocalización y aforo máximo en JSONB
CREATE TABLE evento (
    id_evento SERIAL PRIMARY KEY,
    id_grupo INT REFERENCES grupo(id_grupo) ON DELETE SET NULL,
    titulo VARCHAR(150) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    ubicacion_geo JSONB
);
-- Sistema de mentorías académicas entre pares
CREATE TABLE mentoria (
    id_mentoria SERIAL PRIMARY KEY,
    id_mentor INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    materia_tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20)
);
-- Grafo social de conexiones (seguidor -> seguido)
CREATE TABLE seguimiento (
    id_seguimiento SERIAL PRIMARY KEY,
    id_seguidor INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_seguido INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ----------------------------------------------------------------------------
-- SECCIÓN 2: TABLAS ASOCIATIVAS 
-- ----------------------------------------------------------------------------
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_interes INT NOT NULL REFERENCES interes(id_interes) ON DELETE CASCADE,
    PRIMARY KEY (id_estudiante, id_interes)
);
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    id_habilidad INT NOT NULL REFERENCES habilidad(id_habilidad) ON DELETE CASCADE,
    nivel VARCHAR(30) DEFAULT 'Básico',
    PRIMARY KEY (id_estudiante, id_habilidad)
);
CREATE TABLE miembro_grupo (
    id_grupo INT NOT NULL REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    rol_grupo VARCHAR(30) DEFAULT 'Miembro',
    PRIMARY KEY (id_grupo, id_estudiante)
);
CREATE TABLE asistente_evento (
    id_evento INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_estudiante INT NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    estado_asistencia VARCHAR(20) DEFAULT 'Pendiente',
    PRIMARY KEY (id_evento, id_estudiante)
);
-- ----------------------------------------------------------------------------
-- SECCIÓN 3: CAPA CAMPUS INTELIGENTE 
-- ----------------------------------------------------------------------------
-- Inventario de sensores físicos desplegados en los bloques de la institución
CREATE TABLE dispositivo_iot (
    id_dispositivo SERIAL PRIMARY KEY,
    codigo_hardware VARCHAR(50) UNIQUE NOT NULL,
    tipo_sensor VARCHAR(40) NOT NULL,
    ubicacion_bloque VARCHAR(50) NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activo'
);
-- Ingesta masiva de tramas heterogéneas enviadas por dispositivos IoT
CREATE TABLE telemetria_iot (
    id_telemetria BIGSERIAL PRIMARY KEY,
    id_dispositivo INT NOT NULL REFERENCES dispositivo_iot(id_dispositivo) ON DELETE CASCADE,
    id_evento INT REFERENCES evento(id_evento) ON DELETE SET NULL,
    id_estudiante INT REFERENCES estudiante(id_estudiante) ON DELETE SET NULL,
    fecha_lectura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payload_sensor JSONB NOT NULL
);
-- ----------------------------------------------------------------------------
-- SECCIÓN 4: OPTIMIZACIÓN E INDEXACIÓN 
-- ----------------------------------------------------------------------------
-- Índices GIN para consultas de contención (@>) sobre documentos JSONB
CREATE INDEX idx_perfil_pref_gin ON perfil USING GIN (preferencias_intereses);
CREATE INDEX idx_pub_meta_gin ON publicacion USING GIN (metadatos_multimedia);
CREATE INDEX idx_evento_geo_gin ON evento USING GIN (ubicacion_geo);
CREATE INDEX idx_tel_payload_gin ON telemetria_iot USING GIN (payload_sensor);

-- Índices B-Tree para series temporales IoT y llaves foráneas frecuentes
CREATE INDEX idx_tel_fecha ON telemetria_iot (fecha_lectura);
CREATE INDEX idx_pub_est ON publicacion (id_estudiante);
