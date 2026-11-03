import sys
import mariadb

from conexion import CONFIG  # mismos valores que conexion.py (variables de entorno y .env)

try:
    # Establecer la conexión con la base de datos (la contraseña vacía es válida)
    conexion = mariadb.connect(
        user=CONFIG["user"],
        password=CONFIG["password"] or "",
        host=CONFIG["host"],
        port=CONFIG["port"],
        database=CONFIG["database"]
    )
except mariadb.Error as e:
    print(f"Error al conectar a MariaDB: {e}")
    sys.exit(1)

# Crear un cursor para ejecutar sentencias SQL
cursor = conexion.cursor()

# Ejecutar una consulta de ejemplo
cursor.execute("SELECT * FROM nacionalidad")

# Recorrer los resultados
for (Nacionalidad_ID, Nombre) in cursor:
    print(f"ID: {Nacionalidad_ID}, Nombre: {Nombre}")

# Cerrar cursor y conexión
cursor.close()
conexion.close()
