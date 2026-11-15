-- PROYECTO: Red Social Estudiantil Pascualina
-- AUTORA: Nathaly Rivas Aristizábal

USE red_social_estudiantil;

-- PARTE 1: CONSULTAS DML SIGNIFICATIVAS DEL MODELO DE NEGOCIO
-- ----------------------------------------------------------------------------
-- CONSULTA 1: Talento estudiantil en programación competitiva
-- PREGUNTA DE NEGOCIO: ¿Qué estudiantes de la plataforma tienen registrado como
-- interés la "Programación Competitiva" y en qué semestre académico se 
-- encuentran actualmente para poder convocarlos a las maratones?
-- ----------------------------------------------------------------------------
SELECT 
    p.nombre_completo AS nombre_estudiante,
    e.correo_institucional AS correo,
    p.carrera,
    p.semestre AS semestre_actual,
    i.nombre_interes AS interes_registrado
FROM estudiante e
INNER JOIN perfil p ON e.id_estudiante = p.id_estudiante
INNER JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
INNER JOIN interes i ON ei.id_interes = i.id_interes
WHERE i.nombre_interes = 'Programación Competitiva'
ORDER BY p.semestre DESC;
-- ----------------------------------------------------------------------------
-- CONSULTA 2: Popularidad y tamaño de las comunidades estudiantiles
-- PREGUNTA DE NEGOCIO: ¿Cuál es el ranking de grupos o semilleros de la red 
-- social ordenados desde el que tiene mayor cantidad de miembros inscritos 
-- hasta el de menor participación?
-- ----------------------------------------------------------------------------
SELECT 
    g.nombre AS nombre_grupo,
    g.tipo AS categoria_grupo,
    COUNT(mg.id_estudiante) AS total_miembros
FROM grupo g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
GROUP BY g.id_grupo, g.nombre, g.tipo
ORDER BY total_miembros DESC;
-- ----------------------------------------------------------------------------
-- CONSULTA 3: Nivel de interacción y alcance de las publicaciones en el muro
-- PREGUNTA DE NEGOCIO:¿Qué tipo de publicaciones y autores logran mayor respuesta participativa
-- por parte de la comunidad universitaria al sumar valoraciones rápidas y hilos de comentarios?
-- ----------------------------------------------------------------------------
SELECT 
    pub.id_publicacion,
    p.nombre_completo AS autor,
    pub.tipo_publicacion AS categoria,
    LEFT(pub.contenido, 45) AS extracto_contenido,
    COUNT(DISTINCT r.id_reaccion) AS total_reacciones,
    COUNT(DISTINCT c.id_comentario) AS total_comentarios,
    (COUNT(DISTINCT r.id_reaccion) + COUNT(DISTINCT c.id_comentario)) AS indice_interaccion
FROM publicacion pub
INNER JOIN perfil p ON pub.id_estudiante = p.id_estudiante
LEFT JOIN reaccion r ON pub.id_publicacion = r.id_publicacion
LEFT JOIN comentario c ON pub.id_publicacion = c.id_publicacion
GROUP BY pub.id_publicacion, p.nombre_completo, pub.tipo_publicacion, pub.contenido
ORDER BY indice_interaccion DESC;
-- ----------------------------------------------------------------------------
-- CONSULTA 4: Reconocimiento de mentores académicos activos
-- PREGUNTA DE NEGOCIO ¿Cómo consolidar el historial de mentores activos en Pascualina, detallando 
-- en un solo registro las materias impartidas por cada tutor y su volumen de mentorías efectivas? 
-- ----------------------------------------------------------------------------
SELECT 
    p.nombre_completo AS nombre_mentor,
    p.carrera,
    p.semestre,
    COUNT(m.id_mentoria) AS mentorias_efectivas,
    GROUP_CONCAT(m.materia_tema SEPARATOR ' | ') AS temas_impartidos
