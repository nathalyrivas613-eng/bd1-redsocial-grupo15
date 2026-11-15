-- PROYECTO: Red Social Estudiantil Pascualina
-- AUTORA: Nathaly Rivas Aristizábal

USE red_social_estudiantil;

INSERT INTO estudiante (correo_institucional, password_hash) VALUES
('nathaly.rivas@pascualbravo.edu.co', 'hash_nathaly_2026'),
('samantha.lopez@pascualbravo.edu.co', 'hash_samantha_2026'),
('diego.restrepo@pascualbravo.edu.co', 'hash_diego_2026'),
('mauricio.cardona@pascualbravo.edu.co', 'hash_mauricio_2026'),
('sonia.henao@pascualbravo.edu.co', 'hash_sonia_2026'),
('patricia.velasquez@pascualbravo.edu.co', 'hash_patricia_2026'),
('rodrigo.alvarez@pascualbravo.edu.co', 'hash_rodrigo_2026');

INSERT INTO perfil (id_estudiante, nombre_completo, carrera, semestre, preferencias_intereses) VALUES
(1, 'Nathaly Rivas Aristizabal', 'Ingeniería de Software', 6, '{"modalidad": "Híbrida", "turno": "Noche"}'),
(2, 'Samantha López Quintero', 'Ingeniería de Software', 8, '{"modalidad": "Presencial", "turno": "Tarde"}'),
(3, 'Diego Restrepo Morales', 'Tecnología en Desarrollo de Software', 5, '{"modalidad": "Virtual", "turno": "Noche"}'),
(4, 'Mauricio Cardona Giraldo', 'Ingeniería Mecatrónica', 7, '{"modalidad": "Presencial", "turno": "Mañana"}'),
(5, 'Sonia Henao Zapata', 'Ingeniería de Software', 3, '{"modalidad": "Presencial", "turno": "Tarde"}'),
(6, 'Patricia Velásquez Ortiz', 'Ingeniería Eléctrica', 4, '{"modalidad": "Híbrida", "turno": "Mañana"}'),
(7, 'Rodrigo Álvarez Bedoya', 'Tecnología en Desarrollo de Software', 9, '{"modalidad": "Virtual", "turno": "Noche"}');

INSERT INTO interes (nombre_interes, descripcion) VALUES
('Programación Competitiva', 'Entrenamiento en algoritmos, estructuras de datos y maratones ICPC'),
('Inteligencia Artificial', 'Machine Learning, Deep Learning y procesamiento de lenguaje natural'),
('Desarrollo Web Fullstack', 'Arquitecturas modernas frontend y backend'),
('Videojuegos y E-Sports', 'Diseño de videojuegos y torneos universitarios'),
('Robótica y Automatización', 'Sistemas embebidos, sensores y control');

INSERT INTO habilidad (nombre_habilidad, categoria) VALUES
('SQL y Bases de Datos', 'Datos'),
('Python', 'Programación'),
('JavaScript / React', 'Desarrollo Web'),
('C++', 'Algoritmia'),
('Git y Control de Versiones', 'DevOps');

INSERT INTO estudiante_interes (id_estudiante, id_interes) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 3),
(3, 2), (3, 4),
(4, 1), (4, 5),
(5, 1), (5, 3),
(6, 4), (6, 5),
(7, 1), (7, 2);

INSERT INTO estudiante_habilidad (id_estudiante, id_habilidad, nivel) VALUES
(1, 1, 'Avanzado'), (1, 5, 'Intermedio'),
(2, 1, 'Avanzado'), (2, 2, 'Avanzado'), (2, 3, 'Avanzado'),
(3, 3, 'Intermedio'), (3, 5, 'Básico'),
(4, 2, 'Intermedio'), (4, 4, 'Avanzado'),
(5, 1, 'Básico'), (5, 2, 'Básico'),
(6, 2, 'Intermedio'),
(7, 1, 'Avanzado'), (7, 4, 'Avanzado'), (7, 5, 'Avanzado');

INSERT INTO publicacion (id_estudiante, contenido, tipo_publicacion) VALUES
(1, 'Comparto guía completa de normalización y consultas JOIN en MySQL para el parcial.', 'Recurso'),
(2, '¿Alguien tiene ejercicios resueltos de programación dinámica para practicar este fin de semana?', 'Pregunta'),
(3, 'Nuevo avance en modelos de lenguaje abierto para educación superior.', 'Noticia'),
(5, 'Cuando el SELECT * FROM tabla devuelve 0 filas y te das cuenta que olvidaste el COMMIT.', 'Meme'),
(7, 'Repositorio con plantillas de Git y flujo GitFlow listo para los proyectos de clase.', 'Recurso'),
(4, 'Busco compañeros para armar equipo de robótica aplicada.', 'Pregunta');

