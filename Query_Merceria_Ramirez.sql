Create Database Merceria_Ramirez;

Create Table Productos (C_Producto varchar (20) primary key not null, Nombre_Pd varchar (50), Precio int, Disponibilidad varchar (5), Descripcion varchar (50));

Create Table Proveedores (RFC_Pv varchar (20) primary key not null, Nombre_Pv varchar (30), Entrega_Pd varchar (50), Fecha_Ent date, Pedido_Ext varchar (50), Descripcion_P varchar (50));

Create Table Clientes (ID_Cliente varchar (10) primary key not null, Nombre_Cl varchar (20), Medio_Cotac varchar (100), Metodo_Pago varchar (20), Accion_Soli varchar (10));

Create Table Apartados (ID_Apr varchar (10) primary key not null, Nombre_Cl varchar (20), Fecha_Est_Entr date, Nombre_Pd varchar (50), Cantidad_A int, Descripcion_Ext varchar (50), Fecha_Exp date, ID_Cliente varchar (10),
constraint FK_ID_Cliente foreign key (ID_Cliente) references Clientes (ID_Cliente));

Create Table Encargos (ID_Encr varchar (10) primary key not null, Nombre_Cl varchar (20), Fecha_Exp date, Fecha_Ext_Entr date, Nombre_Pd varchar (50), Cantidad_Enc int, Descripcion_Ext varchar (50), ID_Cliente varchar (10),
constraint FK1_ID_Cliente foreign key (ID_Cliente) references Clientes (ID_Cliente));

Create Table Suministro (ID_Suministro varchar (10) primary key not null, RFC_Pv varchar (20), C_Producto varchar(20)
constraint FK_RFC_Pv foreign key (RFC_Pv) references Proveedores (RFC_Pv),
constraint FK1_C_Producto foreign key (C_Producto) references Productos (C_Producto));

Create Table Detalle_Apartado (ID_DA varchar (10) primary key not null, C_Producto varchar (20), ID_Apr varchar (10),
Constraint FK2_C_Producto foreign key (C_Producto) references Productos (C_Producto),
Constraint FK_ID_Apr foreign key (ID_Apr) references Apartados (ID_Apr));

Create Table Detalle_Encargo (ID_DE varchar (10) primary key not null, ID_Encr varchar (10), C_Producto varchar (20),
Constraint FK_ID_Encr foreign key (ID_Encr) references Encargos (ID_Encr),
Constraint FK3_C_Producto foreign key (C_Producto) references Productos (C_Producto));

Create Table Compra (ID_Compra varchar (10) primary key not null, C_Producto varchar (20), ID_Cliente varchar (10),
Constraint FK4_C_Producto foreign key (C_Producto) references Productos (C_Producto),
Constraint FK2_ID_Cliente foreign key (ID_Cliente) references Clientes (ID_Cliente));

select * from Clientes;

Insert Into Clientes (ID_Cliente, Nombre_Cl, Medio_Cotac, Metodo_Pago, Accion_Soli)
values 
('00001', 'Margarita', '5512837747', 'Efectivo', 'Compra'),
('00002', 'Carlos', 'carlosberto256@hotmail.com', 'Transferencia', 'Pedido'),
('00003', 'Roberto Pozos', '5641563721', 'Efectivo', 'Compra'),
('00004', 'Alejandro Vargaz', 'aleV@gmail.com', 'Targeta', 'Apartado'),
('00005', 'Marco Antonio', '5636234812', 'Targeta', 'Pedido'),
('00006', 'Gerardo Martinez', '@Gerard69', 'Transferencia', 'Apartado'),
('00007', 'Alicia Garcia', '5576837574', 'Efectivo', 'Compra'),
('00008', 'Fernando Lopez', 'fenan278@outlook.com', 'Efectivo', 'Compra'),
('00009', 'Rebeca Juarez', '5586748373', 'Transferencia', 'Pedido'),
('00010', 'Luis Alfredo', '54898237266', 'Targeta', 'Apartado');

Select * From Productos;

