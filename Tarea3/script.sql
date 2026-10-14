-- ============================================================
-- RED SOCIAL ESTUDIANTIL PASCUALINA (MySQL)
-- Estudiante: Nathaly Rivas Aristizabal
-- Asignatura: Bases de Datos I (G100)
-- Script DDL de Implementación de la estructura completa de una base de datos
-- ============================================================

-- 1. Creación y selección de la base de datos
CREATE DATABASE IF NOT EXISTS red_social;
USE red_social;

-- 2. Limpieza de tablas previas si existen (en orden inverso de dependencia)
DROP TABLE IF EXISTS asistentes_evento;
DROP TABLE IF EXISTS eventos;
DROP TABLE IF EXISTS miembros_grupo;
DROP TABLE IF EXISTS grupos;
DROP TABLE IF EXISTS publicaciones;
DROP TABLE IF EXISTS conexiones;
DROP TABLE IF EXISTS estudiantes;

-- 3. Tabla principal / padre: estudiantes
CREATE TABLE estudiantes (
    estudiante_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    carrera VARCHAR(100) NOT NULL,
    semestre INT CHECK (semestre > 0 AND semestre <= 12),
    intereses TEXT,
    habilidades TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabla asociativa: conexiones (relación seguir / mentoría entre estudiantes)
CREATE TABLE conexiones (
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    es_mentor BOOLEAN DEFAULT FALSE,
    fecha_conexion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (seguidor_id, seguido_id),
    CONSTRAINT fk_conexion_seguidor FOREIGN KEY (seguidor_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_conexion_seguido FOREIGN KEY (seguido_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. Tabla hija: publicaciones
CREATE TABLE publicaciones (
    publicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    contenido TEXT NOT NULL,
    categoria VARCHAR(50) DEFAULT 'General',
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (estudiante_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. Tabla: grupos
CREATE TABLE grupos (
    grupo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,
    creador_id INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. Tabla asociativa: miembros_grupo
CREATE TABLE miembros_grupo (
    grupo_id INT NOT NULL,
    estudiante_id INT NOT NULL,
    rol VARCHAR(50) DEFAULT 'Miembro',
    fecha_union DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (grupo_id, estudiante_id),
    CONSTRAINT fk_mg_grupo FOREIGN KEY (grupo_id) 
        REFERENCES grupos(grupo_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mg_estudiante FOREIGN KEY (estudiante_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. Tabla: eventos
CREATE TABLE eventos (
    evento_id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_evento DATETIME NOT NULL,
    ubicacion VARCHAR(150),
    organizador_id INT NOT NULL,
    grupo_id INT,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (grupo_id) 
        REFERENCES grupos(grupo_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 9. Tabla asociativa: asistentes_evento
CREATE TABLE asistentes_evento (
    evento_id INT NOT NULL,
    estudiante_id INT NOT NULL,
    estado_confirmacion VARCHAR(30) DEFAULT 'Confirmado',
    PRIMARY KEY (evento_id, estudiante_id),
    CONSTRAINT fk_ae_evento FOREIGN KEY (evento_id) 
        REFERENCES eventos(evento_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ae_estudiante FOREIGN KEY (estudiante_id) 
        REFERENCES estudiantes(estudiante_id) ON DELETE CASCADE ON UPDATE CASCADE
);
