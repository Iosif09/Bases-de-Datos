Create Database Clinica_SanPatras;

Use Clinica_SanPatras;

Create Table Pacientes (
	Codigo_Paciente int auto_increment primary key not null,
	Nombre_Paciente varchar (40),
    Apellido_Pacientes varchar (40),
    Direccion varchar (100),
    Poblacion varchar (100),
    Provincia varchar (100),
    Codigo_Postal int,
    Telefono_Paciente int,
    Fecha_Nacimiento date);

Create Table Medicos (
	Codigo_Medico int primary key not null,
    Nombre_Medico varchar (40),
    Apellido_Medico varchar (40),
    Telefono_Medico int,
    Especialidad varchar (30));

Create Table Registro_Ingreso (
	Codigo_Ingreso int auto_increment primary key not null,
    Numero_Habitacion int,
    Numero_Cama int,
    Fecha_Ingreso date,
    Codigo_Paciente int,
    Codigo_Medico int,
    Constraint FK_Codigo_Paciente foreign key (Codigo_Paciente) references Pacientes(Codigo_Paciente),
    Constraint FK_Codigo_Medico foreign key (Codigo_Medico) references Medicos(Codigo_Medico));
    
Select * from Pacientes;
Select * From Medicos;
Select * from Registro_Ingreso;

INSERT INTO Pacientes (Nombre_Paciente, Apellido_Pacientes, Direccion, Poblacion, Provincia, Codigo_Postal, Telefono_Paciente, Fecha_Nacimiento) 
VALUES ('María', 'González', 'Av. Reforma 123', 'Ciudad de México', 'CDMX', 01000, 555123456, '1985-03-12'), 
		('Juan', 'Pérez', 'Calle Hidalgo 45', 'Guadalajara', 'Jalisco', 44100, 333987654, '1990-07-25'), 
        ('Lucía', 'Ramírez', 'Av. Juárez 678', 'Monterrey', 'Nuevo León', 64000, 818765432, '1978-11-05'), 
        ('Carlos', 'Fernández', 'Calle Morelos 89', 'Puebla', 'Puebla', 72000, 222456789, '2000-01-15'), 
        ('Ana', 'Martínez', 'Av. Insurgentes 321', 'Toluca', 'Estado de México', 50000, 722345678, '1995-09-30');

INSERT INTO Medicos (Codigo_Medico, Nombre_Medico, Apellido_Medico, Telefono_Medico, Especialidad)
VALUES	(1, 'Laura', 'Sánchez', 555987654, 'Cardiología'),
		(2, 'Miguel', 'Hernández', 555123789, 'Pediatría'),
		(3, 'Sofía', 'López', 555456123, 'Dermatología'),
		(4, 'Andrés', 'Martínez', 555789321, 'Neurología'),
		(5, 'Carolina', 'Ramírez', 555321987, 'Ginecología');

INSERT INTO Registro_Ingreso (Numero_Habitacion, Numero_Cama, Fecha_Ingreso, Codigo_Paciente, Codigo_Medico)
VALUES	(101, 1, '2024-12-01', 1, 2),
		(102, 2, '2024-12-05', 2, 1),
		(103, 1, '2024-12-10', 3, 4),
		(104, 2, '2024-12-15', 4, 3),
		(105, 1, '2024-12-20', 5, 5);

-- Semana 4

DELIMITER //
Create Procedure InsertarDatosPacientesPA(
	IN PA_Nombre_Paciente varchar (40),
    IN PA_Apellido_Pacientes varchar (40),
    IN PA_Direccion varchar (100),
    IN PA_Poblacion varchar (100),
    IN PA_Provincia varchar (100),
    IN PA_Codigo_Postal int,
    IN PA_Telefono_Paciente int,
    IN PA_Fecha_Nacimiento date)
BEGIN
	Insert Into Pacientes(Nombre_Paciente, Apellido_Pacientes, 
		Direccion, Poblacion, Provincia, Codigo_Postal, Telefono_Paciente, Fecha_Nacimiento)
        values (PA_Nombre_Paciente,
				PA_Apellido_Pacientes,
				PA_Direccion,
				PA_Poblacion,
				PA_Provincia,
				PA_Codigo_Postal,
				PA_Telefono_Paciente,
				PA_Fecha_Nacimiento);
	Select * From Pacientes;