FROM mentoria m
INNER JOIN perfil p ON m.id_mentor = p.id_estudiante
WHERE m.estado IN ('Aceptada', 'Finalizada')
GROUP BY m.id_mentor, p.nombre_completo, p.carrera, p.semestre
HAVING COUNT(m.id_mentoria) >= 1
ORDER BY mentorias_efectivas DESC;
-- ----------------------------------------------------------------------------
-- CONSULTA 5: Control logístico y confirmación de asistencia a eventos
-- PREGUNTA DE NEGOCIO: ¿Qué nivel de confirmación real tienen los eventos próximos a realizarse en
--  el Pascual y cuál es la comunidad estudiantil responsable de cada convocatoria?
-- ----------------------------------------------------------------------------
SELECT 
    ev.titulo AS nombre_evento,
    COALESCE(g.nombre, 'Evento General Institucional') AS grupo_organizador,
    ev.fecha_inicio AS fecha_hora,
    COUNT(ae.id_estudiante) AS asistentes_confirmados
FROM evento ev
LEFT JOIN grupo g ON ev.id_grupo = g.id_grupo
LEFT JOIN asistente_evento ae ON ev.id_evento = ae.id_evento AND ae.estado_asistencia = 'Confirmado'
GROUP BY ev.id_evento, ev.titulo, g.nombre, ev.fecha_inicio
ORDER BY ev.fecha_inicio ASC;
-- ----------------------------------------------------------------------------
-- CONSULTA 6: Estudiantes con participación superior al promedio general 
-- PREGUNTA DE NEGOCIO: ¿Qué estudiantes mantienen un ritmo de participación igual o superior 
-- al promedio general de toda la comunidad sumando publicaciones, comentarios y reacciones para 
-- seleccionarlos como embajadores de Pascualina?
-- -----------------------------------------------------------------------------
WITH actividad_estudiantes AS (
    SELECT 
        e.id_estudiante,
        p.nombre_completo AS nombre_estudiante,
        p.carrera,
        p.semestre,
        (SELECT COUNT(*) FROM publicacion pub WHERE pub.id_estudiante = e.id_estudiante) AS total_publicaciones,
        (SELECT COUNT(*) FROM comentario com WHERE com.id_estudiante = e.id_estudiante) AS total_comentarios,
        (SELECT COUNT(*) FROM reaccion reac WHERE reac.id_estudiante = e.id_estudiante) AS total_reacciones
    FROM estudiante e
    INNER JOIN perfil p ON e.id_estudiante = p.id_estudiante
)
SELECT 
    nombre_estudiante,
    carrera,
    semestre,
    total_publicaciones,
    total_comentarios,
    total_reacciones,
    (total_publicaciones + total_comentarios + total_reacciones) AS puntaje_participacion_total
FROM actividad_estudiantes
WHERE (total_publicaciones + total_comentarios + total_reacciones) >= (
    SELECT AVG(total_publicaciones + total_comentarios + total_reacciones) 
    FROM actividad_estudiantes
)
ORDER BY puntaje_participacion_total DESC;

-- PARTE 2: CUATRO VISTAS ANALÍTICAS CREADAS 
-- ----------------------------------------------------------------------------
-- VISTA 1: vw_perfiles_habilidades
-- OBJETIVO: Unificar la ficha académica (carrera, semestre) con el catálogo estandarizado
--  de habilidades para diagnosticar qué tecnologías dominan los estudiantes según su programa académico.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_perfiles_habilidades AS
SELECT 
    e.id_estudiante,
    p.nombre_completo AS estudiante,
    e.correo_institucional AS correo,
    p.carrera,
    p.semestre,
    h.nombre_habilidad AS habilidad,
    h.categoria AS area_habilidad,
    eh.nivel AS nivel_dominio
FROM estudiante e
INNER JOIN perfil p ON e.id_estudiante = p.id_estudiante
INNER JOIN estudiante_habilidad eh ON e.id_estudiante = eh.id_estudiante
INNER JOIN habilidad h ON eh.id_habilidad = h.id_habilidad;

