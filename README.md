# Base de Datos para Gestión de Hotel (PostgreSQL)

Proyecto universitario desarrollado en equipo para simular la operación de un hotel utilizando **PostgreSQL** y **DBeaver**. El objetivo fue estructurar la información de habitaciones y huéspedes, además de practicar la asignación de permisos a distintos tipos de usuarios.

## ¿Qué incluye el proyecto?

- **Tablas principales:** Diseñamos tablas para `Habitaciones`, `Reservas`, `Huespedes` y una tabla intermedia `Incluir` para relacionar reservas con una o más habitaciones.
- **Permisos y roles de usuario:** Creamos diferentes perfiles para que no todos tengan acceso completo a la base de datos:
  - Roles de solo lectura (para becarios o consultas de auditoría).
  - Roles operativos para el personal de recepción (`lobby` y `reserv_area`) con permisos para registrar y modificar datos.
  - Roles con permisos completos de administración (`jefe_admin`) y desarrollo.
- **Vistas:** Creamos vistas simples para consultar rápido datos de contacto y tipos de habitación, además de vistas materializadas para reportes frecuentes.
- **Prueba de transacciones (Rollback):** Agregamos una prueba intencional usando `BEGIN` y `ROLLBACK` para comprobar que la base rechaza registros duplicados sin guardar información corrupta.

## Archivos
- `hotel_schema_rbac.sql`: Script con la creación de tablas, inserciones de prueba, vistas, manejo de transacciones y asignación de roles.
