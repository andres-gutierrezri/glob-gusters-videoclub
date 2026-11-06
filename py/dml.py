"""DML (Data Manipulation Language) — equivalente a sql/mariadb/commands/02_DML.sql.

INSERT (nuevo socio), UPDATE (estado de un ejemplar y duración de una película) y
DELETE (una fila de reparto). Todo se localiza por llave natural y es repetible.
Requiere glob_gusters_insert.sql y ddl.py (columnas Email y Duracion_Minutos).
Las sentencias llevan parámetros (%s), nunca valores concatenados en el SQL.

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual activo y desde la raíz del proyecto:
    python py/dml.py          (en Windows se escribe igual)
"""

# Funciones comunes de conexion.py.
from conexion import conexion, consultar, ejecutar, imprimir, principal


def main():
    # Abre la conexión y la cierra automáticamente al salir.
    with conexion() as con:
        # INSERT: socio nuevo avalado por Laura Gómez (se busca por DNI). IGNORE evita el
        # duplicado en reejecuciones (Dni es UNIQUE). El aval va en tabla derivada porque
        # MariaDB no deja leer `cliente` directo dentro de un INSERT sobre `cliente`.
        n = ejecutar(
            con,
            """INSERT IGNORE INTO `cliente`
                   (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`, `Email`)
               VALUES (%s, %s, %s, %s,
                       (SELECT `Cliente_ID` FROM
                           (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = %s) AS `aval`),
                       %s)""",
            # Valores en el orden de los %s: dni, nombre, dirección, teléfono,
            # DNI del aval (para buscar su ID) y correo electrónico.
            ("1000000005", "Sofía Ramírez", "Calle 50 # 20-30", "3011122334",
             "1000000001", "sofia.ramirez@example.com"),
        )
        # `n` es el número de filas insertadas (0 si el socio ya existía).
        print(f"INSERT cliente: {n} fila(s)")

        # UPDATE: Quo Vadis (1951), ejemplar 2, queda como 'Dañado'.
        # El JOIN localiza el ejemplar por título, año y número; la subconsulta obtiene el ID del estado.
        n = ejecutar(
            con,
            """UPDATE `ejemplar` e
               INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
               SET e.`Estado_ID` = (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = %s)
               WHERE p.`Titulo` = %s AND p.`Anio` = %s AND e.`Numero` = %s""",
            ("Dañado", "Quo Vadis", 1951, 2),
        )
        print(f"UPDATE ejemplar: {n} fila(s)")

        # UPDATE: duración de Interstellar.
        n = ejecutar(
            con,
            "UPDATE `pelicula` SET `Duracion_Minutos` = %s WHERE `Titulo` = %s AND `Anio` = %s",
            (169, "Interstellar", 2014),
        )
        print(f"UPDATE pelicula: {n} fila(s)")

        # DELETE: quita a Anne Hathaway del reparto de Interstellar.
        # `DELETE r FROM ... JOIN ...` borra solo filas de `reparto` (alias r).
        n = ejecutar(
            con,
            """DELETE r FROM `reparto` r
               INNER JOIN `pelicula` p ON p.`Pelicula_ID` = r.`Pelicula_ID`
               INNER JOIN `actor` a ON a.`Actor_ID` = r.`Actor_ID`
               WHERE p.`Titulo` = %s AND p.`Anio` = %s AND a.`Nombre` = %s""",
            ("Interstellar", 2014, "Anne Hathaway"),
        )
        print(f"DELETE reparto: {n} fila(s)")

        # Confirma de forma definitiva las cuatro operaciones anteriores.
        con.commit()

        # Muestra el socio recién insertado para comprobar el resultado.
        imprimir("Cliente nuevo", consultar(
            con, "SELECT `Cliente_ID`, `Nombre`, `Email` FROM `cliente` WHERE `Dni` = %s", ("1000000005",)))


# Ejecuta main() solo al lanzar el archivo directamente.
if __name__ == "__main__":
    principal(main)
