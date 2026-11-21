#Arquitectura Híbrida SQL + JSONB + IoT

**Proyecto:** Red social estudiantil pascualina  
**Asignatura:** Bases de Datos – Tarea 6  
**Autora:** Nathaly Rivas Aristizábal  

> **Nota técnica:** Este documento consolida el inventario completo de tablas, atributos estructurados y
> ** semiestructurados (`JSONB`), estructuras de indexación (`GIN` y `B-Tree`) y consultas analíticas implementadas en PostgreSQL para el soporte de Big Data e IoT.

---

## 1. Diccionario de Tablas y Atributos (Esquema Híbrido Relacional + JSONB + IoT)

La arquitectura integra **15 tablas relacionales** (núcleo transaccional ACID) y **2 tablas de telemetría IoT** (`dispositivo_iot` y `telemetria_iot`).

| # | Tabla | Columna | Tipo de Dato | Restricciones | Comentario Técnico / Estructura Interna JSONB |
|---|---|---|---|---|---|
| 1 | `estudiante` | `id_estudiante` | `SERIAL` | `PK` | Identificador único autoincremental del estudiante. |
| | `estudiante` | `correo_institucional` | `VARCHAR(100)` | `NOT NULL, UNIQUE` | Correo institucional oficial (`@pascualbravo.edu.co`). |
| | `estudiante` | `password_hash` | `VARCHAR(255)` | `NOT NULL` | Contraseña almacenada mediante hash criptográfico seguro. |
| | `estudiante` | `fecha_registro` | `TIMESTAMP` | `DEFAULT NOW()` | Marca de tiempo exacta de creación de la cuenta. |
| 2 | `perfil` | `id_perfil` | `SERIAL` | `PK` | Identificador único del perfil académico. |
| | `perfil` | `id_estudiante` | `INT` | `FK, UNIQUE, NOT NULL` | Relación 1:1 con `estudiante(id_estudiante)`. |
| | `perfil` | `nombre_completo` | `VARCHAR(150)` | `NOT NULL` | Nombres y apellidos completos del estudiante. |
| | `perfil` | `carrera` | `VARCHAR(100)` | `NOT NULL` | Programa académico activo en la institución. |
| | `perfil` | `semestre` | `INT` | `CHECK (> 0)` | Semestre actual validado como entero positivo. |
| | `perfil` | `preferencias_intereses` | `JSONB` | `INDEX GIN` | **Semiestructurado:** Objeto JSON binario con claves flexibles (`tema`, `notificaciones`, `github`, y arreglo `tags`). |
| 3 | `interes` | `id_interes` | `SERIAL` | `PK` | Identificador único del área de interés. |
| | `interes` | `nombre_interes` | `VARCHAR(100)` | `NOT NULL` | Nombre del área temática (ej. Big Data, IoT, Desarrollo Web). |
| | `interes` | `descripcion` | `TEXT` | `NULL` | Descripción general del interés académico. |
| 4 | `habilidad` | `id_habilidad` | `SERIAL` | `PK` | Identificador único de la habilidad. |
| | `habilidad` | `nombre_habilidad` | `VARCHAR(100)` | `NOT NULL` | Nombre de la competencia técnica o blanda. |
| | `habilidad` | `categoria` | `VARCHAR(50)` | `NULL` | Clasificación (Lenguajes, Bases de Datos, Hardware, etc.). |
| 5 | `publicacion` | `id_publicacion` | `SERIAL` | `PK` | Identificador único de la publicación en el muro. |
| | `publicacion` | `id_estudiante` | `INT` | `FK, NOT NULL` | Autor de la publicación (`estudiante`). |
| | `publicacion` | `contenido` | `TEXT` | `NOT NULL` | Cuerpo textual principal de la publicación. |
| | `publicacion` | `tipo_publicacion` | `VARCHAR(30)` | `CHECK IN (...)` | Dominio controlado: `'Pregunta'`, `'Recurso'`, `'Noticia'`, `'Meme'`. |
| | `publicacion` | `metadatos_multimedia` | `JSONB` | `INDEX GIN` | **Semiestructurado:** Almacena `archivo`, arreglo `imagenes`, arreglo `hashtags` (ej. `["#PostgreSQL"]`) y métrica entera `vistas`. |
| | `publicacion` | `fecha_creacion` | `TIMESTAMP` | `DEFAULT NOW()` | Fecha y hora de publicación. |
| 6 | `comentario` | `id_comentario` | `SERIAL` | `PK` | Identificador único del comentario. |
| | `comentario` | `id_publicacion` | `INT` | `FK, NOT NULL` | Publicación comentada (`publicacion`). |
| | `comentario` | `id_estudiante` | `INT` | `FK, NOT NULL` | Estudiante que comenta (`estudiante`). |
| | `comentario` | `contenido` | `TEXT` | `NOT NULL` | Texto del comentario realizado. |
| | `comentario` | `fecha_creacion` | `TIMESTAMP` | `DEFAULT NOW()` | Fecha y hora del comentario. |
| 7 | `reaccion` | `id_reaccion` | `SERIAL` | `PK` | Identificador único de la reacción. |
| | `reaccion` | `id_publicacion` | `INT` | `FK, NOT NULL` | Publicación reaccionada. |
| | `reaccion` | `id_estudiante` | `INT` | `FK, NOT NULL` | Estudiante que emite la reacción. |
| | `reaccion` | `tipo_reaccion` | `VARCHAR(20)` | `NULL` | Tipo de interacción (`'Me gusta'`, `'Me encanta'`, `'Útil'`). |
| 8 | `grupo` | `id_grupo` | `SERIAL` | `PK` | Identificador único del grupo o semillero. |
| | `grupo` | `nombre` | `VARCHAR(100)` | `NOT NULL` | Nombre oficial de la comunidad estudiantil. |
| | `grupo` | `descripcion` | `TEXT` | `NULL` | Propósito y líneas de trabajo del grupo. |
| | `grupo` | `tipo` | `VARCHAR(30)` | `NULL` | Clasificación (`'Semillero'`, `'Club'`, `'Grupo de Estudio'`). |
| 9 | `evento` | `id_evento` | `SERIAL` | `PK` | Identificador único del evento académico. |
| | `evento` | `id_grupo` | `INT` | `FK, NULL` | Grupo organizador (`grupo`). |
| | `evento` | `titulo` | `VARCHAR(150)` | `NOT NULL` | Nombre del evento, taller o maratón. |
| | `evento` | `fecha_inicio` | `TIMESTAMP` | `NOT NULL` | Fecha y hora programada de inicio. |
| | `evento` | `ubicacion_geo` | `JSONB` | `INDEX GIN` | **Semiestructurado:** Objeto JSON con `bloque`, `aula`, coordenadas GPS y capacidad `aforo_maximo`. |
| 10 | `mentoria` | `id_mentoria` | `SERIAL` | `PK` | Identificador único de la sesión de mentoría. |
| | `mentoria` | `id_mentor` | `INT` | `FK, NOT NULL` | Estudiante que brinda apoyo académico (`estudiante`). |
| | `mentoria` | `id_estudiante` | `INT` | `FK, NOT NULL` | Estudiante que solicita la tutoría (`estudiante`). |
| | `mentoria` | `materia_tema` | `VARCHAR(100)` | `NOT NULL` | Asignatura o temática de la mentoría. |
| | `mentoria` | `estado` | `VARCHAR(20)` | `NULL` | Estado del proceso (`'Activa'`, `'Finalizada'`, `'Pendiente'`). |
| 11 | `seguimiento` | `id_seguimiento` | `SERIAL` | `PK` | Identificador único del vínculo social. |
| | `seguimiento` | `id_seguidor` | `INT` | `FK, NOT NULL` | Estudiante que sigue (`estudiante`). |
| | `seguimiento` | `id_seguido` | `INT` | `FK, NOT NULL` | Estudiante seguido (`estudiante`). |
| | `seguimiento` | `fecha_seguimiento` | `TIMESTAMP` | `DEFAULT NOW()` | Fecha en que se estableció la conexión. |
| 12 | `estudiante_interes` | `id_estudiante, id_interes` | `INT, INT` | `PK Compuesta, FK` | Tabla puente N:M entre estudiantes e intereses. |
| 13 | `estudiante_habilidad` | `id_estudiante, id_habilidad` | `INT, INT` | `PK Compuesta, FK` | Tabla puente N:M entre estudiantes y habilidades (incluye `nivel`). |
| 14 | `miembro_grupo` | `id_grupo, id_estudiante` | `INT, INT` | `PK Compuesta, FK` | Tabla puente N:M de membresía en grupos (incluye `rol_grupo`). |
| 15 | `asistente_evento` | `id_evento, id_estudiante` | `INT, INT` | `PK Compuesta, FK` | Tabla puente N:M de inscripción a eventos (incluye `estado_asistencia`). |
| 16 | `dispositivo_iot` | `id_dispositivo` | `SERIAL` | `PK` | **Capa IoT:** Identificador único del nodo hardware registrado en el campus. |
| | `dispositivo_iot` | `codigo_hardware` | `VARCHAR(50)` | `UNIQUE, NOT NULL` | Serial físico único del sensor (ej. `NFC-B12-302`, `CAM-B12-302`). |
| | `dispositivo_iot` | `tipo_sensor` | `VARCHAR(40)` | `NOT NULL` | Tipo de dispositivo (`'Lector_NFC'`, `'Camara_Aforo'`, `'Sensor_Ambiental'`). |
| | `dispositivo_iot` | `ubicacion_bloque` | `VARCHAR(50)` | `NOT NULL` | Ubicación física exacta dentro de la I.U. Pascual Bravo. |
| | `dispositivo_iot` | `estado` | `VARCHAR(20)` | `DEFAULT 'Activo'` | Estado operativo para control de calidad y veracidad de datos. |
| 17 | `telemetria_iot` | `id_telemetria` | `BIGSERIAL` | `PK` | **Capa IoT / Big Data:** Identificador entero de 64 bits diseñado para ingesta masiva de millones de registros. |
| | `telemetria_iot` | `id_dispositivo` | `INT` | `FK, NOT NULL` | Sensor emisor de la lectura (`dispositivo_iot`). |
| | `telemetria_iot` | `id_evento` | `INT` | `FK, NULL` | Evento asociado a la lectura física (opcional). |
| | `telemetria_iot` | `id_estudiante` | `INT` | `FK, NULL` | Estudiante identificado por carnet NFC (opcional). |
| | `telemetria_iot` | `fecha_lectura` | `TIMESTAMP` | `INDEX B-Tree` | Marca de tiempo exacta de captura del evento físico. |
| | `telemetria_iot` | `payload_sensor` | `JSONB` | `NOT NULL, INDEX GIN` | **Semiestructurado IoT:** Trama variable del sensor (`latencia_ms`, `personas_detectadas`, `temperatura_c`, `humedad_pct`). |

