CREATE TABLE Habitaciones (
    id_habitacion SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL,
    precio_por_noche DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL
);


-- TABLA: Reservas
CREATE TABLE Reservas (
    id_reserva SERIAL PRIMARY KEY,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);


-- TABLA: Huespedes
CREATE TABLE Huespedes (
    id_huesped SERIAL PRIMARY KEY,
    id_habitacion INT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    nacionalidad VARCHAR(50),
    telefono VARCHAR(20),
    CONSTRAINT fk_habitacion_huesped
        FOREIGN KEY (id_habitacion)
        REFERENCES Habitaciones (id_habitacion)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);


-- TABLA: Incluir (tabla intermedia entre Reservas y Habitaciones)
CREATE TABLE Incluir (
    id_reserva INT,
    id_habitacion INT,
    PRIMARY KEY (id_reserva, id_habitacion),
    CONSTRAINT fk_incluir_reserva
        FOREIGN KEY (id_reserva)
        REFERENCES Reservas (id_reserva)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_incluir_habitacion
        FOREIGN KEY (id_habitacion)
        REFERENCES Habitaciones (id_habitacion)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- =========================================
-- Insertar Habitaciones
-- =========================================
INSERT INTO Habitaciones (tipo, capacidad, precio_por_noche, estado)
VALUES 
('Sencilla', 1, 800.00, 'Disponible'),
('Doble', 2, 1200.00, 'Ocupada'),
('Suite', 4, 2500.00, 'Mantenimiento'),
('Familiar', 5, 1800.00, 'Disponible');

--  Insertar Reservas
INSERT INTO Reservas (estado, fecha_inicio, fecha_fin)
VALUES
('Confirmada', '2025-10-20', '2025-10-25'),
('Pendiente',  '2025-11-01', '2025-11-03'),
('Cancelada',  '2025-12-15', '2025-12-20');

--  Insertar Huéspedes
-- (Se asocian con habitaciones existentes)
INSERT INTO Huespedes (id_habitacion, nombre, apellido, correo, nacionalidad, telefono)
VALUES
(1, 'Carlos', 'Ramírez', 'carlos.ramirez@email.com', 'Mexicana', '5541239876'),
(2, 'Ana', 'González', 'ana.gonzalez@email.com', 'Argentina', '1123456789'),
(2, 'Luis', 'Martínez', 'luis.martinez@email.com', 'Peruana', '9988776655'),
(4, 'María', 'López', 'maria.lopez@email.com', 'Colombiana', '3216549870');

-- =========================================
--  Insertar en tabla intermedia Incluir
-- (Relaciona Reservas con Habitaciones)
-- =========================================
INSERT INTO Incluir (id_reserva, id_habitacion)
VALUES
(1, 1),  -- Reserva 1 incluye Habitación 1
(1, 2),  -- Reserva 1 incluye Habitación 2
(2, 4);  -- Reserva 2 incluye Habitación 4

select * from Habitaciones;
select * from Reservas;
select * from Huespedes;

-- PUNTO 2 y 3: VISTAS Y VISTAS MATERIALIZADAS
-- Sistema Hotel - Base de datos en PostgreSQL 


--Vista para ver el tipo de habitacion junto con su precio
create view tipo_precio_hab as select tipo, precio_por_noche from habitaciones;

select * from tipo_precio_hab;
--Vista para ver las formas de contactar a un huesped, junto con su apellido
create view contacto_clientes as select apellido, correo, telefono from huespedes;

select * from contacto_clientes;

--Vista materializada para ver el estado de una reserva junto con el nombre y apellido del huesped
create materialized view reserva_huesped as select estado, nombre, apellido 
from reservas join huespedes on reservas.id_reserva = huespedes.id_habitacion;

select * from reserva_huesped;

--Vista materializada para ver el precio por noche de cada reserva junto con su fecha programada
create materialized view precio_fecha as select precio_por_noche, fecha_inicio, fecha_fin 
from habitaciones join reservas on habitaciones.id_habitacion = reservas.id_reserva;

select * from precio_fecha;

-- =====================================================
-- PUNTO 4: DEMOSTRACIÓN DE TRANSACCIÓN CON ERROR
-- Sistema Hotel - Base de datos en PostgreSQL (DBeaver)
-- =====================================================

-- 1. Iniciar una transacción explícita
BEGIN;

-- 2. Mostrar el estado actual de algunas tablas (opcional, para demo)
SELECT 'Reservas antes:' AS info;
SELECT * FROM Reservas ORDER BY id_reserva;

SELECT 'Incluir antes:' AS info;
SELECT * FROM Incluir ORDER BY id_reserva, id_habitacion;

-- 3. Operaciones que SÍ se van a ejecutar correctamente
--    Vamos a agregar una nueva reserva
INSERT INTO Reservas (estado, fecha_inicio, fecha_fin)
VALUES ('Confirmada', '2025-11-15', '2025-11-18')
RETURNING id_reserva;  -- Esto nos devuelve el ID generado

-- 4. Relacionar esa reserva con una habitación disponible (id_habitacion = 4 está disponible)
INSERT INTO Incluir (id_reserva, id_habitacion)
VALUES (4, 4);

-- 5. Aquí provocamos un ERROR INTENCIONAL
--    Intentamos insertar la MISMA combinación de reserva y habitación
--    ¡Esto viola la PRIMARY KEY (id_reserva, id_habitacion)!
INSERT INTO Incluir (id_reserva, id_habitacion)
VALUES (4, 4);

ROLLBACK;

-- RESULTADO DESPUÉS DEL ROLLBACK
SELECT '=== DESPUÉS DEL ROLLBACK ===' AS resultado;

SELECT 'Reservas después del rollback:' AS info;
SELECT * FROM Reservas ORDER BY id_reserva;

SELECT 'Incluir después del rollback:' AS info;
SELECT * FROM Incluir ORDER BY id_reserva, id_habitacion;


--Creación de roles
--Rol de solo lectura
--Primer rol
create role Lecture_Becario1 LOGIN password '1234';

grant connect on database clase08 to Lecture_Becario1;

grant usage on schema hotel to Lecture_becario1;

grant select on all tables in schema hotel to Lecture_becario1;

alter default privileges in schema hotel grant select on tables to Lecture_becario1;

select rolname from pg_roles;

show hba_file;

SELECT rolname, rolcanlogin FROM pg_roles WHERE rolname = 'lecture_becario1';

--Segundo Rol de lectura
create role lecture_visit1 LOGIN password '1234';

grant connect on database clase08 to lecture_visit1;

grant usage on schema hotel to Lecture_visit;

grant select on all tables in schema hotel to lecture_visit;

alter default privileges in schema hotel grant select on tables to lecture_visit;

--Tercel rol de lectura
create role lecture_boss LOGIN password '1234';

grant connect on database clase08 to lecture_boss;

grant usage on schema hotel to lecture_boss;

grant select on all tables in schema hotel to lecture_boss;

alter default privileges in schema hotel grant select on tables to lecture_boss;

--Roles de escritura y lectura
--1er rol lobby
create role lobby LOGIN password 'Looby';

grant connect on database clase08 to lobby;

grant usage on schema hotel to lobby;

grant insert, update on all tables in schema hotel to lobby;

alter default privileges in schema hotel grant insert, update on tables to lobby;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT INSERT, UPDATE ON TABLES TO lobby;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA hotel TO lobby;

GRANT USAGE, SELECT, UPDATE ON SEQUENCE habitaciones_id_habitacion_seq TO lobby;

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA hotel TO lobby;

alter default privileges in schema hotel grant usage, select, update on sequences to lobby;

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA hotel TO lobby;


GRANT INSERT, UPDATE, SELECT ON ALL TABLES IN schema hotel TO lobby;

--2do rol Area recerva

create role reserv_area LOGIN password 'Reser';

grant usage on schema hotel to reserv_area;

grant insert, update on all tables in schema hotel to reserv_area;

alter default privileges in schema hotel grant insert, update on tables to reserv_area;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT INSERT, UPDATE ON TABLES TO reserv_area;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA hotel TO lobby;

GRANT INSERT, UPDATE, SELECT ON ALL TABLES IN schema hotel TO reserv_area;}

