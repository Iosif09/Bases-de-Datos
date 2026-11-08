Create Database Vehiculos;
Use Vehiculos;
Create Table Cliente (
	Codigo_Interno int auto_increment primary key not null,
	RFC_Cliente varchar (13),
    Nombre_Cliente varchar (30),
    Direccion_Cliente varchar (100),
    Ciudad varchar (30),
    Numero_Telefono int
    );
Create Table Consesionario (
	RFC_Consesionario varchar (13) primary key not null,
	Nombre_Consesionario varchar (20),
    Direccion_Consesionario varchar (100)
    );
Create Table Vehiculos (
	Matricula varchar (17) primary key not null,
	Marca varchar (20),
    Modelo varchar (20),
    Color varchar (20),
    Precio_Venta int,
    Codigo_Interno int,
    Constraint FK_Codigo_Interno_V Foreign key (Codigo_Interno) references Cliente(Codigo_Interno)
    );
Create Table Revisiones (
	Codigo_Unico int auto_increment primary key not null,
	Fecha_Revision date,
    Estado_Revision varchar (100),
    Revision_Realizado varchar (100),
    RFC_Consesionario varchar (13),
    Constraint FK_RFC_Consesionario_R foreign key (RFC_Consesionario) references Consesionario(RFC_Consesionario)
    );
Create Table Vehiculo_Revision (
	Codigo_V_R int auto_increment primary key not null,
	Matricula varchar (17),
    Codigo_Unico int,
    Constraint FK_Matricula_VR foreign key (Matricula) references Vehiculos(Matricula),
    Constraint FK_Codigo_Unico_VR foreign key (Codigo_Unico) references Revisiones(Codigo_Unico)
    );

CREATE TABLE Historico (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Usuario VARCHAR(50),
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Tabla_Afectada VARCHAR(50),
    Datos_Eliminados TEXT
);
    
select * from Vehiculos;
Select * from Revisiones;
Select * from Cliente;
select * from Consesionario;
select * from Vehiculo_Revision;

Insert Into Cliente (RFC_Cliente, Nombre_Cliente, Direccion_Cliente, Ciudad, Numero_Telefono)
values ('GOMJ850412ABC', 'Juan Gómez', 'Av. Insurgentes Sur 1234, Col. Del Valle', 'Ciudad de México', 555123456), 
		('MARL920715XYZ', 'Laura Martínez', 'Calle Reforma 567, Col. Centro', 'Puebla', 222765432), 
		('PERE800101QWE', 'Carlos Pérez', 'Blvd. Díaz Ordaz 890, Col. Industrial', 'Monterrey', 818987654), 
        ('RODR950630RTY', 'Ana Rodríguez', 'Av. Universidad 345, Col. Roma', 'Guadalajara', 333456789), 
        ('SANC990210UIO', 'Luis Sánchez', 'Calle Juárez 678, Col. San Pedro', 'Querétaro', 442112233);

Insert Into Consesionario (RFC_Consesionario, Nombre_Consesionario, Direccion_Consesionario)
values ('CONA850412ABC', 'Autos del Norte', 'Av. Constitución 1234, Col. Centro, Monterrey, NL'), 
		('CONB920715XYZ', 'Motors Puebla', 'Calle 5 de Mayo 567, Col. La Paz, Puebla, PUE'), 
        ('CONC800101QWE', 'Distribuidora Sur', 'Blvd. Miguel Alemán 890, Col. Industrial, Mérida, YUC'), 
        ('COND950630RTY', 'Autos Guadalajara', 'Av. Patria 345, Col. Providencia, Guadalajara, JAL'), 
        ('CONE990210UIO', 'Querétaro Motors', 'Calle Corregidora 678, Col. San Pedro, Querétaro, QRO');

