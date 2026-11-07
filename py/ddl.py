"""DDL (Data Definition Language) — equivalente a sql/mariadb/commands/01_DDL.sql.

CREATE / ALTER / CREATE INDEX / DROP. Idempotente: todo usa IF [NOT] EXISTS.
Requiere haber ejecutado antes sql/mariadb/glob_gusters.sql.

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual instalado y ACTIVADO y desde la raíz del proyecto:
    python3 py/ddl.py          (macOS y Linux; en Windows: python py/ddl.py)
"""

# Funciones comunes de conexion.py: context manager de conexión, SELECT, escritura e impresión.
from conexion import conexion, consultar, ejecutar, imprimir, principal

# Lista ordenada de sentencias DDL; se ejecutan una tras otra.
SENTENCIAS = [
    # CREATE: tabla de prueba para demostrar CREATE TABLE.
    # IF NOT EXISTS evita el error si la tabla ya existe (re-ejecución segura).
    """CREATE TABLE IF NOT EXISTS `tabla_prueba` (
        `Tabla_Prueba_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
        `Descripcion` VARCHAR(100) NOT NULL,
        PRIMARY KEY (`Tabla_Prueba_ID`)
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
      COMMENT = 'Tabla temporal usada únicamente para demostrar sentencias DDL.'""",
    # ALTER: correo del socio.
    # ADD COLUMN IF NOT EXISTS agrega la columna solo si todavía no existe.
    """ALTER TABLE `cliente`
        ADD COLUMN IF NOT EXISTS `Email` VARCHAR(120) NULL
        COMMENT 'Correo electrónico de contacto del socio (opcional).'""",
    # ALTER: duración de la película.
    """ALTER TABLE `pelicula`
        ADD COLUMN IF NOT EXISTS `Duracion_Minutos` SMALLINT UNSIGNED NULL
        COMMENT 'Duración de la película en minutos.'""",
    # ALTER: amplía el teléfono para indicativos internacionales.
    # MODIFY COLUMN cambia el tipo de una columna existente (de VARCHAR(20) a VARCHAR(25)).
    """ALTER TABLE `cliente`
        MODIFY COLUMN `Telefono` VARCHAR(25) NOT NULL
        COMMENT 'Teléfono de contacto del socio, incluye indicativo internacional.'""",
    # CREATE INDEX: búsquedas por título.
    "CREATE INDEX IF NOT EXISTS `idx_pelicula_titulo` ON `pelicula` (`Titulo`)",
    # DROP: elimina la tabla de prueba.
    "DROP TABLE IF EXISTS `tabla_prueba`",
]


def main():
    # Abre la conexión y la cierra automáticamente al terminar el bloque.
    with conexion() as con:
        # Ejecuta cada sentencia DDL en el orden de la lista.
        for sql in SENTENCIAS:
            ejecutar(con, sql)
            # Muestra un resumen: espacios múltiples colapsados y máximo 90 caracteres.
            print("OK:", " ".join(sql.split())[:90])
        # Confirma los cambios (en MariaDB el DDL ya confirma implícitamente).
        con.commit()

        # Verifica el resultado consultando el diccionario del servidor (information_schema).
        imprimir(
            "Columnas agregadas",
            consultar(
                con,
                # DATABASE() = base actual; el filtro IN compara pares (tabla, columna).
                """SELECT table_name AS tabla, column_name AS columna, column_type AS tipo
                   FROM information_schema.columns
                   WHERE table_schema = DATABASE()
                     AND (table_name, column_name) IN
                         (('cliente', 'Email'), ('cliente', 'Telefono'), ('pelicula', 'Duracion_Minutos'))
                   ORDER BY table_name, column_name""",
            ),
        )


# Ejecuta main() solo cuando el archivo se lanza directamente (python3 py/ddl.py).
if __name__ == "__main__":
    principal(main)