end //
delimiter //

Call InsertarDatosPacientesPA('María', 'González', 'Av. Reforma 123', 'Ciudad de México', 'CDMX', 11000, 555123456, '1990-05-14');
Call InsertarDatosPacientesPA('Juan', 'Pérez', 'Calle Hidalgo 456', 'Guadalajara', 'Jalisco', 44100, 333987654, '1985-09-23');
Call InsertarDatosPacientesPA('Lucía', 'Ramírez', 'Blvd. Insurgentes 789', 'Monterrey', 'Nuevo León', 64000, 818765432, '1992-12-01');

DELIMITER //
Create Procedure InsertarDatosMedicosPA (
	in PA_Codigo_Medico int,
    in PA_Nombre_Medico varchar (40),
    in PA_Apellido_Medico varchar (40),
    in PA_Telefono_Medico int,
    in PA_Especialidad varchar (30))
BEGIN
	Insert Into Medicos(Codigo_Medico, Nombre_Medico, Apellido_Medico, Telefono_Medico, Especialidad)
	values (PA_Codigo_Medico,
			PA_Nombre_Medico,
			PA_Apellido_Medico,
			PA_Telefono_Medico,
			PA_Especialidad);
	Select * From Medicos;
end //
delimiter //

Call InsertarDatosMedicosPA(6, 'Carlos', 'Hernández', 555123456, 'Cardiología');
Call InsertarDatosMedicosPA(7, 'Ana', 'Martínez', 555987654, 'Pediatría');
Call InsertarDatosMedicosPA(8, 'Luis', 'Ramírez', 555765432, 'Neurología');

DELIMITER //
Create Procedure InsertarDatosRIPA(
	in PA_Numero_Habitacion int,
    IN PA_Numero_Cama int,
    IN PA_Fecha_Ingreso date,
    IN PA_Codigo_Paciente int,
    IN PA_Codigo_Medico int)
begin
	insert into Registro_Ingreso(Numero_Habitacion, Numero_Cama, Fecha_Ingreso,
	Codigo_Paciente, Codigo_Medico)
    values (PA_Numero_Habitacion,
			PA_Numero_Cama,
			PA_Fecha_Ingreso,
			PA_Codigo_Paciente,
			PA_Codigo_Medico);
	Select * From Registro_Ingreso;
END //
DELIMITER //

Call InsertarDatosRIPA(201, 1, '2026-02-07', 6, 7);
Call InsertarDatosRIPA(202, 2, '2026-02-07', 7, 8);
Call InsertarDatosRIPA(203, 1, '2026-02-08', 8, 6);

-- Semana 6

DELIMITER //
Create Procedure ActTel (
	in PA_Telefono_Paciente int,
    in PA_Codigo_Paciente int)
BEGIN
	Update Pacientes set Telefono_Paciente = PA_Telefono_Paciente 
		where Codigo_Paciente = PA_Codigo_Paciente;
    select Codigo_Paciente, Nombre_Paciente, Apellido_Pacientes, Telefono_Paciente from Pacientes
		where Codigo_Paciente = PA_Codigo_Paciente;
END //
DELIMITER //

Call ActTel (567498721, 3);

DELIMITER //
Create Procedure EspecialidadMed(
	IN PA_Apellido_Medico varchar (40),
    in PA_Especialidad varchar (30))
BEGIN
	update Medicos set Especialidad = PA_Especialidad
		where Apellido_Medico = PA_Apellido_Medico;
	select Codigo_Medico, Nombre_Medico, Apellido_Medico, Especialidad from Medicos
		where Apellido_Medico = PA_Apellido_Medico;
END //
DELIMITER //

Call EspecialidadMed('Hernández', 'Medico General');

DELIMITER //
Create Procedure IngresoCama (
	in PA_Codigo_Ingreso int,
    in PA_Numero_Habitacion int,
    in PA_Numero_Cama int)
BEGIN
	Update Registro_Ingreso set Numero_Habitacion = PA_Numero_Habitacion, Numero_Cama = PA_Numero_Cama
		where Codigo_Ingreso = PA_Codigo_Ingreso;
	select Codigo_Ingreso, Numero_Habitacion, Numero_Cama, Fecha_Ingreso, Codigo_Paciente from Registro_Ingreso
		where Codigo_Ingreso = PA_Codigo_Ingreso;