Insert Into Vehiculos (Matricula, Marca, Modelo, Color, Precio_Venta, Codigo_Interno)
values ('1HGCM82633A004352', 'Honda', 'Civic', 'Rojo', 250000, 1),
		('2T1BURHE5JC123456', 'Toyota', 'Corolla', 'Blanco', 230000, 2), 
        ('3FAHP0HA7AR987654', 'Ford', 'Fusion', 'Negro', 280000, 3), 
        ('5YJSA1E26HF000789', 'Tesla', 'Model S', 'Azul', 1200000, 4), 
        ('WVWZZZ1JZXW000321', 'Volkswagen', 'Jetta', 'Gris', 270000, 5);
        
Insert Into Revisiones (Fecha_Revision, Estado_Revision, Revision_Realizado, RFC_Consesionario)
values ('2025-01-15', 'Aprobada sin observaciones', 'Cambio de aceite y filtros', 'CONA850412ABC'), 
		('2025-02-10', 'Pendiente de refacciones', 'Revisión de frenos y suspensión', 'CONB920715XYZ'), 
        ('2025-03-05', 'Aprobada con recomendaciones', 'Ajuste de motor y limpieza de inyectores', 'CONC800101QWE'), 
        ('2025-04-20', 'Rechazada por fallas críticas', 'Diagnóstico eléctrico completo', 'COND950630RTY'), 
        ('2025-05-12', 'Aprobada sin observaciones', 'Revisión general y alineación', 'CONE990210UIO');
        
INSERT INTO Vehiculo_Revision (Matricula, Codigo_Unico)
VALUES	('1HGCM82633A004352', 1),
		('2T1BURHE5JC123456', 2),
		('3FAHP0HA7AR987654', 3),
		('5YJSA1E26HF000789', 4),
		('WVWZZZ1JZXW000321', 5);
        
-- Semana 4

DELIMITER //
Create Procedure InsertarDatosClientePA (
    in PA_RFC_Cliente varchar (13),
    in PA_Nombre_Cliente varchar (30),
    in PA_Direccion_Cliente varchar (100),
    in PA_Ciudad varchar (30),
    in PA_Numero_Telefono int)
begin 
Insert Into Cliente (RFC_Cliente, Nombre_Cliente, Direccion_Cliente, Ciudad, Numero_Telefono)
values (PA_RFC_Cliente,
		PA_Nombre_Cliente,
        PA_Direccion_Cliente,
        PA_Ciudad,
        PA_Numero_Telefono);
Select * from Cliente;
End//
DELIMITER //

CALL InsertarDatosClientePA('RODI98274345T', 'Jose Alfredo', 'Indios Verdes No20 Padrera', 'Edo Mexico', 556793782);
Call InsertarDatosClientePA('DI4D84NMF832N', 'Maira Maria', 'Roma 125 Benito Juarez', 'Ciudad de Meixco', 553927490);
Call InsertarDatosClientePA('IFJ5483IFG9NM', 'Carlos Rodriguez', 'Cuauthemoc La Merced No40', 'Ciudad de Mexico', '569876302');

DELIMITER //
create procedure InsertarDatosConsesionarioPA(
	in PA_RFC_Consesionario varchar (13),
	IN PA_Nombre_Consesionario varchar (20),
    IN PA_Direccion_Consesionario varchar (100))
BEGIN
	INSERT INTO Consesionario(RFC_Consesionario, Nombre_Consesionario, Direccion_Consesionario)
    values (PA_RFC_Consesionario,
			PA_Nombre_Consesionario,
			PA_Direccion_Consesionario);
	Select * From Consesionario;
END //
DELIMITER //

Call InsertarDatosConsesionarioPA('JF8490GTO2184', 'Carros Guadalajara', 'Venustiano Carranza No245');
Call InsertarDatosConsesionarioPA('O495HFTEO09RM', 'Vehiculos Volks SA', 'Tlalpan Coyota SN');
Call InsertarDatosConsesionarioPA('CJE94HF84NEW9', 'Motores Nacinales', 'Cuauthemoc La Prava No20');

DELIMITER //
Create Procedure InsertarDatosVehiculosPA(
	in PA_Matricula varchar (17),
	in PA_Marca varchar (20),
    in PA_Modelo varchar (20),
    in PA_Color varchar (20),
    in PA_Precio_Venta int,
    in PA_Codigo_Interno int)