-- Consulta de validación de la Vista 1:
SELECT * FROM vw_perfiles_habilidades WHERE nivel_dominio = 'Avanzado';
-- ----------------------------------------------------------------------------
-- VISTA 2: vw_analitica_participacion_estudiante
-- OBJETIVO: Facilitar reportes rápidos de participación individual sin necesidad de escribir
-- cuatro subconsultas correlacionadas cada vez que bienestar universitario evalúe la actividad de los usuarios.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_analitica_participacion_estudiante AS
SELECT 
    e.id_estudiante,
    p.nombre_completo AS estudiante,
    p.carrera,
    (SELECT COUNT(*) FROM publicacion pub WHERE pub.id_estudiante = e.id_estudiante) AS publicaciones_creadas,
    (SELECT COUNT(*) FROM comentario com WHERE com.id_estudiante = e.id_estudiante) AS comentarios_realizados,
    (SELECT COUNT(*) FROM seguimiento seg WHERE seg.id_seguido = e.id_estudiante) AS total_seguidores,
    (SELECT COUNT(*) FROM miembro_grupo mg WHERE mg.id_estudiante = e.id_estudiante) AS grupos_inscritos
FROM estudiante e
INNER JOIN perfil p ON e.id_estudiante = p.id_estudiante;

-- Consulta de validación de la Vista 2:
SELECT * FROM vw_analitica_participacion_estudiante ORDER BY publicaciones_creadas DESC;
-- ----------------------------------------------------------------------------
-- VISTA 3: vw_rendimiento_grupos_eventos
-- OBJETIVO: Detectar de inmediato qué grupos transforman sus miembros en eventos
-- reales con alta asistencia y cuáles comunidades están inactivas y requieren acompañamiento.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_rendimiento_grupos_eventos AS
SELECT 
    g.id_grupo,
    g.nombre AS grupo,
    g.tipo AS tipo_grupo,
    COUNT(DISTINCT mg.id_estudiante) AS cantidad_miembros,
    COUNT(DISTINCT ev.id_evento) AS eventos_programados,
    COUNT(DISTINCT ae.id_estudiante) AS total_asistentes_confirmados
FROM grupo g
LEFT JOIN miembro_grupo mg ON g.id_grupo = mg.id_grupo
LEFT JOIN evento ev ON g.id_grupo = ev.id_grupo
LEFT JOIN asistente_evento ae ON ev.id_evento = ae.id_evento AND ae.estado_asistencia = 'Confirmado'
GROUP BY g.id_grupo, g.nombre, g.tipo;

-- Consulta de validación de la Vista 3:
SELECT * FROM vw_rendimiento_grupos_eventos;
-- ----------------------------------------------------------------------------
-- VISTA 4: vw_ecosistema_mentorias_intereses
-- OBJETIVO: Integrar en una sola vista los intereses declarados de cada estudiante junto con
-- su rol dual en mentorías (sesiones_como_mentor vs. mentorias_solicitadas) y su red de contactos (seguidores y seguidos).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ecosistema_mentorias_intereses AS
SELECT 
    e.id_estudiante,
    p.nombre_completo AS estudiante,
    p.carrera,
    p.semestre,
    GROUP_CONCAT(DISTINCT i.nombre_interes ORDER BY i.nombre_interes SEPARATOR ', ') AS intereses_registrados,
    (SELECT COUNT(*) FROM mentoria m1 WHERE m1.id_mentor = e.id_estudiante AND m1.estado IN ('Aceptada', 'Finalizada')) AS sesiones_como_mentor,
    (SELECT COUNT(*) FROM mentoria m2 WHERE m2.id_estudiante = e.id_estudiante) AS mentorias_solicitadas,
    (SELECT COUNT(*) FROM seguimiento s1 WHERE s1.id_seguido = e.id_estudiante) AS seguidores,
    (SELECT COUNT(*) FROM seguimiento s2 WHERE s2.id_seguidor = e.id_estudiante) AS seguidos
FROM estudiante e
INNER JOIN perfil p ON e.id_estudiante = p.id_estudiante
LEFT JOIN estudiante_interes ei ON e.id_estudiante = ei.id_estudiante
LEFT JOIN interes i ON ei.id_interes = i.id_interes
GROUP BY e.id_estudiante, p.nombre_completo, p.carrera, p.semestre;

-- Consulta de validación de la Vista 4:
SELECT * FROM vw_ecosistema_mentorias_intereses ORDER BY sesiones_como_mentor DESC, seguidores DESC;