---

## 2. Diccionario de Índices y Estructuras de Optimización Big Data

Para evitar recorridos secuenciales completos (*Sequential Scans*) sobre grandes volúmenes de documentos `JSONB` y series temporales IoT, se implementaron **6 índices especializados**:

| # | Nombre del Índice | Tabla | Columna(s) | Tipo | Justificación Técnica y Rendimiento |
|---|---|---|---|---|---|
| 1 | `idx_perfil_pref_gin` | `perfil` | `preferencias_intereses` | `GIN` | Indexa claves y valores internos del JSONB para filtrar estudiantes por intereses o configuración sin degradar la consulta. |
| 2 | `idx_pub_meta_gin` | `publicacion` | `metadatos_multimedia` | `GIN` | Optimiza el operador de contención `@>` sobre el arreglo `hashtags` (ej. búsqueda instantánea de `#PostgreSQL`). |
| 3 | `idx_evento_geo_gin` | `evento` | `ubicacion_geo` | `GIN` | Acelera consultas por bloque, aula y capacidad máxima (`aforo_maximo`) dentro del objeto geográfico JSONB. |
| 4 | `idx_tel_payload_gin` | `telemetria_iot` | `payload_sensor` | `GIN` | Permite consultar métricas heterogéneas enviadas por distintos sensores IoT en tramas masivas de alta velocidad. |
| 5 | `idx_tel_fecha` | `telemetria_iot` | `fecha_lectura` | `B-Tree` | Optimiza el filtrado por rangos de tiempo y ordenamiento cronológico en lecturas de telemetría. |
| 6 | `idx_pub_est` | `publicacion` | `id_estudiante` | `B-Tree` | Acelera los cruces relacionales (`JOIN`) entre perfiles académicos y publicaciones. |