END //
DELIMITER //

Call IngresoCama(3, 110, 3);

DELIMITER // 
CREATE PROCEDURE EliminarPacienteDesdeFecha (
    IN PA_CodigoPaciente INT,
    IN PA_Fecha DATE)
BEGIN
    DELETE FROM Registro_Ingreso
    WHERE Codigo_Paciente = PA_CodigoPaciente
      AND Fecha_Ingreso >= PA_Fecha;

    DELETE FROM Pacientes
    WHERE Codigo_Paciente = PA_CodigoPaciente;
    Select * From Pacientes;
END //
DELIMITER //

Call EliminarPacienteDesdeFecha(3, '2024-12-10');

DELIMITER //
CREATE PROCEDURE ReporteIngresosPorMedico()
BEGIN
    SELECT 
        M.Codigo_Medico,
        M.Nombre_Medico,
        M.Apellido_Medico,
        M.Especialidad,
        COUNT(ri.Codigo_Ingreso) AS Total_Ingresos
    FROM Medicos M
    LEFT JOIN Registro_Ingreso ri 
        ON m.Codigo_Medico = ri.Codigo_Medico
    GROUP BY m.Codigo_Medico, m.Nombre_Medico, m.Apellido_Medico, m.Especialidad
    ORDER BY Total_Ingresos DESC;
END //
DELIMITER //

CALL ReporteIngresosPorMedico();

DELIMITER //
CREATE PROCEDURE ValidarOcupacionActual (
    IN p_NumeroHabitacion INT,
    IN p_NumeroCama INT)
BEGIN
    SELECT 
        ri.Numero_Habitacion, ri.Numero_Cama, ri.Fecha_Ingreso, p.Nombre_Paciente,
        p.Apellido_Pacientes, m.Nombre_Medico, m.Apellido_Medico, m.Especialidad,
        CASE 
            WHEN ri.Fecha_Ingreso >= CURDATE() THEN 'Ocupada'
            ELSE 'Disponible'
        END AS Estado_Cama
    FROM Registro_Ingreso ri
    INNER JOIN Pacientes p 
		ON ri.Codigo_Paciente = p.Codigo_Paciente
    INNER JOIN Medicos m 
		ON ri.Codigo_Medico = m.Codigo_Medico
    WHERE ri.Numero_Habitacion = p_NumeroHabitacion
      AND ri.Numero_Cama = p_NumeroCama;
END //
DELIMITER //

CALL ValidarOcupacionActual(101, 1);

-- Semana 7

DELIMITER //
CREATE PROCEDURE IngresoPacientes()
BEGIN
    SELECT 
        p.Codigo_Paciente,
        p.Nombre_Paciente,
        p.Apellido_Pacientes,
        m.Codigo_Medico,
        m.Nombre_Medico,
        m.Apellido_Medico,
        COUNT(ri.Codigo_Ingreso) AS Total_Ingresos
    FROM Registro_Ingreso ri
    INNER JOIN Pacientes p ON ri.Codigo_Paciente = p.Codigo_Paciente
    INNER JOIN Medicos m ON ri.Codigo_Medico = m.Codigo_Medico
    GROUP BY p.Codigo_Paciente, p.Nombre_Paciente, p.Apellido_Pacientes,
             m.Codigo_Medico, m.Nombre_Medico, m.Apellido_Medico
    HAVING COUNT(ri.Codigo_Ingreso) > 1;
END //
DELIMITER ;

Call IngresoPacientes;

DELIMITER //
CREATE PROCEDURE RegistroNoAsociado()
BEGIN
    SELECT ri.Codigo_Ingreso,
           ri.Numero_Habitacion,
           ri.Numero_Cama,
           ri.Fecha_Ingreso,
           ri.Codigo_Paciente
    FROM Registro_Ingreso ri
    LEFT JOIN Pacientes p ON ri.Codigo_Paciente = p.Codigo_Paciente
    WHERE p.Codigo_Paciente IS NULL;

    DELETE FROM Registro_Ingreso
    WHERE Codigo_Paciente NOT IN (SELECT Codigo_Paciente FROM Pacientes);
END //
DELIMITER //

CALL RegistroNoAsociado();