-- Nathaly Rivas Aristizabal

-- 1. Entidad: estudiante
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    correo_institucional VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Entidad: perfil
CREATE TABLE perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    semestre INT CHECK (semestre > 0),
    preferencias_intereses JSONB NULL,
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 3. Entidad: interes
CREATE TABLE interes (
    id_interes SERIAL PRIMARY KEY,
    nombre_interes VARCHAR(100) NOT NULL,
    descripcion TEXT NULL
);

-- 4. Entidad: habilidad
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_habilidad VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NULL
);

-- 5. Entidad: publicacion
CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido TEXT NOT NULL,
    tipo_publicacion VARCHAR(30) CHECK (tipo_publicacion IN ('Pregunta', 'Recurso', 'Noticia', 'Meme')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 6. Entidad: comentario
CREATE TABLE comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 7. Entidad: reaccion
CREATE TABLE reaccion (
    id_reaccion SERIAL PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    tipo_reaccion VARCHAR(20) CHECK (tipo_reaccion IN ('Me gusta', 'Util', 'Interesante')),
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 8. Entidad: grupo
CREATE TABLE grupo (
    id_grupo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    tipo VARCHAR(30) CHECK (tipo IN ('Estudio', 'Hackaton', 'Club'))
);

-- 9. Entidad: evento
CREATE TABLE evento (
    id_evento SERIAL PRIMARY KEY,
    id_grupo INT NULL,
    titulo VARCHAR(150) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    ubicacion_geo JSONB NULL,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE SET NULL
);

-- 10. Entidad: mentoria
CREATE TABLE mentoria (
    id_mentoria SERIAL PRIMARY KEY,
    id_mentor INT NOT NULL,
    id_estudiante INT NOT NULL,
    materia_tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('Pendiente', 'Aceptada', 'Finalizada')),
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_mentoria_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 11. Entidad: seguimiento
CREATE TABLE seguimiento (
    id_seguimiento SERIAL PRIMARY KEY,
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seguimiento_seguidor FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_seguimiento_seguido FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 12. Interseccion: estudiante_interes
CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),
    CONSTRAINT fk_ei_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_ei_interes FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

-- 13. Interseccion: estudiante_habilidad
CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(30) DEFAULT 'Básico',
    PRIMARY KEY (id_estudiante, id_habilidad),
    CONSTRAINT fk_eh_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

-- 14. Interseccion: miembro_grupo
CREATE TABLE miembro_grupo (
    id_grupo INT NOT NULL,
    id_estudiante INT NOT NULL,
    rol_grupo VARCHAR(30) DEFAULT 'Miembro',
    PRIMARY KEY (id_grupo, id_estudiante),
    CONSTRAINT fk_mg_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_mg_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

-- 15. Interseccion: asistente_evento
CREATE TABLE asistente_evento (
    id_evento INT NOT NULL,
    id_estudiante INT NOT NULL,
    estado_asistencia VARCHAR(20) DEFAULT 'Confirmado',
    PRIMARY KEY (id_evento, id_estudiante),
    CONSTRAINT fk_ae_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT fk_ae_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT 
    table_name AS tabla,
    string_agg(column_name || ' (' || data_type || ')', ', ') AS atributos
FROM information_schema.columns 
WHERE table_schema = 'public' 
GROUP BY table_name
ORDER BY table_name;
SELECT 
 