INSERT INTO comentario (id_publicacion, id_estudiante, contenido) VALUES
(1, 2, 'Excelente aporte Nathaly, muy claro el uso de los JOIN.'),
(1, 5, 'Justo lo que necesitaba para estudiar hoy, ¡gracias!'),
(2, 7, 'Te paso el enlace de Codeforces con problemas clasificados por dificultad.'),
(4, 3, 'Jajaja tal cual nos pasó ayer con la base de datos.'),
(6, 6, 'Me interesa Mauricio, escríbeme por interno y cuadramos.');

INSERT INTO reaccion (id_publicacion, id_estudiante, tipo_reaccion) VALUES
(1, 2, 'Util'), (1, 3, 'Util'), (1, 5, 'Me gusta'), (1, 7, 'Util'),
(2, 1, 'Interesante'), (2, 4, 'Interesante'), (2, 7, 'Me gusta'),
(3, 1, 'Interesante'), (3, 6, 'Me gusta'),
(4, 1, 'Me gusta'), (4, 2, 'Me gusta'), (4, 3, 'Me gusta'),
(5, 1, 'Util'), (5, 4, 'Util'),
(6, 6, 'Me gusta');

INSERT INTO grupo (nombre, descripcion, tipo) VALUES
('Semillero Programación Competitiva', 'Entrenamiento semanal para maratones ACIS/ICPC', 'Estudio'),
('Hackathon Pascualina 2026', 'Equipo de desarrollo rápido de soluciones web', 'Hackaton'),
('Club de Inteligencia Artificial', 'Lectura de papers y talleres prácticos de IA', 'Club'),
('GamerZone Pascual', 'Torneos internos y diseño de videojuegos', 'Club');

INSERT INTO miembro_grupo (id_grupo, id_estudiante, rol_grupo) VALUES
(1, 1, 'Líder'), (1, 7, 'Mentor'), (1, 4, 'Miembro'), (1, 5, 'Miembro'),
(2, 2, 'Líder'), (2, 1, 'Miembro'), (2, 3, 'Miembro'),
(3, 1, 'Líder'), (3, 3, 'Miembro'), (3, 6, 'Miembro'),
(4, 3, 'Líder'), (4, 6, 'Miembro');

INSERT INTO evento (id_grupo, titulo, fecha_inicio, ubicacion_geo) VALUES
(1, 'Maratón Interna de Algoritmos', '2026-11-20 14:00:00', '{"bloque": "Bloque 5", "aula": "Sala Sistemas 201"}'),
(2, 'Taller Intensivo de Git y SQL', '2026-11-25 18:00:00', '{"bloque": "Virtual", "enlace": "meet.pascualbravo.edu.co/sql"}'),
(3, 'Charla: Aplicaciones de IA en Ingeniería', '2026-12-02 10:00:00', '{"bloque": "Auditorio Principal", "aula": "101"}');

INSERT INTO asistente_evento (id_evento, id_estudiante, estado_asistencia) VALUES
(1, 1, 'Confirmado'), (1, 2, 'Confirmado'), (1, 4, 'Confirmado'), (1, 5, 'Pendiente'), (1, 7, 'Confirmado'),
(2, 1, 'Confirmado'), (2, 2, 'Confirmado'), (2, 3, 'Confirmado'), (2, 5, 'Confirmado'),
(3, 1, 'Confirmado'), (3, 3, 'Confirmado'), (3, 6, 'Confirmado');

INSERT INTO mentoria (id_mentor, id_estudiante, materia_tema, estado) VALUES
(2, 5, 'Bases de Datos Relacionales y SQL', 'Aceptada'),
(1, 3, 'Control de Versiones con Git', 'Finalizada'),
(7, 1, 'Estructuras de Datos Avanzadas', 'Aceptada'),
(4, 6, 'Fundamentos de Programación en Python', 'Pendiente');

INSERT INTO seguimiento (id_seguidor, id_seguido) VALUES
(5, 1), (5, 2), (3, 1), (1, 2), (4, 7), (6, 1), (7, 2);