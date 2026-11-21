-- ============================================================================
-- PROYECTO: Red social estudiantil pascualina 
-- AUTORA: Nathaly Rivas Aristizábal
-- ARCHIVO: DML_datos_y_consultas.sql
-- ============================================================================
-- ----------------------------------------------------------------------------
-- SECCIÓN 1: INSERCIÓN DE DATOS MAESTROS Y PERFILES HÍBRIDOS 
-- ----------------------------------------------------------------------------
-- Registro de estudiantes institucionales
INSERT INTO estudiante (correo_institucional, password_hash) VALUES
('rodrigo.alvarez@pascualbravo.edu.co', 'hash_01'),
('samantha.lopez@pascualbravo.edu.co', 'hash_02'),
('mauricio.cardona@pascualbravo.edu.co', 'hash_03'),
('nathaly.rivas@pascualbravo.edu.co', 'hash_04'),
('sonia.henao@pascualbravo.edu.co', 'hash_05');
-- Perfiles académicos con preferencias personalizadas en JSONB
INSERT INTO perfil (id_estudiante, nombre_completo, carrera, semestre, preferencias_intereses) VALUES
(1, 'Rodrigo Álvarez Bedoya', 'Tecnología en Desarrollo de Software', 9,
 jsonb_build_object('tema', 'oscuro', 'tags', jsonb_build_array('ProgramacionCompetitiva'))),
(2, 'Samantha López Quintero', 'Ingeniería de Software', 8,
 jsonb_build_object('tema', 'claro', 'tags', jsonb_build_array('ProgramacionCompetitiva', 'PostgreSQL'))),
(3, 'Mauricio Cardona Giraldo', 'Ingeniería Mecatrónica', 7,
 jsonb_build_object('tema', 'oscuro', 'tags', jsonb_build_array('ProgramacionCompetitiva', 'IoT'))),
(4, 'Nathaly Rivas Aristizábal', 'Ingeniería de Software', 6,
 jsonb_build_object('tema', 'oscuro', 'tags', jsonb_build_array('BigData', 'PostgreSQL'))),
(5, 'Sonia Henao Zapata', 'Ingeniería de Software', 3,
 jsonb_build_object('tema', 'claro', 'tags', jsonb_build_array('ProgramacionCompetitiva')));
-- Catálogo de intereses y vinculación N:M
INSERT INTO interes (nombre_interes, descripcion) VALUES
('Programación Competitiva', 'Maratones de programación');
INSERT INTO estudiante_interes VALUES (1,1), (2,1), (3,1), (4,1), (5,1);
-- ----------------------------------------------------------------------------
-- SECCIÓN 2: COMUNIDADES, EVENTOS GEOLOCALIZADOS E INTERACCIONES SOCIALES
-- ----------------------------------------------------------------------------
-- Creación de semillero académico
INSERT INTO grupo (nombre, descripcion, tipo) VALUES
('Semillero de Datos e IA', 'Big Data e IoT Pascual Bravo', 'Semillero');
-- Eventos con ubicación física y aforo máximo en formato JSONB
INSERT INTO evento (id_grupo, titulo, fecha_inicio, ubicacion_geo) VALUES
(1, 'Maratón de Bases de Datos Híbridas', '2026-11-25 14:00:00',
 jsonb_build_object('bloque', 'Bloque 12', 'aula', '302', 'aforo_maximo', 40)),
(1, 'Taller Campus Inteligente IoT', '2026-12-02 08:00:00',
 jsonb_build_object('bloque', 'Auditorio', 'aula', '101', 'aforo_maximo', 120));
-- Publicaciones con metadatos variables.
INSERT INTO publicacion (id_estudiante, contenido, tipo_publicacion, metadatos_multimedia) VALUES
(4, 'Guía de arquitectura híbrida con PostgreSQL y JSONB.', 'Recurso',
 jsonb_build_object('archivo', 'arquitectura_hibrida.pdf', 'hashtags', jsonb_build_array('#BigData', '#PostgreSQL'), 'vistas', 145)),
(3, 'Sensores ESP32 para el campus inteligente.', 'Pregunta',
 jsonb_build_object('imagenes', jsonb_build_array('esp32.jpg'), 'hashtags', jsonb_build_array('#IoT'), 'vistas', 98)),
(1, 'Ejercicios de grafos y programación dinámica.', 'Recurso',
 jsonb_build_object('archivo', 'grafos_dp.pdf', 'hashtags', jsonb_build_array('#Algoritmos'), 'vistas', 160)),
(2, 'Optimizando consultas JSONB con índices GIN.', 'Noticia',
 jsonb_build_object('hashtags', jsonb_build_array('#PostgreSQL'), 'vistas', 84)),
(5, 'Apuntes de estructuras de datos y SQL analítico.', 'Recurso',
 jsonb_build_object('archivo', 'estructuras.pdf', 'hashtags', jsonb_build_array('#PostgreSQL'), 'vistas', 72));
