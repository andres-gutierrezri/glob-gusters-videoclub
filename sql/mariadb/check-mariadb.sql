-- MariaDB Health Check Script

-- Verificar la versión de MariaDB
SELECT VERSION();

-- Verificar el puerto en el que está escuchando MariaDB
SHOW VARIABLES LIKE 'port';

-- Verificar puertos abiertos y conexiones activas
SHOW PROCESSLIST;

-- Verificar la versión de MariaDB y el estado del servidor
SELECT VERSION(), @@version_comment, @@version_compile_machine, @@version_compile_os;

-- Verificar la versión del servidor
SELECT @@version;

-- Verificar la versión del compilador
SELECT @@version_compile_machine, @@version_compile_os;

-- Verificar la versión del sistema operativo
SELECT @@version_compile_os;

-- Verificar el estado de la base de datos
SELECT DATABASE();

-- Verificar el estado del servidor
SHOW STATUS;

-- Verificar la configuración del servidor
SHOW VARIABLES;

-- Verificar procedimientos almacenados
SHOW PROCEDURE STATUS;

-- Verificar triggers
SHOW TRIGGERS;

-- Verificar vistas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Verificar eventos
SHOW EVENTS;

-- Verificar tablas
SHOW TABLES;

-- Verificar funciones
SHOW FUNCTION STATUS;

-- Consultar información de esquema
SELECT * FROM information_schema.routines LIMIT 10;

-- Consulta para ver una lista básica de usuarios y sus hosts
SELECT user, host FROM mysql.user;

-- Detalles sobre todos los usuarios
SELECT * FROM mysql.user;

-- Ver el estado de bloqueo de la cuenta o si la contraseña ha expirado
SELECT user, account_locked, password_expired FROM mysql.user;