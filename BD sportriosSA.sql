CREATE DATABASE sportrios_alquiler_db;
GO

USE sportrios_alquiler_db;
GO

-- ===========================================================================
-- 1. CREACIÓN DE TABLAS (ESTRUCTURA RELACIONAL 3FN)
-- ===========================================================================

-- TABLA: Sedes (La infraestructura general)
CREATE TABLE Sedes (
    id_sede INT IDENTITY(1,1),
    nombre_sede VARCHAR(100) NOT NULL,
    direccion_sede VARCHAR(255) NOT NULL,
    CONSTRAINT pk_sedes PRIMARY KEY (id_sede)
);

-- TABLA: Canchas (Especifica detalladamente cada escenario deportivo por sede)
CREATE TABLE Canchas (
    id_cancha INT IDENTITY(1,1),
    id_sede INT NOT NULL,
    nombre_cancha VARCHAR(100) NOT NULL,
    tipo_disciplina VARCHAR(50) NOT NULL,        
    tipo_superficie VARCHAR(50) NOT NULL,         
    tarifa_hora_dia NUMERIC(10, 2) NOT NULL,
    tarifa_hora_noche NUMERIC(10, 2) NOT NULL,
    CONSTRAINT pk_canchas PRIMARY KEY (id_cancha),
    CONSTRAINT fk_canchas_sedes FOREIGN KEY (id_sede) REFERENCES Sedes (id_sede),
    CONSTRAINT chk_tarifa_dia CHECK (tarifa_hora_dia >= 0),
    CONSTRAINT chk_tarifa_noche CHECK (tarifa_hora_noche >= 0)
);

-- TABLA: Clientes (Entidad exclusiva para las personas que alquilan)
CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1),
    cedula VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(150),
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cedula_cliente UNIQUE (cedula)
);

-- TABLA: Empleados (Entidad exclusiva para el personal del complejo)
CREATE TABLE Empleados (
    id_empleado INT IDENTITY(1,1),
    cedula VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(150),
    rol_sistema VARCHAR(30) NOT NULL,            
    CONSTRAINT pk_empleados PRIMARY KEY (id_empleado),
    CONSTRAINT uq_cedula_empleado UNIQUE (cedula),
    CONSTRAINT chk_rol_sistema CHECK (rol_sistema IN ('Administrador', 'Recepcionista', 'Contador'))
);

-- TABLA: ReservasAlquileres (Registra el movimiento e ingresos del negocio)
CREATE TABLE ReservasAlquileres (
    id_reserva INT IDENTITY(1,1),
    id_cancha INT NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado_receptor INT NOT NULL,           
    fecha_reserva DATE NOT NULL,                  
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tipo_horario VARCHAR(20) NOT NULL,            
    estado_pago VARCHAR(20) DEFAULT 'Pendiente' NOT NULL, 
    metodo_pago VARCHAR(30),                      
    monto_ingreso NUMERIC(10, 2) DEFAULT 0.00 NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),    
    CONSTRAINT pk_reservas_alquileres PRIMARY KEY (id_reserva),
    CONSTRAINT fk_reserva_cancha FOREIGN KEY (id_cancha) REFERENCES Canchas (id_cancha),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes (id_cliente),
    CONSTRAINT fk_reserva_empleado FOREIGN KEY (id_empleado_receptor) REFERENCES Empleados (id_empleado),
    CONSTRAINT chk_horas_rango CHECK (hora_inicio < hora_fin),
    CONSTRAINT chk_tipo_horario CHECK (tipo_horario IN ('Diurno', 'Nocturno')),
    CONSTRAINT chk_estado_pago CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Cancelado')),
    CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('Efectivo', 'Transferencia') OR metodo_pago IS NULL),
    CONSTRAINT chk_monto_ingreso CHECK (monto_ingreso >= 0)
);

