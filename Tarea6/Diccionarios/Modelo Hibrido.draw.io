-- Diagarama modelo hibrido 
erDiagram
    ESTUDIANTE ||--|| PERFIL : tiene
    ESTUDIANTE ||--o{ PUBLICACION : crea
    ESTUDIANTE ||--o{ COMENTARIO : escribe
    ESTUDIANTE ||--o{ REACCION : realiza
    PUBLICACION ||--o{ COMENTARIO : recibe
    PUBLICACION ||--o{ REACCION : recibe
    ESTUDIANTE ||--o{ MENTORIA : mentor_o_aprendiz
    ESTUDIANTE ||--o{ SEGUIMIENTO : sigue_o_seguido
    ESTUDIANTE ||--o{ ESTUDIANTE_INTERES : posee
    INTERES ||--o{ ESTUDIANTE_INTERES : agrupa
    ESTUDIANTE ||--o{ ESTUDIANTE_HABILIDAD : domina
    HABILIDAD ||--o{ ESTUDIANTE_HABILIDAD : clasifica
    GRUPO ||--o{ MIEMBRO_GRUPO : integra
    ESTUDIANTE ||--o{ MIEMBRO_GRUPO : participa
    GRUPO ||--o{ EVENTO : organiza
    EVENTO ||--o{ ASISTENTE_EVENTO : registra
    ESTUDIANTE ||--o{ ASISTENTE_EVENTO : asiste
    DISPOSITIVO_IOT ||--o{ TELEMETRIA_IOT : emite
    EVENTO ||--o{ TELEMETRIA_IOT : monitorea
    ESTUDIANTE ||--o{ TELEMETRIA_IOT : identifica_nfc

    ESTUDIANTE {
        serial id_estudiante PK
        varchar correo_institucional
        varchar password_hash
        timestamp fecha_registro
    }
    PERFIL {
        serial id_perfil PK
        int id_estudiante FK
        varchar nombre_completo
        varchar carrera
        int semestre
        jsonb preferencias_intereses
    }
    PUBLICACION {
        serial id_publicacion PK
        int id_estudiante FK
        text contenido
        varchar tipo_publicacion
        jsonb metadatos_multimedia
    }
    EVENTO {
        serial id_evento PK
        int id_grupo FK
        varchar titulo
        timestamp fecha_inicio
        jsonb ubicacion_geo
    }
    DISPOSITIVO_IOT {
        serial id_dispositivo PK
        varchar codigo_hardware
        varchar tipo_sensor
        varchar ubicacion_bloque
    }
    TELEMETRIA_IOT {
        bigserial id_telemetria PK
        int id_dispositivo FK
        int id_evento FK
        int id_estudiante FK
        jsonb payload_sensor
    }