begin
	Insert Into Vehiculos(Matricula, Marca, Modelo, Color, Precio_Venta, Codigo_Interno)
    Values (PA_Matricula,
			PA_Marca,
			PA_Modelo,
			PA_Color,
			PA_Precio_Venta,
			PA_Codigo_Interno);
	Select * from Vehiculos;
END //
DELIMITER //

Call InsertarDatosVehiculosPA('OD937F85JG0RM', 'Toyota', 'Sedan', 'Negro', 35000, 6);
Call InsertarDatosVehiculosPA('F9834H9FNW98D', 'Dodge', 'Challenger', 'Naranja', 225000, 7);
Call InsertarDatosVehiculosPA('8945G89HJ34T8', 'Volkswagen', 'Betlee', 'Amarillo', 70000, 8);

DELIMITER //
create Procedure InsertarDatosRevisiones(
	in PA_Fecha_Revision date,
    in PA_Estado_Revision varchar (100),
    in PA_Revision_Realizado varchar (100),
    in PA_RFC_Consesionario varchar (13))
begin
	Insert Into Revisiones(Fecha_Revision, Estado_Revision, Revision_Realizado, RFC_Consesionario)
    values (PA_Fecha_Revision,
			PA_Estado_Revision,
			PA_Revision_Realizado,
			PA_RFC_Consesionario);
	Select * From Revisiones;
END //
DELIMITER //

Call InsertarDatosRevisiones('2025-04-20', 'Aprovada sin Observaciones', 'Cambio de Balatas', 'CJE94HF84NEW9');
Call InsertarDatosRevisiones('2025-05-29', 'Aprovada con Observaciones', 'Mantenimiento de Motor', 'JF8490GTO2184');
Call InsertarDatosRevisiones('2025-12-01', 'En Revision', 'Cambio de Susoension', 'O495HFTEO09RM');

DELIMITER //
Create Procedure InsertarDatosVRPA(
	in PA_Matricula varchar (17),
    in PA_Codigo_Unico int)
BEGIN
	Insert Into Vehiculo_Revision (Matricula, Codigo_Unico)
	values (PA_Matricula,
			PA_Codigo_Unico);
	sELECT * From Vehiculo_Revision;
END //
DELIMITER //

Call InsertarDatosVRPA('OD937F85JG0RM', 6);
Call InsertarDatosVRPA('F9834H9FNW98D', 7);
Call InsertarDatosVRPA('8945G89HJ34T8', 8);

-- Semana 6

DELIMITER //
Create Procedure PrecioVentaAutos()
BEGIN
	Update Vehiculos set Precio_Venta = Precio_Venta + ((4 * Precio_Venta)/(100)) where Precio_Venta > 250000;
    Select * From Vehiculos;
END //
DELIMITER //

Call PrecioVentaAutos;

DELIMITER //
Create Procedure ActuDIRTEL(
	in PA_Direccion_Cliente varchar (100),
    in PA_Numero_Telefono int
)
BEGIN
	Update  Cliente set Direccion_Cliente = PA_Direccion_Cliente , Numero_Telefono = PA_Numero_Telefono
		where Codigo_Interno = 8;
END //
DELIMITER //

Call ActuDIRTEL('Villa de Aragon No130 La Pradera', '559012539');

DELIMITER //
Create Procedure DatosRevision (
	in PA_Estado_Revision varchar (100),
    in PA_Revision_Realizado varchar (100))
BEGIN
	Update Revisiones set Estado_Revision = PA_Estado_Revision, Revision_Realizado = PA_Revision_Realizado 
		where Codigo_Unico = 3;
	Select * From Revisiones;
END //
DELIMITER //

Call DatosRevision('Completado', 'Cambio de Balatas');

DELIMITER //
Create Procedure InfoVehiculosClientes (
	in p_matricula varchar (17))