-- TABLA: CostosOperativos (Registra los egresos asignados a una infraestructura real)
CREATE TABLE CostosOperativos (
    id_egreso INT IDENTITY(1,1),
    id_cancha INT NOT NULL,             
    tipo_costo VARCHAR(50) NOT NULL,             
    monto_gasto NUMERIC(10, 2) NOT NULL,
    fecha_gasto DATE DEFAULT GETDATE() NOT NULL,
    id_empleado_contador INT NOT NULL,
    CONSTRAINT pk_costos_operativos PRIMARY KEY (id_egreso),
    CONSTRAINT fk_costos_cancha FOREIGN KEY (id_cancha) REFERENCES Canchas (id_cancha),
    CONSTRAINT fk_costos_contador FOREIGN KEY (id_empleado_contador) REFERENCES Empleados (id_empleado),
    CONSTRAINT chk_tipo_costo CHECK (tipo_costo IN ('Luz', 'Agua', 'Mantenimiento_Cesped', 'Insumos_Limpieza')),
    CONSTRAINT chk_monto_gasto CHECK (monto_gasto > 0)
);

-- Creación de un índice de rendimiento para acelerar los reportes por fechas y canchas
CREATE INDEX idx_reserva_fecha_cancha ON ReservasAlquileres (fecha_reserva, id_cancha);
GO


-- ===========================================================================
-- 2. POBLADO DE DATOS DE PRUEBA (CONSISTENCIA DE CLAVES FORÁNEAS)
-- ===========================================================================

-- Insertar las 3 sedes de SportRíos S.A.
INSERT INTO Sedes (nombre_sede, direccion_sede) VALUES
('Ventanas Central', 'Av. Seminario y Calle Limón'), -- ID: 1
('Quevedo Norte', 'Sector San Camilo'),             -- ID: 2
('Babahoyo Sur', 'Av. Universitaria');               -- ID: 3

-- Insertar las 10 canchas especificando a qué sede pertenecen (Lógica de tu Ingeniero)
INSERT INTO Canchas (id_sede, nombre_cancha, tipo_disciplina, tipo_superficie, tarifa_hora_dia, tarifa_hora_noche) VALUES
(1, 'Cancha Alfa F7', 'Fútbol 7', 'Césped Sintético', 20.00, 30.00), -- ID: 1 (En Ventanas)
(1, 'Cancha Beta F5', 'Fútbol 5', 'Césped Sintético', 15.00, 25.00), -- ID: 2 (En Ventanas)
(1, 'Pádel Cristal 1', 'Pádel', 'Cristal/Vidrio', 12.00, 18.00),     -- ID: 3 (En Ventanas)
(1, 'Ecuavoley Arena', 'Ecuavoley', 'Arena', 10.00, 15.00),          -- ID: 4 (En Ventanas)
(2, 'Estadio F7 Pro', 'Fútbol 7', 'Césped Sintético', 22.00, 32.00),  -- ID: 5 (En Quevedo)
(2, 'La Bombonera F5', 'Fútbol 5', 'Césped Sintético', 17.00, 27.00), -- ID: 6 (En Quevedo)
(2, 'Pádel Pro 1', 'Pádel', 'Cristal/Vidrio', 14.00, 20.00),          -- ID: 7 (En Quevedo)
(3, 'Fluminense F7', 'Fútbol 7', 'Césped Sintético', 25.00, 35.00),  -- ID: 8 (En Babahoyo)
(3, 'Los Ríos F5', 'Fútbol 5', 'Césped Sintético', 18.00, 28.00),     -- ID: 9 (En Babahoyo)
(3, 'Pádel Cristal B1', 'Pádel', 'Cristal/Vidrio', 15.00, 22.00);    -- ID: 10(En Babahoyo)

-- Insertar Clientes independientes
INSERT INTO Clientes (cedula, nombre, apellido, telefono, email) VALUES
('1200000011', 'Manuel', 'Zambrano', '0990000011', 'manuel.z@gmail.com'),    -- ID: 1
('1200000012', 'Roberto', 'Cedeño', '0990000012', 'roberto.c@gmail.com'),    -- ID: 2
('1200000013', 'Fabián', 'Moreira', '0990000013', 'fabian.m@gmail.com'),     -- ID: 3
('1200000014', 'Gabriel', 'Bustamante', '0990000014', 'gabriel.b@gmail.com'), -- ID: 4
('1200000015', 'Christian', 'Vera', '0990000015', 'christian.v@gmail.com'),  -- ID: 5
('1200000016', 'Santiago', 'Montalvo', '0990000016', 'santiago.m@gmail.com');-- ID: 6