---

## 3. Diccionario de Consultas Analíticas (DML)

Inventario completo de las consultas SQL diseñadas para extraer *insights* combinando tablas relacionales (`JOIN`), funciones de agregación (`SUM`, `COUNT`, `AVG`, `GROUP BY`) y operadores JSONB (`->>`, `@>`):

| # | Consulta Analítica | Tablas Cruzadas (`JOIN`) | Operadores y Funciones SQL/JSONB | Insight / Resultado Obtenido |
|---|---|---|---|---|
| 1 | **Alcance multimedia y reacciones por carrera** | `perfil` ⋈ `publicacion` ⋈ `reaccion` | `LEFT JOIN`, `GROUP BY`, `COUNT(DISTINCT ...)`, `SUM((metadatos_multimedia->>'vistas')::INT)` | Mide el impacto académico por programa: *Ingeniería de Software* lidera con 3 publicaciones, 591 vistas JSON y 4 reacciones; *Tecnología en Desarrollo de Software* suma 320 vistas; *Ingeniería Mecatrónica* suma 98 vistas. |
| 2 | **Filtrado de recursos por hashtag mediante índice GIN** | `publicacion` ⋈ `perfil` | Operador de contención `@>` (`'{"hashtags": ["#PostgreSQL"]}'::jsonb`), `COALESCE`, `->>` | Recupera publicaciones etiquetadas con `#PostgreSQL` ordenadas por vistas: Nathaly Rivas (145 vistas), Samantha López (84 vistas) y Sonia Henao (72 vistas). |
| 3 | **Control de asistencia física NFC vs. Aforo máximo JSONB** | `evento` ⋈ `telemetria_iot` ⋈ `dispositivo_iot` | `JOIN` triple, `COUNT`, `ROUND`, `(ubicacion_geo->>'aforo_maximo')::INT` | Cruza lecturas reales de carnets NFC con la capacidad definida en JSONB: el *Maratón de Bases de Datos Híbridas* (Bloque 12) registró 5 ingresos sobre 40 cupos máximos (**12.50% de ocupación real**). |
| 4 | **Monitoreo ambiental y detección de aforo por bloque** | `dispositivo_iot` ⋈ `telemetria_iot` | `GROUP BY`, `ROUND(AVG((payload_sensor->>'personas_detectadas')::NUMERIC), 1)`, `AVG(...'temperatura_c')` | Consolida lecturas heterogéneas por sensor: *Biblioteca Central* (`Sensor_Ambiental`) promedia **21.8 °C**; *Bloque 12 - Aula 302* (`Camara_Aforo`) detecta **34.0 personas** en promedio y (`Lector_NFC`) registra **5 lecturas**. |