--3er rol admin de la base de datos

create role jefe_admin LOGIN password 'GODADMIN';

grant CONNEcT on database clase08 to jefe_admin;

grant create on database clase08 to jefe_admin;

grant all on schema hotel to jefe_admin;

grant all privileges on all tables in schema hotel to jefe_admin;

alter default privileges in schema hotel grant all on tables to jefe_admin;

alter role jefe_admin CREATEROLE CREATEDB;

--4to rol de programadores

create role progra with password '1234';

grant connect on database clase08 to progra;

grant usage on schema hotel to progra;

grant create on schema hotel to progra;

grant select, insert, update on all tables in schema hotel to progra;

alter default privileges in schema hotel
grant select, insert, update on tables to progra;

alter role progra LOGIN;

alter table hotel.habitaciones owner to progra;
alter table hotel.huespedes owner to progra;
alter table hotel.incluir owner to progra;
alter table hotel.reservas owner to progra;

--5 rol de programador
Alter role programador_2 with password '1234';

grant connect on database clase08 to programador_2;

grant usage on schema hotel to programador_2;

grant create on schema public to programador_2;

grant select, insert, update on all tables in schema hotel to programador_2;

alter default privileges in schema hotel
grant select, insert, update on tables to programador_2;

SELECT * FROM Habitaciones;
SELECT * FROM precio_fecha;