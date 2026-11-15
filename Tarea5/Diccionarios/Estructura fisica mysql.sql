-- PROYECTO: Red Social Estudiantil Pascualina
-- Institución Universitaria Pascual Bravo
-- AUTORA: Nathaly Rivas Aristizábal

DROP DATABASE IF EXISTS red_social_estudiantil;
CREATE DATABASE red_social_estudiantil CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE red_social_estudiantil;

-- 1. Tabla maestra de credenciales institucionales
CREATE TABLE estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    correo_institucional VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla de perfil académico (Relación 1:1 con estudiante)
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    semestre INT CHECK (semestre > 0),
    preferencias_intereses JSON NULL,
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 3. Catálogo maestro de áreas de interés
CREATE TABLE interes (
    id_interes INT AUTO_INCREMENT PRIMARY KEY,
    nombre_interes VARCHAR(100) NOT NULL,
    descripcion TEXT NULL
);

-- 4. Catálogo maestro de habilidades técnicas y blandas
CREATE TABLE habilidad (
    id_habilidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_habilidad VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NULL
);

-- 5. Tabla de publicaciones en el muro
CREATE TABLE publicacion (
    id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido TEXT NOT NULL,
    tipo_publicacion VARCHAR(30) CHECK (tipo_publicacion IN ('Pregunta', 'Recurso', 'Noticia', 'Meme')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 6. Tabla de comentarios sobre publicaciones
CREATE TABLE comentario (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 7. Tabla de reacciones sobre publicaciones
CREATE TABLE reaccion (
    id_reaccion INT AUTO_INCREMENT PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    tipo_reaccion VARCHAR(20) NULL,
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 8. Tabla de grupos, semilleros y clubes estudiantiles
CREATE TABLE grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    tipo VARCHAR(30) NULL
);

-- 9. Tabla de eventos académicos y culturales
CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT NULL,
    titulo VARCHAR(150) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    ubicacion_geo JSON NULL,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE SET NULL
);

-- 10. Tabla de sesiones de mentoría entre pares
CREATE TABLE mentoria (
    id_mentoria INT AUTO_INCREMENT PRIMARY KEY,
    id_mentor INT NOT NULL,
    id_estudiante INT NOT NULL,
    materia_tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) NULL,
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 11. Tabla recursiva de seguimiento entre estudiantes (N:M)
CREATE TABLE seguimiento (
    id_seguimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seguimiento_seguidor FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_seguimiento_seguido FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 12. Tabla asociativa estudiante - interés (N:M)
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),
    CONSTRAINT fk_ei_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_ei_interes FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

-- 13. Tabla asociativa estudiante - habilidad (N:M)
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(30) DEFAULT 'Básico',
    PRIMARY KEY (id_estudiante, id_habilidad),
    CONSTRAINT fk_eh_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

-- 14. Tabla asociativa miembro - grupo (N:M)
CREATE TABLE miembro_grupo (
    id_grupo INT NOT NULL,
    id_estudiante INT NOT NULL,
    rol_grupo VARCHAR(30) DEFAULT 'Miembro',
    PRIMARY KEY (id_grupo, id_estudiante),
    CONSTRAINT fk_mg_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_mg_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 15. Tabla asociativa asistente - evento (N:M)
CREATE TABLE asistente_evento (
    id_evento INT NOT NULL,
    id_estudiante INT NOT NULL,
    estado_asistencia VARCHAR(20) DEFAULT 'Pendiente',
    PRIMARY KEY (id_evento, id_estudiante),
    CONSTRAINT fk_ae_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT fk_ae_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);