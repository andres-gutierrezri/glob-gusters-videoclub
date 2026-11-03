import sys
import mariadb

try:
    # Establecer la conexión con la base de datos
    conexion = mariadb.connect(
        user="root",
        password="",
        host="127.0.0.1",
        port=3306,
        database="glob_gusters"
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