-- Reacciones de estudiantes sobre las publicaciones
INSERT INTO reaccion (id_publicacion, id_estudiante, tipo_reaccion) VALUES
(1,1,'Me encanta'), (1,2,'Me gusta'), (1,3,'Me encanta'),
(2,4,'Me gusta'), (3,4,'Me encanta'), (3,5,'Me gusta'), (4,4,'Me gusta');
-- ----------------------------------------------------------------------------
-- SECCIÓN 3: DISPOSITIVOS IoT Y TELEMETRÍA EN TIEMPO REAL
-- ----------------------------------------------------------------------------
-- Registro de sensores físicos del campus
INSERT INTO dispositivo_iot (codigo_hardware, tipo_sensor, ubicacion_bloque) VALUES
('NFC-B12-302', 'Lector_NFC', 'Bloque 12 - Aula 302'),
('CAM-B12-302', 'Camara_Aforo', 'Bloque 12 - Aula 302'),
('ENV-BIB-01', 'Sensor_Ambiental', 'Biblioteca Central');
-- Tramas heterogéneas enviadas por lectores NFC, cámaras y sensores ambientales
INSERT INTO telemetria_iot (id_dispositivo, id_evento, id_estudiante, payload_sensor) VALUES
(1, 1, 1, jsonb_build_object('evento_nfc', 'check_in', 'latencia_ms', 12)),
(1, 1, 2, jsonb_build_object('evento_nfc', 'check_in', 'latencia_ms', 15)),
(1, 1, 3, jsonb_build_object('evento_nfc', 'check_in', 'latencia_ms', 11)),
(1, 1, 4, jsonb_build_object('evento_nfc', 'check_in', 'latencia_ms', 13)),
(1, 1, 5, jsonb_build_object('evento_nfc', 'check_in', 'latencia_ms', 14)),
(2, 1, NULL, jsonb_build_object('personas_detectadas', 34, 'estado_aforo', 'Alto')),
(3, NULL, NULL, jsonb_build_object('temperatura_c', 21.8, 'humedad_pct', 54));
-- ----------------------------------------------------------------------------
-- SECCIÓN 4: CONSULTAS ANALÍTICAS
-- ----------------------------------------------------------------------------
-- CONSULTA 1: Consolidado de publicaciones, vistas JSONB y reacciones por carrera
SELECT pf.carrera,
       COUNT(DISTINCT pb.id_publicacion) AS publicaciones,
       SUM((pb.metadatos_multimedia->>'vistas')::INT) AS vistas_json,
       COUNT(r.id_reaccion) AS reacciones
FROM perfil pf
JOIN publicacion pb ON pf.id_estudiante = pb.id_estudiante
LEFT JOIN reaccion r ON pb.id_publicacion = r.id_publicacion
GROUP BY pf.carrera
ORDER BY vistas_json DESC;
-- CONSULTA 2: Búsqueda de publicaciones por hashtag usando índice GIN (@>)
SELECT pf.nombre_completo AS autor,
       pb.tipo_publicacion,
       COALESCE(pb.metadatos_multimedia->>'archivo', 'Sin adjunto') AS recurso,
       (pb.metadatos_multimedia->>'vistas')::INT AS vistas
FROM publicacion pb
JOIN perfil pf ON pb.id_estudiante = pf.id_estudiante
WHERE pb.metadatos_multimedia @> '{"hashtags": ["#PostgreSQL"]}'
ORDER BY vistas DESC;
-- CONSULTA 3: Control de asistencia física (NFC IoT) vs. aforo máximo (JSONB)
SELECT e.titulo AS evento,
       e.ubicacion_geo->>'bloque' AS bloque,
       (e.ubicacion_geo->>'aforo_maximo')::INT AS aforo,
       COUNT(t.id_telemetria) AS ingresos_nfc,
       ROUND((COUNT(t.id_telemetria)::NUMERIC / (e.ubicacion_geo->>'aforo_maximo')::INT) * 100, 2) AS ocupacion_pct
FROM evento e
JOIN telemetria_iot t ON e.id_evento = t.id_evento
JOIN dispositivo_iot d ON t.id_dispositivo = d.id_dispositivo
WHERE d.tipo_sensor = 'Lector_NFC'
GROUP BY e.id_evento, e.titulo, e.ubicacion_geo;
-- CONSULTA 4: Promedio de ocupación y temperatura ambiental por bloque del campus
SELECT d.ubicacion_bloque,
       d.tipo_sensor,
       COUNT(t.id_telemetria) AS lecturas,
       ROUND(AVG((t.payload_sensor->>'personas_detectadas')::NUMERIC), 1) AS prom_personas,
       ROUND(AVG((t.payload_sensor->>'temperatura_c')::NUMERIC), 1) AS temp_prom_c
FROM dispositivo_iot d
JOIN telemetria_iot t ON d.id_dispositivo = t.id_dispositivo
GROUP BY d.ubicacion_bloque, d.tipo_sensor
ORDER BY d.ubicacion_bloque;