Insert Into Productos (C_Producto, Nombre_Pd, Precio, Disponibilidad, Descripcion)
values 
('00EDE920FR', 'Hilo Cañamo', '100', 'Si', 'Rollo de Hilo Cañamo Color Negro'),
('9J84E7DH4N', 'Hilo Nilon', '75', 'Si', 'Rollo de Hilo Nilon Varios Colores'),
('18SN74762H', 'Agujas La Moderna', '28', 'No', 'Paquete de Agujas Varias Medidas'),
('8932EFUEN37', 'Almohadon Blanco', '120', 'Si', 'Par de Almohadones en Blanco'),
('89HDV521CD', 'Mantel 30x20', '35', 'Si', 'Mantel con Estampado para Cocer'),
('63DG5DG48N', 'Cierre Metalico C', '27', 'No', 'Cierre Metalico Chico Varios Colores'),
('7836CV62', 'Estambre Matizo', '39', 'No', 'Rollo de Estambre Matizo Surtido'),
('3256VBNR6', 'Mantel Mesa', '150', 'Si', 'Mantel para Mesa 1Mx1.5M'),
('7483S53GG', 'Boton Negro Chico', '15', 'Si', 'Par de Botones Chicos Color Negro'),
('23S26GD4MV', 'Liston Rojo', '90', 'No', 'Rollo de Liston Color Rojo 7M');

Select * From Proveedores;

Insert Into Proveedores (RFC_Pv, Nombre_Pv, Entrega_Pd, Fecha_Ent, Pedido_Ext, Descripcion_P)
values 
('YHDE72HDBE7C', 'LaSuper', 'Envio y Entrega Personal', '2024-01-20', 'Hilo Cañamo', 'Rollo de Hilo Cañamo Verde'), 
('JD8493JF9J03', 'Cosmos SA. de CV', 'Entrega Por Partes', '2024-12-12', 'No', 'Ninguno'),
('7DC73JF84NG', 'Selanusa SA.', 'Entrega Exitosa', '2025-02-01', 'Estambre Metalico', 'Paquete de Estambre Metalico Surtido'),
('7D389HV983J', 'ElGuero SA. de CV.', 'Entrega Personal', '2025-03-02', 'No', 'Ninguno'),
('2873D920VINR', 'ALaMexicana', 'Entrega Por Partes', '2024-11-11', 'No', 'Ninguno'),
('48989H49H5YN', 'El GaTO SA.', 'Entrega Completa', '2023-03-12', 'Liston Surtido', 'Docena de Rollo de Liston Surtido'),
('98NFN9CE8CF9', 'Porfirio SA. de CV.', 'Entrega Tardia', '2024-05-23', 'No', 'Ninguno'),
('G9NFE9N342D', 'Ademersa SA. de CV.', 'Entrega Exitosa', '2023-01-09', 'Hilo Matizado', 'Docena de Rollo de Hilo Matizado Surtido'),
('93F923DH8DET', 'MerceriaAntuan', 'Envio Personal', '2020-10-29', 'No', 'Ninguno'),
('893FJ012DMI', 'Punto y Cruz SA. de CV.', 'Envio por Partes', '2021-10-19', 'Rollo de Tela', 'Rollo de Tela Blanco Punto de Cruz');

Select * From Apartados;

Insert Into Apartados (ID_Apr, Nombre_Cl, Fecha_Est_Entr, Nombre_Pd, Cantidad_A, Descripcion_Ext, Fecha_Exp, ID_Cliente)
values 
('000001', 'Gerardo Martinez', '2024-12-20', 'Hilo Cañamo', '3', 'No', '2024-12-18', '00006'),
('000002', 'Luis Alfredo', '2025-01-13', 'Mantel 30x30', '10', 'Estampados Aleatorios en Tela Blanca', '2025-01-03', '00002'),
('000004', 'Alegandro Vargaz', '2024-12-19', 'Mantel para Mesa 1M', '5', 'Tela Cuadrille', '2024-12-04', '00004'),
('000003', 'Felipe Armando', '2020-09-09', 'Botones Grandes', '20', 'Botones Grandes Diversas figuras Color Negro', '2020-09-01', '00001'),
('000005', 'Alejandra Robles', '2024-12-01', 'Mantel Cuadrille', '5', 'Ninguno', '2024-11-20', '00003'),
('000006', 'Daniel Martinez', '2023-10-03', 'Estambre Multicolor', '10', 'Rollos de Estambre Multicolor Matizado', '2023-09-27', '00005'),
('000007', 'Jose Hernandez', '2025-01-27', 'Cierres Largos', '15', 'Cierres Metalicos Largos Varios Colores','2025-01-20', '00007'),
('000008', 'Manuel Juvencio', '2024-12-27', 'Encajes Blancos', '5', 'Encaje Modelo Ya Seleccionado', '2024-12-19', '00008'),
('000009', 'Jose Alejandro', '2025-02-02', 'Liston Negro', '8', 'Rollos de Liston Negro 10M', '2025-02-01', '00009'),
('000010', 'Dennis Colin', '2023-10-10', 'Aros de Bordar', '10', 'Aros de Bordar Todas las Medidas', '2023-10-03', '00010');