BEGIN
	Select Cliente.RFC_Cliente, Cliente.Nombre_Cliente, Vehiculos.Matricula, Vehiculos.Modelo, Vehiculos.Precio_Venta,
    Revisiones.Codigo_Unico, Revisiones.Estado_Revision, Revisiones.Revision_Realizado, Revisiones.Fecha_Revision
	FROM Cliente
		INNER JOIN Vehiculos
			ON Cliente.Codigo_Interno = Vehiculos.Codigo_Interno
		INNER JOIN Vehiculo_Revision
			ON Vehiculos.Matricula = Vehiculo_Revision.Matricula
		INNER JOIN Revisiones
			ON Vehiculo_Revision.Codigo_Unico = Revisiones.Codigo_Unico where Vehiculos.Matricula = p_matricula;
END //
DELIMITER //
        
Call InfoVehiculosClientes('WVWZZZ1JZXW000321');
        
DELIMITER //
Create Procedure DelVehiculos(
	in PA_Codigo_Unico int)
BEGIN
	Delete From Vehiculo_Revision where Codigo_Unico = 3;
	Delete From Revisiones where Codigo_Unico = PA_Codigo_Unico;
    Select * From Revisiones;
END //
DELIMITER //

Call DelVehiculos(3);

-- Semana 7

DELIMITER //
Create Procedure SINREVISION ()
BEGIN
	Select Cliente.RFC_Cliente, Cliente.Nombre_Cliente, Vehiculos.Matricula, Vehiculos.Modelo,
    Revisiones.Codigo_Unico, Revisiones.Estado_Revision
	FROM Cliente
		INNER JOIN Vehiculos
			ON Cliente.Codigo_Interno = Vehiculos.Codigo_Interno
		INNER JOIN Vehiculo_Revision
			ON Vehiculos.Matricula = Vehiculo_Revision.Matricula
		INNER JOIN Revisiones
			ON Vehiculo_Revision.Codigo_Unico = Revisiones.Codigo_Unico 
		where Estado_Revision = 'Sin Revisiones';
END //
DELIMITER //

Call SINREVISION;

-- Semana 8

DELIMITER //
CREATE TRIGGER validar_precio_vehiculo_insert
BEFORE INSERT ON Vehiculos
FOR EACH ROW
BEGIN
    IF NEW.Precio_Venta <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: El Precio_Venta del vehículo debe ser mayor a 0. Por favor, ingrese un precio válido.';
    END IF;
END //
DELIMITER //

DELIMITER //
CREATE TRIGGER trg_delete_vehiculos
AFTER DELETE ON Vehiculos
FOR EACH ROW
BEGIN
    INSERT INTO Historico (Usuario, Tabla_Afectada, Datos_Eliminados)
    VALUES (
        CURRENT_USER(),
        'Vehiculos',
        CONCAT('Matricula: ', OLD.Matricula,
               ', Marca: ', OLD.Marca,
               ', Modelo: ', OLD.Modelo,
               ', Color: ', OLD.Color,
               ', Precio_Venta: ', OLD.Precio_Venta,
               ', Codigo_Interno: ', OLD.Codigo_Interno));
END //
DELIMITER //

DELETE FROM Vehiculos WHERE Matricula = 'ABC123';

-- Semana 9

Create User 'admin_autos'@'localhost' identified by 'admin_autos';
Create User 'vendedor1'@'localhost' identified by 'vendedor1';
Create User 'consultar1'@'localhost' identified by 'consultar1';

Create Role 'Rol_Admin';
Grant All on Vehiculos.Vehiculos to 'Rol_Admin';
Grant 'Rol_Admin' to 'admin_autos';

Create Role 'Rol_Vendedor';
Grant Select on Vehiculos.Vehiculos to 'Rol_Vendedor';
Grant Select, Insert, Update on Vehiculos.Cliente to 'Rol_Vendedor';
Grant 'Rol_Vendedor' to 'vendedor1';

Create Role 'Consultor';
Grant Select on Vehiculos.* to 'Consultor';
Grant 'Consultor' to 'consultar1';

Set Default Role 'Rol_Admin' to 'admin_autos'@'localhost';
Set Default Role 'Rol_Vendedor' to 'vendedor1'@'localhost';
Set Default Role 'Consultor' to 'consultar1'@'localhost';