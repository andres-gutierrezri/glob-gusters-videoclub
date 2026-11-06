"""DCL (Data Control Language) — equivalente a sql/mariadb/commands/05_DCL.sql.

CREATE USER / GRANT / REVOKE / FLUSH PRIVILEGES / SHOW GRANTS. Requiere una cuenta
administrativa (por defecto root de XAMPP). Es repetible: CREATE USER usa IF NOT EXISTS.

Las contraseñas de las cuentas de ejemplo se pueden cambiar con las variables de
entorno GLOB_GUSTERS_PASS_REPORTES y GLOB_GUSTERS_PASS_MOSTRADOR; los valores por
defecto son los mismos del .sql.

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual activo y desde la raíz del proyecto:
    python py/dcl.py          (en Windows se escribe igual)
"""

# Módulo estándar para leer variables de entorno.
import os

# Funciones comunes de conexion.py (al importarlo también se carga el archivo .env).
from conexion import conexion, consultar, ejecutar, principal

# Base de datos sobre la que se conceden los permisos.
BD = "glob_gusters"
# Cuentas de ejemplo: nombre -> (contraseña, privilegios que se conceden).
USUARIOS = {
    # Cuenta de solo lectura para reportes.
    "glob_gusters_reportes": (os.getenv("GLOB_GUSTERS_PASS_REPORTES", "Reportes#2024"), "SELECT"),
    # Cuenta de mostrador: puede consultar, insertar y actualizar (el DELETE se revoca abajo).
    "glob_gusters_mostrador": (os.getenv("GLOB_GUSTERS_PASS_MOSTRADOR", "Mostrador#2024"), "SELECT, INSERT, UPDATE"),
}

def main():
    # Requiere privilegios administrativos (root) para crear usuarios y conceder permisos.
    with conexion() as con:
        for usuario, (clave, privilegios) in USUARIOS.items():
            # Cuenta completa en formato MariaDB: 'usuario'@'host'.
            cuenta = f"'{usuario}'@'localhost'"
            # La contraseña va como parámetro; el resto son nombres fijos definidos arriba.
            ejecutar(con, f"CREATE USER IF NOT EXISTS {cuenta} IDENTIFIED BY %s", (clave,))
            # Concede los privilegios sobre todas las tablas de la base del proyecto.
            ejecutar(con, f"GRANT {privilegios} ON `{BD}`.* TO {cuenta}")
            print(f"Usuario {cuenta}: GRANT {privilegios}")

        # El personal de mostrador no puede borrar historial de rentas.
        ejecutar(con, f"REVOKE DELETE ON `{BD}`.* FROM 'glob_gusters_mostrador'@'localhost'")
        # Recarga las tablas de permisos para que los cambios apliquen de inmediato.
        ejecutar(con, "FLUSH PRIVILEGES")

        # Muestra los permisos finales de cada cuenta de ejemplo.
        for usuario in USUARIOS:
            print(f"\n== Privilegios de {usuario} ==")
            for fila in consultar(con, f"SHOW GRANTS FOR '{usuario}'@'localhost'"):
                # Cada fila tiene una sola columna (con nombre variable): se toma su único valor.
                print(next(iter(fila.values())))


# Ejecuta main() solo al lanzar el archivo directamente.
if __name__ == "__main__":
    principal(main)
