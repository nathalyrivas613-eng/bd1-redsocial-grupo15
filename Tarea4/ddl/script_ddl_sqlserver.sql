-- Nathaly Rivas Aristizabal

 CREATE TABLE estudiante (
  id_estudiante INT IDENTITY (1,1) PRIMARY KEY, 
  correo_institucional VARCHAR (100) NOT NULL UNIQUE, 
  password_hash VARCHAR (255) NOT NULL,
  fecha_registro DATETIME DEFAULT GETDATE()
 );

 CREATE TABLE perfil (
    id_perfil INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    nombre_completo VARCHAR(150) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    semestre INT CHECK (semestre > 0),
    preferencias_intereses NVARCHAR(MAX) NULL,
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

CREATE TABLE interes (
    id_interes INT IDENTITY(1,1) PRIMARY KEY,
    nombre_interes VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX) NULL
);

CREATE TABLE habilidad (
    id_habilidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_habilidad VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NULL
);

CREATE TABLE publicacion (
    id_publicacion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(MAX) NOT NULL,
    tipo_publicacion VARCHAR(30) CHECK (tipo_publicacion IN ('Pregunta', 'Recurso', 'Noticia', 'Meme')),
    fecha_creacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE
);

CREATE TABLE comentario (
    id_comentario INT IDENTITY(1,1) PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    contenido VARCHAR(MAX) NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);

CREATE TABLE reaccion (
    id_reaccion INT IDENTITY(1,1) PRIMARY KEY,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    tipo_reaccion VARCHAR(20) CHECK (tipo_reaccion IN ('Me gusta', 'Util', 'Interesante')),
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);

CREATE TABLE grupo (
    id_grupo INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX) NULL,
    tipo VARCHAR(30) CHECK (tipo IN ('Estudio', 'Hackaton', 'Club'))
);

CREATE TABLE evento (
    id_evento INT IDENTITY(1,1) PRIMARY KEY,
    id_grupo INT NULL,
    titulo VARCHAR(150) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    ubicacion_geo NVARCHAR(MAX) NULL,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE SET NULL
);

CREATE TABLE mentoria (
    id_mentoria INT IDENTITY(1,1) PRIMARY KEY,
    id_mentor INT NOT NULL,
    id_estudiante INT NOT NULL,
    materia_tema VARCHAR(100) NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('Pendiente', 'Aceptada', 'Finalizada')),
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante),
    CONSTRAINT fk_mentoria_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);

CREATE TABLE seguimiento (
    id_seguimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_seguimiento_seguidor FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante),
    CONSTRAINT fk_seguimiento_seguido FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante)
);

CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    PRIMARY KEY (id_estudiante, id_interes),
    CONSTRAINT fk_ei_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_ei_interes FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE
);

CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(30) DEFAULT 'Básico',
    PRIMARY KEY (id_estudiante, id_habilidad),
    CONSTRAINT fk_eh_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE
);

CREATE TABLE miembro_grupo (
    id_grupo INT NOT NULL,
    id_estudiante INT NOT NULL,
    rol_grupo VARCHAR(30) DEFAULT 'Miembro',
    PRIMARY KEY (id_grupo, id_estudiante),
    CONSTRAINT fk_mg_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_mg_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);

CREATE TABLE asistente_evento (
    id_evento INT NOT NULL,
    id_estudiante INT NOT NULL,
    estado_asistencia VARCHAR(20) DEFAULT 'Confirmado',
    PRIMARY KEY (id_evento, id_estudiante),
    CONSTRAINT fk_ae_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE,
    CONSTRAINT fk_ae_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);
SELECT 
    TABLE_NAME AS tabla,
    STRING_AGG(COLUMN_NAME + ' (' + DATA_TYPE + ')', ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) AS atributos
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;