-- Insertar Empleados independientes con sus roles
INSERT INTO Empleados (cedula, nombre, apellido, telefono, email, rol_sistema) VALUES
('1201234567', 'Carlos', 'Mendoza', '0981111111', 'carlos.adm@sportrios.com', 'Administrador'), -- ID: 1
('1207654321', 'Juan', 'Pérez', '0982222222', 'juan.rec@sportrios.com', 'Recepcionista'),     -- ID: 2
('1203456789', 'Ana', 'Ríos', '0984444444', 'ana.cont@sportrios.com', 'Contador'),            -- ID: 3
('1207778889', 'Lucía', 'Benítez', '0985556667', 'lucia.rec@sportrios.com', 'Recepcionista');  -- ID: 4

-- Insertar las 10 Reservas apuntando correctamente a las nuevas tablas separadas
INSERT INTO ReservasAlquileres (id_cancha, id_cliente, id_empleado_receptor, fecha_reserva, hora_inicio, hora_fin, tipo_horario, estado_pago, metodo_pago, monto_ingreso) VALUES
(1, 1, 2, '2026-05-01', '14:00:00', '15:00:00', 'Diurno', 'Pagado', 'Efectivo', 20.00),
(1, 2, 2, '2026-05-01', '19:00:00', '20:00:00', 'Nocturno', 'Pagado', 'Transferencia', 30.00),
(2, 3, 2, '2026-05-02', '10:00:00', '11:00:00', 'Diurno', 'Pagado', 'Efectivo', 15.00),
(3, 4, 4, '2026-05-03', '16:00:00', '17:00:00', 'Diurno', 'Pagado', 'Efectivo', 12.00),
(5, 5, 2, '2026-05-05', '19:00:00', '20:00:00', 'Nocturno', 'Pagado', 'Transferencia', 32.00),
(6, 6, 4, '2026-05-06', '08:00:00', '09:00:00', 'Diurno', 'Pagado', 'Efectivo', 17.00),
(7, 1, 2, '2026-05-07', '21:00:00', '22:00:00', 'Nocturno', 'Cancelado', NULL, 0.00),
(8, 2, 4, '2026-05-10', '19:00:00', '20:00:00', 'Nocturno', 'Pagado', 'Transferencia', 35.00),
(9, 3, 2, '2026-05-12', '15:00:00', '16:00:00', 'Diurno', 'Pendiente', NULL, 18.00),
(10, 4, 2, '2026-05-15', '20:00:00', '21:00:00', 'Nocturno', 'Pagado', 'Transferencia', 22.00);

-- Insertar Costos Operativos amarrando los gastos a canchas físicas y auditados por el Contador (Empleado 3)
INSERT INTO CostosOperativos (id_cancha, tipo_costo, monto_gasto, fecha_gasto, id_empleado_contador) VALUES
(1, 'Mantenimiento_Cesped', 120.00, '2026-05-02', 3),
(1, 'Insumos_Limpieza', 45.00, '2026-05-05', 3),
(5, 'Mantenimiento_Cesped', 150.00, '2026-05-03', 3),
(5, 'Insumos_Limpieza', 60.00, '2026-05-06', 3),
(8, 'Mantenimiento_Cesped', 160.00, '2026-05-04', 3),
(8, 'Insumos_Limpieza', 85.00, '2026-05-07', 3),
(2, 'Luz', 180.50, '2026-05-28', 3),
(2, 'Agua', 45.20, '2026-05-28', 3),
(6, 'Luz', 210.00, '2026-05-28', 3),
(9, 'Luz', 240.80, '2026-05-28', 3);
GO
