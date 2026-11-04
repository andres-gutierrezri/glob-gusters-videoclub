"""Ejemplo mínimo de conexión con el conector oficial `mariadb`.

Lista el contenido de la tabla `nacionalidad`. A diferencia del resto de scripts de py/
(que usan PyMySQL a través de conexion.py), este usa el paquete `mariadb`, que es
opcional: está comentado en requirements.txt porque necesita MariaDB Connector/C >= 3.3.1.

Configuración: no tiene valores escritos en el código. Usuario, contraseña, host, puerto y
base de datos salen de las variables de entorno GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT,
GLOB_GUSTERS_USER, GLOB_GUSTERS_PASSWORD y GLOB_GUSTERS_DB, que conexion.py lee del
archivo `.env` de la raíz (una variable ya definida en el sistema tiene prioridad).

Uso:
    python py/conexion_mariabd.py
"""

# `sys` permite terminar el programa con un código de error (sys.exit).
import sys
# Conector oficial de MariaDB (dependencia opcional, ver requirements.txt).
import mariadb

# Reutiliza los mismos parámetros de conexion.py (variables de entorno y archivo .env).
from conexion import CONFIG  # mismos valores que conexion.py (variables de entorno y .env)

try:
    # Establecer la conexión con la base de datos (la contraseña vacía es válida)
    conexion = mariadb.connect(
        # Usuario tomado de la configuración compartida.
        user=CONFIG["user"],
        # Contraseña; `or ""` convierte None en cadena vacía (sin contraseña).
        password=CONFIG["password"] or "",
        # Servidor de MariaDB. Con "localhost" el conector oficial usa el socket Unix local
        # (que puede pertenecer a otro servidor MySQL/MariaDB e ignora el puerto); por eso se
        # fuerza TCP con 127.0.0.1, igual que hace PyMySQL.
        host="127.0.0.1" if CONFIG["host"] == "localhost" else CONFIG["host"],
        # Puerto TCP.
        port=CONFIG["port"],
        # Base de datos a usar.
        database=CONFIG["database"]
    )
except mariadb.Error as e:
    # Si la conexión falla, se muestra el motivo y se sale con código 1 (error).
    print(f"Error al conectar a MariaDB: {e}")
    sys.exit(1)

# Crear un cursor para ejecutar sentencias SQL
cursor = conexion.cursor()

# Ejecutar una consulta de ejemplo
cursor.execute("SELECT * FROM nacionalidad")

# Recorrer los resultados
# Cada fila es una tupla (id, nombre) que se desempaqueta en dos variables.
for (Nacionalidad_ID, Nombre) in cursor:
    print(f"ID: {Nacionalidad_ID}, Nombre: {Nombre}")

# Cerrar cursor y conexión
cursor.close()
conexion.close()
