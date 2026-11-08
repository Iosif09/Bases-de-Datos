-- Creacion de Base de Datos --
Create Database gestion_biblioteca_sig
CHARACTER SET utf8mb4 -- definicion de carateres a usar --
COLLATE utf8mb4_unicode_ci; -- regla de comparacion y codificacion --

USE gestion_biblioteca_sig;

CREATE TABLE tipo_usuario (
    id_tipo_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tu VARCHAR(30) NOT NULL UNIQUE,
    limite_prestamos_tu TINYINT NOT NULL DEFAULT 3,
    dias_prestamo_tu TINYINT NOT NULL DEFAULT 7,
    multa_diaria_tu DECIMAL(5,2) NOT NULL DEFAULT 0.50,
    puede_reservar_tu BOOLEAN NOT NULL DEFAULT TRUE,
    max_renovaciones_tu TINYINT NOT NULL DEFAULT 2
) ENGINE=InnoDB; -- motor de almacenamiento en tablas --

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_usuario INT NOT NULL,
    numero_documento_u VARCHAR(20) NOT NULL UNIQUE,
    nombre_u VARCHAR(50) NOT NULL,
    apellidos_u VARCHAR(70) NOT NULL,
    correo_u VARCHAR(100) NOT NULL UNIQUE,
    telefono_u VARCHAR(15) NULL,
    direccion_u TEXT NULL,
    fecha_registro_u DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado_u ENUM('activo', 'suspendido', 'inactivo') NOT NULL DEFAULT 'activo',
    contraseña_u VARCHAR(255) NOT NULL,
    observaciones_u TEXT NULL,
    CONSTRAINT fk_usuario_tipo_usuario
        FOREIGN KEY (id_tipo_usuario) REFERENCES tipo_usuario(id_tipo_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_usuario_documento ON usuarios(numero_documento_u); -- creacion de indices en tablas para busqueda --
CREATE INDEX idx_usuario_correo ON usuarios(correo_u);

CREATE TABLE titulos (
    id_titulo INT AUTO_INCREMENT PRIMARY KEY,
    isbn_t VARCHAR(13) NULL UNIQUE,
    titulo_t VARCHAR(200) NOT NULL,
    autor_t VARCHAR(100) NOT NULL,
    editorial_t VARCHAR(100) NULL,
    año_publicacion_t YEAR NULL,
    edicion_t VARCHAR(20) NULL,
    num_paginas_t SMALLINT NULL,
    idioma_t VARCHAR(20) NOT NULL DEFAULT 'Español',
    materia_t VARCHAR(50) NULL,
    descripcion_t TEXT NULL
) ENGINE=InnoDB;

CREATE INDEX idx_titulo_nombre ON titulos(titulo_t);
CREATE INDEX idx_titulo_autor ON titulos(autor_t);

CREATE TABLE ejemplares (
    id_ejemplar INT AUTO_INCREMENT PRIMARY KEY,
    id_titulo INT NOT NULL,
    codigo_barras_e VARCHAR(20) NOT NULL UNIQUE,
    estado_e ENUM('disponible', 'prestado', 'reparacion', 'extraviado', 'reserva') NOT NULL DEFAULT 'disponible',
    ubicacion_fisica_e VARCHAR(50) NULL,
    fecha_adquisicion_e DATE NULL,
    costo_e DECIMAL(8,2) NULL,
    
    CONSTRAINT fk_ejemplar_titulo
        FOREIGN KEY (id_titulo) REFERENCES titulos(id_titulo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_ejemplar_codigo ON ejemplares(codigo_barras_e);
CREATE INDEX idx_ejemplar_estado ON ejemplares(estado_e);

CREATE TABLE prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_prestamo_p DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion_esperada_p DATE NOT NULL,
    fecha_devolucion_real_p DATE NULL,
    renovaciones_p TINYINT NOT NULL DEFAULT 0,
    id_bibliotecario_presto INT NOT NULL,
    estado_p ENUM('activo', 'devuelto', 'vencido') NOT NULL DEFAULT 'activo',
    
    CONSTRAINT fk_prestamo_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_ejemplar
        FOREIGN KEY (id_ejemplar) REFERENCES ejemplares(id_ejemplar)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_prestamo_bibliotecario
        FOREIGN KEY (id_bibliotecario_presto) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_prestamo_fechas CHECK (fecha_devolucion_esperada_p >= DATE(fecha_prestamo_p)) -- CHECK restriccion de integridad de fechas --
) ENGINE=InnoDB;

CREATE INDEX idx_prestamo_usuario ON prestamos(id_usuario);
CREATE INDEX idx_prestamo_ejemplar ON prestamos(id_ejemplar);
CREATE INDEX idx_prestamo_estado_fecha ON prestamos(estado_p, fecha_devolucion_esperada_p);

CREATE TABLE multas (
    id_multa INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    id_usuario INT NOT NULL,
    monto_m DECIMAL(8,2) NOT NULL,
    motivo_m ENUM('retraso', 'daño', 'extravío') NOT NULL,
    fecha_registro_m DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pagado_m BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_pago_m DATETIME NULL,
    
    CONSTRAINT fk_multa_prestamo
        FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_multa_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT unique_prestamo_multa UNIQUE (id_prestamo) -- para claves unicas con UNIQUE --
) ENGINE=InnoDB;

CREATE INDEX idx_multa_usuario_pagado ON multas(id_usuario, pagado_m);

CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_solicitud_r DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_disponible_r DATE NULL,  -- Fecha estimada de devolución (se puede calcular con trigger)
    estado_r ENUM('pendiente', 'activa', 'cancelada', 'cumplida') NOT NULL DEFAULT 'pendiente',
    posicion_cola_r TINYINT NULL,
    
    CONSTRAINT fk_reserva_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_ejemplar
        FOREIGN KEY (id_ejemplar) REFERENCES ejemplares(id_ejemplar)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_reserva_ejemplar_estado ON reservas(id_ejemplar, estado_r);
CREATE INDEX idx_reserva_usuario_estado ON reservas(id_usuario, estado_r);

CREATE TABLE rol_sistema (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rs VARCHAR(20) NOT NULL UNIQUE,
    descripcion_rs VARCHAR(100) NULL,
    nivel_permiso_rs TINYINT NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion_ur DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    asignado_por INT NOT NULL,
    
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuariorol_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_usuariorol_rol
        FOREIGN KEY (id_rol) REFERENCES rol_sistema(id_rol)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_usuariorol_asignador
        FOREIGN KEY (asignado_por) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE auditoria_prestamo (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT NOT NULL,
    accion_ap ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    fecha_hora_ap DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_ejecutor INT NOT NULL,
    datos_anteriores_ap JSON NULL,
    datos_nuevos_ap JSON NULL,
    
    CONSTRAINT fk_auditoria_prestamo
        FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (usuario_ejecutor) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_auditoria_prestamo ON auditoria_prestamo(id_prestamo);
CREATE INDEX idx_auditoria_fecha ON auditoria_prestamo(fecha_hora_ap);

CREATE TABLE configuracion_global (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    clave_cg VARCHAR(50) NOT NULL UNIQUE,
    valor_cg VARCHAR(100) NOT NULL,
    descripcion_cg TEXT NULL,
    fecha_actualizacion_cg DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    actualizado_por INT NOT NULL,
    
    CONSTRAINT fk_config_usuario
        FOREIGN KEY (actualizado_por) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo_n ENUM('vencimiento', 'multa', 'reserva_disponible', 'recordatorio') NOT NULL,
    mensaje_n TEXT NOT NULL,
    fecha_envio_n DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leido_n BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_lectura_n DATETIME NULL,
    
    CONSTRAINT fk_notificacion_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_notificacion_usuario_leido ON notificaciones(id_usuario, leido_n);

-- Datos para Referencia de Triggers --
-- Insertar tipos de usuario --
INSERT INTO tipo_usuario (nombre_tu, limite_prestamos_tu, dias_prestamo_tu, multa_diaria_tu, puede_reservar_tu, max_renovaciones_tu)
VALUES ('Estudiante', 3, 7, 0.50, TRUE, 2),
       ('Docente', 7, 15, 0.50, TRUE, 3),
       ('Administrador', 10, 30, 0.00, TRUE, 5);

-- Insertar usuarios --
INSERT INTO usuarios (id_tipo_usuario, numero_documento_u, nombre_u, apellidos_u, correo_u, contraseña_u, estado_u)
VALUES (3, 'ADMIN01', 'Admin', 'Sistema', 'admin@mail.com', SHA2('admin123',256), 'activo'),
       (1, '11111', 'Ana', 'García', 'ana@mail.com', SHA2('pass',256), 'activo'),
       (1, '22222', 'Luis', 'Pérez', 'luis@mail.com', SHA2('pass',256), 'suspendido'),
       (2, '33333', 'Marta', 'López', 'marta@mail.com', SHA2('pass',256), 'activo');

-- Insertar títulos y ejemplares --
INSERT INTO titulos (titulo_t, autor_t) VALUES ('Libro prueba', 'Autor Test');
SET @id_titulo = LAST_INSERT_ID();
INSERT INTO ejemplares (id_titulo, codigo_barras_e, estado_e) VALUES (@id_titulo, 'EJ001', 'disponible');
INSERT INTO ejemplares (id_titulo, codigo_barras_e, estado_e) VALUES (@id_titulo, 'EJ002', 'prestado');
INSERT INTO ejemplares (id_titulo, codigo_barras_e, estado_e) VALUES (@id_titulo, 'EJ003', 'disponible');

-- Insertar configuración global --
INSERT INTO configuracion_global (clave_cg, valor_cg, actualizado_por) VALUES ('dias_gracia', '1', 1);

-- Inserccion de Datos con PA --

DELIMITER //
CREATE PROCEDURE InsertarTipoUsuario(
    IN p_nombre VARCHAR(30),
    IN p_limite_prestamos TINYINT,
    IN p_dias_prestamo TINYINT,
    IN p_multa_diaria DECIMAL(5,2),
    IN p_puede_reservar BOOLEAN,
    IN p_max_renovaciones TINYINT
)
BEGIN
    INSERT IGNORE INTO tipo_usuario (nombre_tu, limite_prestamos_tu, dias_prestamo_tu, multa_diaria_tu, puede_reservar_tu, max_renovaciones_tu)
    VALUES (p_nombre, p_limite_prestamos, p_dias_prestamo, p_multa_diaria, p_puede_reservar, p_max_renovaciones);
END //
DELIMITER //

CALL InsertarTipoUsuario('Estudiante', 3, 7, 0.50, TRUE, 2);
CALL InsertarTipoUsuario('Docente', 7, 15, 0.50, TRUE, 3);
CALL InsertarTipoUsuario('Investigador', 10, 30, 0.50, TRUE, 4);
CALL InsertarTipoUsuario('Externo', 2, 5, 1.00, FALSE, 1);
CALL InsertarTipoUsuario('Administrador', 15, 45, 0.00, TRUE, 5);
SELECT * FROM tipo_usuario;

DELIMITER //
CREATE PROCEDURE InsertarRolSistema(
    IN p_nombre VARCHAR(20),
    IN p_descripcion VARCHAR(100),
    IN p_nivel_permiso TINYINT
)
BEGIN
    INSERT IGNORE INTO rol_sistema (nombre_rs, descripcion_rs, nivel_permiso_rs)
    VALUES (p_nombre, p_descripcion, p_nivel_permiso);
END //
DELIMITER //

CALL InsertarRolSistema('admin', 'Acceso total al sistema', 10);
CALL InsertarRolSistema('bibliotecario', 'Gestión de préstamos y usuarios', 7);
CALL InsertarRolSistema('consultor', 'Solo consulta de catálogo', 2);
CALL InsertarRolSistema('auditor', 'Lectura de auditorías y reportes', 4);
CALL InsertarRolSistema('supervisor', 'Supervisión de reportes', 8);
SELECT * FROM rol_sistema;

DELIMITER //
CREATE PROCEDURE InsertarUsuario(
    IN p_id_tipo_usuario INT,
    IN p_numero_documento VARCHAR(20),
    IN p_nombre VARCHAR(50),
    IN p_apellidos VARCHAR(70),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_direccion TEXT,
    IN p_estado ENUM('activo','suspendido','inactivo'),
    IN p_contraseña VARCHAR(255),
    IN p_observaciones TEXT
)
BEGIN
    INSERT IGNORE INTO usuarios (id_tipo_usuario, numero_documento_u, nombre_u, apellidos_u, correo_u, telefono_u, direccion_u, estado_u, contraseña_u, observaciones_u)
    VALUES (p_id_tipo_usuario, p_numero_documento, p_nombre, p_apellidos, p_correo, p_telefono, p_direccion, p_estado, p_contraseña, p_observaciones);
END //
DELIMITER //

CALL InsertarUsuario(1, '12345678', 'Ana', 'García', 'ana@mail.com', '555-1111', 'Calle 1', 'activo', SHA2('pass123',256), NULL);
CALL InsertarUsuario(2, '87654321', 'Luis', 'Pérez', 'luis@mail.com', '555-2222', 'Calle 2', 'activo', SHA2('pass123',256), 'Profesor titular');
CALL InsertarUsuario(3, '11223344', 'Marta', 'López', 'marta@mail.com', '555-3333', 'Calle 3', 'activo', SHA2('pass123',256), 'Investigadora senior');
CALL InsertarUsuario(4, '44332211', 'Carlos', 'Ruiz', 'carlos@mail.com', '555-4444', 'Calle 4', 'suspendido', SHA2('pass123',256), 'Multa pendiente');
CALL InsertarUsuario(5, '99887766', 'Admin', 'Sistema', 'admin@mail.com', '555-0000', 'Admin', 'activo', SHA2('admin789',256), 'Usuario administrador');
SELECT * FROM usuarios;

DELIMITER //
CREATE PROCEDURE InsertarTitulo(
    IN p_isbn VARCHAR(13),
    IN p_titulo VARCHAR(200),
    IN p_autor VARCHAR(100),
    IN p_editorial VARCHAR(100),
    IN p_año_publicacion YEAR,
    IN p_edicion VARCHAR(20),
    IN p_num_paginas SMALLINT,
    IN p_idioma VARCHAR(20),
    IN p_materia VARCHAR(50),
    IN p_descripcion TEXT
)
BEGIN
    INSERT IGNORE INTO titulos (isbn_t, titulo_t, autor_t, editorial_t, año_publicacion_t, edicion_t, num_paginas_t, idioma_t, materia_t, descripcion_t)
    VALUES (p_isbn, p_titulo, p_autor, p_editorial, p_año_publicacion, p_edicion, p_num_paginas, p_idioma, p_materia, p_descripcion);
END //
DELIMITER //

CALL InsertarTitulo('978-3-16-1484', 'Introducción a la Algoritmia', 'Thomas Cormen', 'MIT Press', 2009, '3ra', 1312, 'Español', 'Informática', 'Clásico de algoritmos');
CALL InsertarTitulo('978-0-13-1103', 'El Lenguaje de Programación C', 'Brian Kernighan', 'Prentice Hall', 1988, '2da', 272, 'Español', 'Programación', 'Libro fundamental de C');
CALL InsertarTitulo('978-0-596-005', 'Aprendiendo MySQL', 'Robin Nixon', 'O\'Reilly', 2010, '1ra', 600, 'Español', 'Bases de datos', 'Práctico con ejemplos');
CALL InsertarTitulo('978-84-7829-0', 'Cien años de soledad', 'Gabriel García Márquez', 'Sudamericana', 1967, '1ra', 496, 'Español', 'Literatura', 'Novela famosa');
CALL InsertarTitulo('978-0-262-013', 'Inteligencia Artificial: Un Enfoque Moderno', 'Stuart Russell', 'Pearson', 2010, '3ra', 1152, 'Español', 'IA', 'Libro de texto');
SELECT * FROM titulos;

DELIMITER //
CREATE PROCEDURE InsertarEjemplar(
    IN p_id_titulo INT,
    IN p_codigo_barras VARCHAR(20),
    IN p_estado ENUM('disponible','prestado','reparacion','extraviado','reserva'),
    IN p_ubicacion_fisica VARCHAR(50),
    IN p_fecha_adquisicion DATE,
    IN p_costo DECIMAL(8,2)
)
BEGIN
    INSERT IGNORE INTO ejemplares (id_titulo, codigo_barras_e, estado_e, ubicacion_fisica_e, fecha_adquisicion_e, costo_e)
    VALUES (p_id_titulo, p_codigo_barras, p_estado, p_ubicacion_fisica, p_fecha_adquisicion, p_costo);
END //
DELIMITER //

CALL InsertarEjemplar(1, 'LIB001', 'disponible', 'Estante A1', '2020-01-15', 45.00);
CALL InsertarEjemplar(1, 'LIB002', 'prestado', 'Estante A1', '2020-01-15', 45.00);
CALL InsertarEjemplar(2, 'LIB003', 'disponible', 'Estante B2', '2020-03-10', 35.50);
CALL InsertarEjemplar(3, 'LIB004', 'reparacion', 'Estante C3', '2021-06-20', 60.00);
CALL InsertarEjemplar(4, 'LIB005', 'disponible', 'Literatura D4', '2019-11-05', 25.00);
SELECT * FROM ejemplares;

DELIMITER //
CREATE PROCEDURE InsertarPrestamo(
    IN p_id_usuario INT,
    IN p_id_ejemplar INT,
    IN p_fecha_prestamo DATETIME,
    IN p_fecha_devolucion_esperada DATE,
    IN p_fecha_devolucion_real DATE,
    IN p_renovaciones TINYINT,
    IN p_id_bibliotecario_presto INT,
    IN p_estado ENUM('activo','devuelto','vencido')
)
BEGIN
    INSERT IGNORE INTO prestamos (id_usuario, id_ejemplar, fecha_prestamo_p, fecha_devolucion_esperada_p, fecha_devolucion_real_p, renovaciones_p, id_bibliotecario_presto, estado_p)
    VALUES (p_id_usuario, p_id_ejemplar, p_fecha_prestamo, p_fecha_devolucion_esperada, p_fecha_devolucion_real, p_renovaciones, p_id_bibliotecario_presto, p_estado);
END //
DELIMITER //

CALL InsertarPrestamo(1, 2, '2025-04-01 10:00:00', '2025-04-08', NULL, 0, 5, 'activo');
CALL InsertarPrestamo(2, 1, '2025-03-20 11:30:00', '2025-04-04', '2025-04-03', 1, 5, 'devuelto');
CALL InsertarPrestamo(3, 5, '2025-04-05 09:15:00', '2025-05-05', NULL, 0, 5, 'activo');
CALL InsertarPrestamo(4, 3, '2025-03-01 14:00:00', '2025-03-08', '2025-03-10', 0, 5, 'devuelto');
CALL InsertarPrestamo(5, 4, '2025-04-10 16:20:00', '2025-04-25', NULL, 0, 5, 'activo');
SELECT * FROM prestamos;

DELIMITER //
CREATE PROCEDURE InsertarMulta(
    IN p_id_prestamo INT,
    IN p_id_usuario INT,
    IN p_monto DECIMAL(8,2),
    IN p_motivo ENUM('retraso','daño','extravío'),
    IN p_pagado BOOLEAN,
    IN p_fecha_pago DATETIME
)
BEGIN
    INSERT IGNORE INTO multas (id_prestamo, id_usuario, monto_m, motivo_m, pagado_m, fecha_pago_m)
    VALUES (p_id_prestamo, p_id_usuario, p_monto, p_motivo, p_pagado, p_fecha_pago);
END //
DELIMITER //

CALL InsertarMulta(2, 2, 2.00, 'retraso', TRUE, '2025-04-03 18:00:00');
CALL InsertarMulta(4, 4, 4.00, 'retraso', FALSE, NULL);
CALL InsertarMulta(1, 1, 0.00, 'retraso', TRUE, '2025-04-09 09:00:00'); -- monto 0 por días de gracia
CALL InsertarMulta(3, 3, 7.50, 'daño', FALSE, NULL);
CALL InsertarMulta(5, 5, 0.00, 'extravío', FALSE, NULL);
SELECT * FROM multas;

DELIMITER //
CREATE PROCEDURE InsertarReserva(
    IN p_id_usuario INT,
    IN p_id_ejemplar INT,
    IN p_fecha_solicitud DATETIME,
    IN p_fecha_disponible DATE,
    IN p_estado ENUM('pendiente','activa','cancelada','cumplida'),
    IN p_posicion_cola TINYINT
)
BEGIN
    INSERT IGNORE INTO reservas (id_usuario, id_ejemplar, fecha_solicitud_r, fecha_disponible_r, estado_r, posicion_cola_r)
    VALUES (p_id_usuario, p_id_ejemplar, p_fecha_solicitud, p_fecha_disponible, p_estado, p_posicion_cola);
END //
DELIMITER //

CALL InsertarReserva(1, 2, '2025-04-02 08:00:00', '2025-04-09', 'cumplida', 1);
CALL InsertarReserva(2, 5, '2025-04-03 09:00:00', NULL, 'pendiente', 1);
CALL InsertarReserva(3, 1, '2025-04-04 10:00:00', NULL, 'activa', 1);
CALL InsertarReserva(4, 3, '2025-04-05 11:00:00', '2025-03-10', 'cancelada', NULL);
CALL InsertarReserva(5, 4, '2025-04-06 12:00:00', NULL, 'pendiente', 2);
SELECT * FROM reservas;

DELIMITER //
CREATE PROCEDURE InsertarConfiguracion(
    IN p_clave VARCHAR(50),
    IN p_valor VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_actualizado_por INT
)
BEGIN
    INSERT IGNORE INTO configuracion_global (clave_cg, valor_cg, descripcion_cg, actualizado_por)
    VALUES (p_clave, p_valor, p_descripcion, p_actualizado_por);
END //
DELIMITER //

CALL InsertarConfiguracion('dias_gracia', '1', 'Días sin multa después del vencimiento', 5);
CALL InsertarConfiguracion('multa_maxima_factor', '1.0', 'La multa máxima equivale al costo del ejemplar', 5);
CALL InsertarConfiguracion('notificacion_vencimiento_anticipo', '2', 'Días antes para notificar vencimiento', 5);
CALL InsertarConfiguracion('limite_reservas_activas', '3', 'Máximo de reservas activas por usuario', 5);
CALL InsertarConfiguracion('max_renovaciones_global', '2', 'Renovaciones máximas por defecto', 5);
SELECT * FROM configuracion_global;

DELIMITER //
CREATE PROCEDURE InsertarNotificacion(
    IN p_id_usuario INT,
    IN p_tipo ENUM('vencimiento','multa','reserva_disponible','recordatorio'),
    IN p_mensaje TEXT,
    IN p_leido BOOLEAN,
    IN p_fecha_lectura DATETIME
)
BEGIN
    INSERT IGNORE INTO notificaciones (id_usuario, tipo_n, mensaje_n, leido_n, fecha_lectura_n)
    VALUES (p_id_usuario, p_tipo, p_mensaje, p_leido, p_fecha_lectura);
END //
DELIMITER //

CALL InsertarNotificacion(1, 'vencimiento', 'Su préstamo vence en 2 días', FALSE, NULL);
CALL InsertarNotificacion(2, 'multa', 'Tiene una multa pendiente de $2.00', FALSE, NULL);
CALL InsertarNotificacion(3, 'reserva_disponible', 'El libro que reservó ya está disponible', TRUE, '2025-04-07 08:00:00');
CALL InsertarNotificacion(4, 'recordatorio', 'Por favor devuelva los libros atrasados', FALSE, NULL);
CALL InsertarNotificacion(5, 'vencimiento', 'Préstamo vence hoy', FALSE, NULL);
SELECT * FROM notificaciones;

DELIMITER //
CREATE PROCEDURE InsertarAuditoria(
    IN p_id_prestamo INT,
    IN p_accion ENUM('INSERT','UPDATE','DELETE'),
    IN p_usuario_ejecutor INT,
    IN p_datos_anteriores JSON,
    IN p_datos_nuevos JSON
)
BEGIN
    INSERT IGNORE INTO auditoria_prestamo (id_prestamo, accion_ap, usuario_ejecutor, datos_anteriores_ap, datos_nuevos_ap)
    VALUES (p_id_prestamo, p_accion, p_usuario_ejecutor, p_datos_anteriores, p_datos_nuevos);
END //
DELIMITER //

CALL InsertarAuditoria(1, 'INSERT', 5, NULL, JSON_OBJECT('id_prestamo',1,'usuario',1));
CALL InsertarAuditoria(2, 'UPDATE', 5, JSON_OBJECT('estado','activo'), JSON_OBJECT('estado','devuelto'));
CALL InsertarAuditoria(3, 'INSERT', 5, NULL, JSON_OBJECT('id_prestamo',3));
CALL InsertarAuditoria(4, 'DELETE', 5, JSON_OBJECT('id_prestamo',4), NULL);
CALL InsertarAuditoria(5, 'UPDATE', 5, JSON_OBJECT('renovaciones',0), JSON_OBJECT('renovaciones',1));
SELECT * FROM auditoria_prestamo;

--                  Procedimientos Almacenados                   --

-- Busqueda de Libros Dinamico --

DELIMITER //
CREATE PROCEDURE BuscarLibrosPA(
    IN p_keyword VARCHAR(100),
    IN p_orden VARCHAR(20)
)
BEGIN
    IF p_keyword IS NULL OR TRIM(p_keyword) = '' THEN -- TRIM limpia espacios en blanco --
        SELECT 'Error: Ingrese una palabra clave para buscar.' AS mensaje;
    ELSE
        SELECT 
            id_titulo, 
            titulo_t, 
            autor_t, 
            editorial_t, 
            año_publicacion_t
        FROM titulos
        WHERE titulo_t LIKE CONCAT('%', p_keyword, '%') -- CONCAT junta cadenas en una sola --
           OR autor_t LIKE CONCAT('%', p_keyword, '%')
        ORDER BY 
            CASE 
                WHEN p_orden = 'titulo' THEN titulo_t
                WHEN p_orden = 'autor' THEN autor_t
                WHEN p_orden = 'año' THEN año_publicacion_t
                ELSE titulo_t
            END;
    END IF;
END //
DELIMITER //

CALL BuscarLibrosPA('ciencia', 'titulo');
CALL BuscarLibrosPA('García', 'autor');
CALL BuscarLibrosPA('', 'titulo');

-- Busqueda de Prestamos Activos --

DELIMITER //
CREATE PROCEDURE PrestamosActivosPA()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error al obtener préstamos activos.' AS mensaje;
    END;
    
    SELECT 
        p.id_prestamo, 
        CONCAT(u.nombre_u, ' ', u.apellidos_u) AS nombre_usuario,
        t.titulos_t,
        e.codigo_barras_e,
        DATE_FORMAT(p.fecha_prestamo_p, '%d/%m/%Y') AS fecha_prestamo, -- DATEFORMAT cambio de presentacion de fecha --
        DATE_FORMAT(p.fecha_devolucion_esperada_p, '%d/%m/%Y') AS fecha_esperada,
        DATEDIFF(p.fecha_devolucion_esperada_p, CURDATE()) AS dias_restantes, -- DATEDIFF calcula diferencia entre fechas en dias --
        CASE  
            WHEN p.fecha_devolucion_esperada_p < CURDATE() THEN 'Vencido'
            ELSE 'Vigente'
        END AS estado_plazo
    FROM prestamos p
    INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
    INNER JOIN ejemplar e ON p.id_ejemplar = e.id_ejemplar
    INNER JOIN titulo t ON e.id_titulo = t.id_titulo
    WHERE p.estado_p = 'activo'
    ORDER BY p.fecha_devolucion_esperada_p ASC;
END //
DELIMITER //

CALL PrestamosActivosPA();

-- Usuarios con Multas Pendientes --

DELIMITER //
CREATE PROCEDURE UsuariosConMultasPA()
BEGIN
    DECLARE v_total_usuarios INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_total_usuarios
    FROM usuarios u
    WHERE EXISTS (SELECT 1 FROM multas m WHERE m.id_usuario = u.id_usuario AND m.pagado_m = FALSE);
    
    IF v_total_usuarios = 0 THEN
        SELECT 'No hay usuarios con multas pendientes' AS mensaje;
    ELSE
        SELECT 
            u.id_usuario, 
            u.nombre_u, 
            u.apellidos_u, 
            COALESCE(SUM(m.monto_m), 0) AS total_deuda,
            COUNT(m.id_multa) AS cantidad_multas,
            CASE 
                WHEN SUM(m.monto_m) > 100 THEN 'Alta'
                WHEN SUM(m.monto_m) > 50 THEN 'Media'
                ELSE 'Baja'
            END AS nivel_deuda
        FROM usuarios u
        LEFT JOIN multas m ON u.id_usuario = m.id_usuario AND m.pagado_m = FALSE
        GROUP BY u.id_usuario
        HAVING total_deuda > 0
        ORDER BY total_deuda DESC;
    END IF;
END //
DELIMITER //

CALL UsuariosConMultasPA();

-- Prestamos por Periodos de Fechas --

DELIMITER //
CREATE PROCEDURE PrestamosPorPeriodoPA(
    IN fecha_inicio DATE, 
    IN fecha_fin DATE
)
BEGIN
    IF fecha_inicio IS NULL OR fecha_fin IS NULL THEN
        SELECT 'Error: Debe proporcionar ambas fechas' AS mensaje;
    ELSEIF fecha_inicio > fecha_fin THEN
        SELECT 'Error: La fecha de inicio no puede ser mayor que la fecha fin' AS mensaje;
    ELSE
        SELECT 
            p.id_prestamo,
            CONCAT(u.nombre_u, ' ', u.apellidos_u) AS usuario,
            t.titulo_t,
            DATE(p.fecha_prestamo_p) AS fecha_prestamo,
            CASE 
                WHEN p.fecha_devolucion_real_p IS NOT NULL THEN 'Devuelto'
                ELSE 'Pendiente'
            END AS estado_devolucion
        FROM prestamos p
        INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
        INNER JOIN ejemplares e ON p.id_ejemplar = e.id_ejemplar
        INNER JOIN titulos t ON e.id_titulo = t.id_titulo
        WHERE DATE(p.fecha_prestamo_p) BETWEEN fecha_inicio AND fecha_fin
        ORDER BY p.fecha_prestamo_p;
    END IF;
END //
DELIMITER //

CALL PrestamosPorPeriodoPA('2025-04-01', '2025-04-30');
CALL PrestamosPorPeriodoPA('2025-05-01', '2025-04-01');
CALL PrestamosPorPeriodoPA(NULL, '2025-04-30');

-- Prestamos Atrazados y Multa Estimada --

DELIMITER //
CREATE PROCEDURE PrestamosConRetrasoPA()
BEGIN
    SELECT 
        p.id_prestamo,
        CONCAT(u.nombre_u, ' ', u.apellidos_u) AS usuario,
        t.titulo_t,
        p.fecha_devolucion_esperada_p,
        DATEDIFF(CURDATE(), p.fecha_devolucion_esperada_p) AS dias_retraso,
        DATEDIFF(CURDATE(), p.fecha_devolucion_esperada_p) * tu.multa_diaria_tu AS multa_estimada,
        CASE 
            WHEN DATEDIFF(CURDATE(), p.fecha_devolucion_esperada_p) > 30 THEN 'Muy grave'
            WHEN DATEDIFF(CURDATE(), p.fecha_devolucion_esperada_p) > 15 THEN 'Grave'
            ELSE 'Leve'
        END AS severidad
    FROM prestamos p
    INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
    INNER JOIN ejemplares e ON p.id_ejemplar = e.id_ejemplar
    INNER JOIN titulos t ON e.id_titulo = t.id_titulo
    INNER JOIN tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
    WHERE p.estado_p = 'activo' 
      AND p.fecha_devolucion_esperada_P < CURDATE() -- CURDATE devuelve la fecha actual --
    ORDER BY dias_retraso DESC;
END //
DELIMITER //

CALL PrestamosConRetrasoPA();

-- Actualizacion de Prestamos Vencidos --

DELIMITER //
CREATE PROCEDURE ActualizarPrestamosVencidosPA()
BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    UPDATE prestamos
    SET estado_p = 'vencido'
    WHERE estado_p = 'activo' AND fecha_devolucion_esperada_p < CURDATE();
    
    SELECT ROW_COUNT() INTO v_count;
    
    IF v_count > 0 THEN
        SELECT CONCAT('Se actualizaron ', v_count, ' préstamos a estado vencido') AS mensaje;
    ELSE
        SELECT 'No hay préstamos vencidos pendientes para actualizar' AS mensaje;
    END IF;
END //
DELIMITER //

CALL ActualizarPrestamosVencidosPA();

-- Filtro de Usuarios por Estado y Tipos --

DELIMITER //
CREATE PROCEDURE FiltrarUsuariosPA(
    IN p_estado VARCHAR(10),
    IN p_tipos VARCHAR(100)
)
BEGIN
    IF p_estado IS NULL OR p_estado = '' THEN
        SET p_estado = '%';
    END IF;
    
    SELECT 
        u.id_usuario, 
        u.nombre_u, 
        u.apellidos_u, 
        u.estado_u, 
        tu.nombre_tu AS tipo_usuario,
        CASE 
            WHEN u.estado_u = 'suspendido' THEN 'Sancionado'
            WHEN u.estado_u = 'activo' THEN 'Activo'
            ELSE 'Inactivo'
        END AS estado_descripcion
    FROM usuarios u
    INNER JOIN tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
    WHERE (p_estado = '%' OR u.estado_u = p_estado)
      AND (p_tipos IS NULL OR p_tipos = '' OR FIND_IN_SET(u.id_tipo_usuario, p_tipos))
    ORDER BY u.apellidos_u, u.nombre_u;
END //
DELIMITER //

CALL FiltrarUsuariosPA('activo', '');
CALL FiltrarUsuariosPA('suspendido', '1,3');
CALL FiltrarUsuariosPA('%', '');

-- Busqueda de Uusarios Sin Prestamos --

DELIMITER //
CREATE PROCEDURE UsuariosSinPrestamosPA()
BEGIN
    DECLARE v_cantidad INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_cantidad
    FROM usuarios u
    WHERE NOT EXISTS (SELECT 1 FROM prestamos p WHERE p.id_usuario = u.id_usuario);
    
    IF v_cantidad = 0 THEN
        SELECT 'Todos los usuarios han realizado al menos un préstamo' AS mensaje;
    ELSE
        SELECT 
            u.id_usuario, 
            u.nombre_u, 
            u.apellidos_u, 
            u.correo_u,
            tu.nombre_tu AS tipo_usuario
        FROM usuarios u
        INNER JOIN tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario
        WHERE u.id_usuario NOT IN (SELECT DISTINCT id_usuario FROM prestamos)
        ORDER BY u.apellidos_u;
    END IF;
END //
DELIMITER //

CALL UsuariosSinPrestamosPA();

--           Triggers           --

-- Validacion al Insertar en Prestamos --
DELIMITER //
CREATE TRIGGER before_insert_prestamos
BEFORE INSERT ON prestamos
FOR EACH ROW
BEGIN
    DECLARE v_estado_usuario VARCHAR(20);
    DECLARE v_multa_pendiente INT;
    DECLARE v_prestamos_activos INT;
    DECLARE v_limite INT;
    DECLARE v_estado_ejemplar VARCHAR(20);
    DECLARE v_tipo_usuario INT;
    DECLARE v_mensaje VARCHAR(255);
    
    SELECT estado_u, id_tipo_usuario INTO v_estado_usuario, v_tipo_usuario
    FROM usuarios WHERE id_usuario = NEW.id_usuario FOR UPDATE;
    
    IF v_estado_usuario != 'activo' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El usuario no está activo o está suspendido';
    END IF;
    
    SELECT COUNT(*) INTO v_multa_pendiente
    FROM multas WHERE id_usuario = NEW.id_usuario AND pagado_m = FALSE;
    
    IF v_multa_pendiente > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El usuario tiene multas pendientes';
    END IF;
    
    SELECT limite_prestamos_tu INTO v_limite
    FROM tipo_usuario WHERE id_tipo_usuario = v_tipo_usuario;
    
    SELECT COUNT(*) INTO v_prestamos_activos
    FROM prestamos WHERE id_usuario = NEW.id_usuario AND estado_p = 'activo';
    
    IF v_prestamos_activos >= v_limite THEN
        SET v_mensaje = CONCAT('El usuario ya alcanzó el límite de ', v_limite, ' préstamos activos');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje;
    END IF;
    
    SELECT estado_e INTO v_estado_ejemplar
    FROM ejemplares WHERE id_ejemplar = NEW.id_ejemplar FOR UPDATE;
    
    IF v_estado_ejemplar != 'disponible' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El ejemplar no está disponible para préstamo';
    END IF;
    
    IF NEW.fecha_devolucion_esperada_p IS NULL THEN
        SELECT dias_prestamo_tu INTO @dias
        FROM tipo_usuario WHERE id_tipo_usuario = v_tipo_usuario;
        SET NEW.fecha_devolucion_esperada_p = DATE_ADD(CURDATE(), INTERVAL @dias DAY);
    END IF;
    
    UPDATE ejemplares SET estado_e = 'prestado' WHERE id_ejemplar = NEW.id_ejemplar;
END //
DELIMITER //

-- Prueba Trigger before_insert_prestamos --
INSERT INTO prestamos (id_usuario, id_ejemplar, fecha_prestamo_p, fecha_devolucion_esperada_p, id_bibliotecario_presto)
VALUES (2, 1, NOW(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1);

INSERT INTO prestamos (id_usuario, id_ejemplar, fecha_prestamo_p, fecha_devolucion_esperada_p, id_bibliotecario_presto)
VALUES (3, 1, NOW(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1);

-- Actualizar al Devolver un Prestamo --

DELIMITER //
CREATE TRIGGER after_update_prestamo_devolucion
AFTER UPDATE ON prestamos
FOR EACH ROW
BEGIN
    DECLARE v_dias_retraso INT;
    DECLARE v_multa_diaria DECIMAL(5,2);
    DECLARE v_monto DECIMAL(8,2);
    DECLARE v_costo_ejemplar DECIMAL(8,2);
    DECLARE v_multa_maxima DECIMAL(8,2);
    DECLARE v_id_reserva INT;
    DECLARE v_id_usuario_reserva INT;
    DECLARE v_dias_gracia INT;
    
    IF NEW.estado_p = 'devuelto' AND OLD.estado_p != 'devuelto' THEN
        
        UPDATE ejemplares SET estado_e = 'disponible' WHERE id_ejemplar = NEW.id_ejemplar;
        
        IF NEW.fecha_devolucion_real_p > OLD.fecha_devolucion_esperada_p THEN
            SET v_dias_retraso = DATEDIFF(NEW.fecha_devolucion_real_p, OLD.fecha_devolucion_esperada_p);
            
            SELECT valor_cg INTO v_dias_gracia FROM configuracion_global WHERE clave_cg = 'dias_gracia';
            SET v_dias_gracia = COALESCE(v_dias_gracia, 0);
            
            IF v_dias_retraso > v_dias_gracia THEN
                SET v_dias_retraso = v_dias_retraso - v_dias_gracia;
                
                SELECT tu.multa_diaria_tu INTO v_multa_diaria
                FROM tipo_usuario tu
                JOIN usuarios u ON u.id_tipo_usuario = tu.id_tipo_usuario
                WHERE u.id_usuario = NEW.id_usuario;
                
                SELECT costo_e INTO v_costo_ejemplar FROM ejemplares WHERE id_ejemplar = NEW.id_ejemplar;
                SET v_multa_maxima = COALESCE(v_costo_ejemplar, 999999);
                
                SET v_monto = v_dias_retraso * v_multa_diaria;
                IF v_monto > v_multa_maxima THEN
                    SET v_monto = v_multa_maxima;
                END IF;
                
                IF NOT EXISTS (SELECT 1 FROM multas WHERE id_prestamo = NEW.id_prestamo) THEN
                    INSERT INTO multas (id_prestamo, id_usuario, monto_m, motivo_m, pagado_m)
                    VALUES (NEW.id_prestamo, NEW.id_usuario, v_monto, 'retraso', FALSE);
                END IF;
            END IF;
        END IF;
        
        SELECT id_reserva, id_usuario INTO v_id_reserva, v_id_usuario_reserva
        FROM reservas
        WHERE id_ejemplar = NEW.id_ejemplar AND estado_r = 'pendiente'
        ORDER BY posicion_cola_r ASC, fecha_solicitud_r ASC
        LIMIT 1;
        
        IF v_id_reserva IS NOT NULL THEN
            UPDATE reservas SET estado_r = 'activa' WHERE id_reserva = v_id_reserva;
            UPDATE ejemplares SET estado_e = 'reserva' WHERE id_ejemplar = NEW.id_ejemplar;
            INSERT INTO notificaciones (id_usuario, tipo_n, mensaje_n)
            VALUES (v_id_usuario_reserva, 'reserva_disponible', 
                    CONCAT('El ejemplar que reservó ya está disponible. Tiene 48 horas para recogerlo.'));
        END IF;
    END IF;
END //
DELIMITER //

-- Prueba de Trigger after_update_prestamo_devolucion --
INSERT INTO prestamos (id_usuario, id_ejemplar, fecha_prestamo_p, fecha_devolucion_esperada_p, id_bibliotecario_presto, estado_p)
VALUES (2, 3, '2025-04-01', '2025-04-10', 1, 'activo');
SET @id_prestamo = LAST_INSERT_ID();

UPDATE prestamos SET fecha_devolucion_real_p = CURDATE(), estado_p = 'devuelto' WHERE id_prestamo = @id_prestamo;

INSERT INTO reservas (id_usuario, id_ejemplar, estado_r) VALUES (4, 3, 'pendiente');

UPDATE prestamos SET estado_p = 'activo', fecha_devolucion_esperada_p = DATE_ADD(CURDATE(), INTERVAL 7 DAY) WHERE id_ejemplar = 3 AND estado_p = 'devuelto';

UPDATE prestamos SET fecha_devolucion_real_p = CURDATE(), estado_p = 'devuelto' WHERE id_ejemplar = 3;

SELECT * FROM reservas WHERE id_ejemplar = 3;
SELECT * FROM notificaciones WHERE id_usuario = 4;

-- Evita Multiples Multas por Un Mimso Prestamo --

DELIMITER //
CREATE TRIGGER before_insert_multa
BEFORE INSERT ON multas
FOR EACH ROW
BEGIN
    DECLARE v_existente INT;
    SELECT COUNT(*) INTO v_existente FROM multas WHERE id_prestamo = NEW.id_prestamo;
    IF v_existente > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ya existe una multa para este préstamo';
    END IF;
END //
DELIMITER //

-- Prueba de Trigger before_insert_multa --
INSERT INTO multas (id_prestamo, id_usuario, monto_m, motivo_m) VALUES (@id_prestamo, 2, 5.00, 'retraso');

-- Mantener Orden de Cola de Reservas --

DELIMITER //
CREATE TRIGGER before_insert_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_pos INT;
    SELECT COALESCE(MAX(posicion_cola_r), 0) + 1 INTO v_pos
    FROM reservas
    WHERE id_ejemplar = NEW.id_ejemplar;
    SET NEW.posicion_cola_r = v_pos;
END//
DELIMITER //

-- Prueba de Trigger after_insert_reserva --
INSERT INTO reservas (id_usuario, id_ejemplar, estado_r) VALUES (2, 1, 'pendiente');
INSERT INTO reservas (id_usuario, id_ejemplar, estado_r) VALUES (3, 1, 'pendiente');
INSERT INTO reservas (id_usuario, id_ejemplar, estado_r) VALUES (4, 1, 'pendiente');

SELECT id_reserva, posicion_cola_r FROM reservas WHERE id_ejemplar = 1 ORDER BY posicion_cola_r;

-- Auditoria Automatica para Prestamos --

DELIMITER //
CREATE TRIGGER after_insert_prestamo_audit
AFTER INSERT ON prestamos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_prestamo (id_prestamo, accion_ap, usuario_ejecutor, datos_nuevos_ap)
    VALUES (NEW.id_prestamo, 'INSERT', NEW.id_bibliotecario_presto, 
            JSON_OBJECT('id_prestamo', NEW.id_prestamo,  -- JSON formato de texto como dato estructurado --
                        'id_usuario', NEW.id_usuario,
                        'id_ejemplar', NEW.id_ejemplar,
                        'fecha_prestamo', NEW.fecha_prestamo_p,
                        'fecha_esperada', NEW.fecha_devolucion_esperada_p,
                        'estado', NEW.estado_p));
END//

CREATE TRIGGER after_update_prestamo_audit
AFTER UPDATE ON prestamos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_prestamo (id_prestamo, accion_ap, usuario_ejecutor, datos_anteriores_ap, datos_nuevos_ap)
    VALUES (NEW.id_prestamo, 'UPDATE', NEW.id_bibliotecario_presto,
            JSON_OBJECT('estado', OLD.estado_p, 
                        'fecha_esperada', OLD.fecha_devolucion_esperada_p,
                        'renovaciones', OLD.renovaciones_p,
                        'fecha_devolucion_real', OLD.fecha_devolucion_real_p),
            JSON_OBJECT('estado', NEW.estado_p,
                        'fecha_esperada', NEW.fecha_devolucion_esperada_p,
                        'renovaciones', NEW.renovaciones_p,
                        'fecha_devolucion_real', NEW.fecha_devolucion_real_p));
END //
DELIMITER //

-- Prueba de Trigger after_insert_prestamo_audit --
INSERT INTO prestamos (id_usuario, id_ejemplar, fecha_prestamo_p, fecha_devolucion_esperada_p, id_bibliotecario_presto)
VALUES (2, 1, NOW(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1);
SET @id_prestamo2 = LAST_INSERT_ID();

SELECT * FROM auditoria_prestamo WHERE id_prestamo = @id_prestamo2 AND accion_ap = 'INSERT';

UPDATE prestamos SET renovaciones_p = 1, fecha_devolucion_esperada_p = DATE_ADD(CURDATE(), INTERVAL 7 DAY) 
WHERE id_prestamo = @id_prestamo2;

SELECT * FROM auditoria_prestamo WHERE id_prestamo = @id_prestamo2 AND accion_ap = 'UPDATE';

-- Comprobar que Codigo de Barras sea Unico --

DELIMITER //
CREATE TRIGGER before_insert_ejemplar
BEFORE INSERT ON ejemplares
FOR EACH ROW
BEGIN
    DECLARE v_existente INT;
    SELECT COUNT(*) INTO v_existente FROM ejemplares WHERE codigo_barras_e = NEW.codigo_barras_e;
    IF v_existente > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El código de barras ya existe para otro ejemplar';
    END IF;
END //
DELIMITER //

-- Prueba de Trigger before_insert_ejemplar --
INSERT INTO ejemplares (id_titulo, codigo_barras_e) VALUES (1, 'EJ001');

-- Actualizar Fecha Automaticamente en Reservas al Programar una Devolucion --

DELIMITER //
CREATE TRIGGER after_insert_prestamo_reserva_estimada
AFTER INSERT ON prestamos
FOR EACH ROW
BEGIN
    DECLARE v_id_reserva INT;
    SELECT id_reserva INTO v_id_reserva
    FROM reservas
    WHERE id_ejemplar = NEW.id_ejemplar AND estado_r = 'pendiente'
    ORDER BY posicion_cola_r ASC, fecha_solicitud_r ASC
    LIMIT 1;
    
    IF v_id_reserva IS NOT NULL THEN
        UPDATE reservas
        SET fecha_disponible_r = NEW.fecha_devolucion_esperada_p
        WHERE id_reserva = v_id_reserva;
    END IF;
END //
DELIMITER //

-- Prueba de Trigger after_insert_prestamo_reserva_estimada --
INSERT INTO reservas (id_usuario, id_ejemplar, estado_r) VALUES (4, 1, 'pendiente') 
ON DUPLICATE KEY UPDATE estado_r ='pendiente';

UPDATE ejemplares SET estado_e = 'disponible' WHERE id_ejemplar = 1;
INSERT INTO prestamos (id_usuario, id_ejemplar, fecha_devolucion_esperada_p, id_bibliotecario_presto)
VALUES (2, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 1);

SELECT fecha_disponible_r FROM reservas WHERE id_ejemplar = 1 AND estado_r = 'pendiente' ORDER BY fecha_solicitud_r LIMIT 1;

--                      Creacion de Roles y Usuarios                          --

CREATE USER IF NOT EXISTS 'admin_bd'@'localhost' IDENTIFIED BY 'AdminBd#2025$eguro';
CREATE USER IF NOT EXISTS 'bibliotecario'@'localhost' IDENTIFIED BY 'Biblio#Prestamos2025';
CREATE USER IF NOT EXISTS 'consultor'@'localhost' IDENTIFIED BY 'Consul#Lectura2025';
CREATE USER IF NOT EXISTS 'auditor'@'localhost' IDENTIFIED BY 'Audit#Logs2025';

ALTER USER 'bibliotecario'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'consultor'@'localhost' PASSWORD EXPIRE INTERVAL 180 DAY;

CREATE ROLE 'admin_role', 'bibliotecario_role', 'consultor_role', 'auditor_role';

GRANT ALL ON gestion_biblioteca_sig.* TO 'admin_role' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON gestion_biblioteca_sig.usuarios TO 'bibliotecario_role';

GRANT 'admin_role' TO 'admin_bd'@'localhost';
GRANT 'bibliotecario_role' TO 'bibliotecario'@'localhost';
GRANT 'consultor_role' TO 'consultor'@'localhost';
GRANT 'auditor_role' TO 'auditor'@'localhost';

SET DEFAULT ROLE 'bibliotecario_role' TO 'bibliotecario'@'localhost';

DELIMITER //
CREATE FUNCTION VerificarCredencial(p_correo VARCHAR(100), p_contraseña VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_hash VARCHAR(255);
    SELECT contraseña_u INTO v_hash FROM usuarios WHERE correo_u = p_correo;
    RETURN v_hash = SHA2(p_contraseña, 256); -- SHA2 para guardado de contraseñas seguro --
END //
DELIMITER //

REVOKE FILE, SHOW DATABASES, CREATE USER, RELOAD ON *.* FROM 'admin_bd'@'localhost';

-- Para registro de conexion a base de datos --
CREATE TABLE log_acceso (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    ip VARCHAR(50),
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    comando VARCHAR(50)
);
Select * from log_acceso;

SET GLOBAL init_connect = 'INSERT INTO gestion_biblioteca_sig.log_acceso (usuario, ip) VALUES (USER(), SUBSTRING_INDEX(USER(), ''@'', -1))';
-- init_connect variable del sistema de ejecucion automatica de sentencias sql al conectar servidor --

SELECT user, host FROM mysql.user; -- listado de todos los roles de usuarios disponibles --

SHOW GRANTS FOR 'bibliotecario'@'localhost'; -- mostrar permisos 

ALTER USER 'bibliotecario'@'localhost' IDENTIFIED BY 'NuevaClave#2025'; -- para cambio de contraseñas periodicamente

SELECT CURRENT_USER();