Select * From Encargos;

Insert Into Encargos (ID_Encr, Nombre_Cl, Fecha_Exp, Fecha_Ext_Entr, Nombre_Pd, Cantidad_Enc, Descripcion_Ext, ID_Cliente)
values 
('000001', 'Carlos', '2021-03-04', '2021-03-10', 'Hilo Nilon Azul', '7', 'Colores Pastel Azul', '00002'),
('000002', 'Marco Antonio', '2025-01-20', '2025-01-27', 'Agujas Varios', '10', 'Varios Tamaños', '00005'),
('000003', 'Rebeca Juarez', '2020-06-01', '2020-06-05', 'Estambre Matizado', '12', 'Rollos de Estambre Matiado Rosa y Morado', '00009'),
('000004', 'Ana Gómez', '2022-04-12', '2022-04-18', 'Listón Verde', '8', 'Rollos de Listón Verde Oscuro', '00001'),
('000005', 'Juan Pablo', '2023-07-09', '2023-07-15', 'Botones Dorados', '15', 'Botones de Metal Dorado', '00003'),
('000006', 'Carla Fernández', '2024-11-01', '2024-11-06', 'Encaje Beige', '6', 'Encaje fino de color beige', '00004'),
('000007', 'Roberto Cruz', '2023-03-20', '2023-03-25', 'Tela Satinada', '9', 'Tela satinada en colores pastel', '00006'),
('000008', 'Victoria López', '2025-05-10', '2025-05-15', 'Hilos Metálicos', '10', 'Hilos metálicos para bordar', '00007'),
('000009', 'Santiago Álvarez', '2024-09-30', '2024-10-05', 'Cierres Cortos', '12', 'Cierres metálicos cortos varios colores', '00008'),
('000010', 'Fernanda Ruiz', '2023-12-15', '2023-12-20', 'Aros Grandes', '7', 'Aros grandes para bordar', '00010');

Select * from Suministro;

Insert Into Suministro (ID_Suministro, RFC_Pv, C_Producto)
values 
('0000320', '2873D920VINR', '00EDE920FR'),
('0004320', '48989H49H5YN', '9J84E7DH4N'),
('0000231', '7D389HV983J', '18SN74762H'),
('00000342', '7DC73JF84NG', '8932EFUEN37'),
('00000043', '893FJ012DMI', '89HDV521CD'),
('0000583', '93F923DH8DET', '63DG5DG48N'),
('0000642', '98NFN9CE8CF9', '7836CV62'),
('00008560', 'G9NFE9N342D', '3256VBNR6'),
('00048309', 'JD8493JF9J03', '7483S53GG'),
('00005130', 'YHDE72HDBE7C', '23S26GD4MV');

Select * From Detalle_Apartado;

Insert Into Detalle_Apartado (ID_DA, C_Producto, ID_Apr)
values 
('00392038', '00EDE920FR', '000001'),
('03493288', '9J84E7DH4N', '000002'),
('02739200', '18SN74762H', '000003'),
('000034280', '8932EFUEN37', '000004'),
('004382845', '89HDV521CD', '000005'),
('003283900', '63DG5DG48N', '000006'),
('09432901', '7836CV62', '000007'),
('00788430', '3256VBNR6', '000008'),
('093928832', '7483S53GG', '000009'),
('092871634', '23S26GD4MV', '000010');

Select * From Detalle_Encargo;

Insert Into Detalle_Encargo (ID_DE, ID_Encr, C_Producto)
values 
('932871432', '000001', '00EDE920FR'),
('98393292', '000002', '18SN74762H'),
('73276198', '000003', '23S26GD4MV'),
('23762398', '000004', '3256VBNR6'),
('87865645', '000005', '63DG5DG48N'),
('23433545', '000006', '7483S53GG'),
('5465433', '000007', '7836CV62'),
('2435654', '000008','8932EFUEN37'),
('226554', '000009', '89HDV521CD'),
('975436', '000010', '9J84E7DH4N');

Select * From Compra;

Insert Into Compra (ID_Compra, C_Producto, ID_Cliente)
values 
('0003289', '89HDV521CD', '00001'),
('0000321', '7483S53GG', '00002'),
('0016320', '3256VBNR6', '00003'),
('0000718', '8932EFUEN37', '00004'),
('0000327', '7836CV62', '00005'),
('0003261', '23S26GD4MV', '00006'),
('0006281', '63DG5DG48N', '00007'),
('0002617', '00EDE920FR', '00008'),
('0009862', '9J84E7DH4N', '00009'),
('0001735', '18SN74762H', '00010');