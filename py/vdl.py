"""VDL (View Definition Language) — equivalente a sql/mariadb/commands/04_VDL.sql.

CREATE OR REPLACE VIEW de las dos vistas del proyecto y consulta de cada una.
El DROP VIEW queda detrás de la opción --drop, igual que está comentado en el .sql:
    python py/vdl.py --drop

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual activo y desde la raíz del proyecto:
    python py/vdl.py          (en Windows se escribe igual)
"""

# `sys` da acceso a los argumentos de la línea de comandos.
import sys

# Funciones comunes de conexion.py.
from conexion import conexion, consultar, ejecutar, imprimir

# Cada vista: nombre -> (sentencia que la crea, consulta que la verifica).
VISTAS = {
    # Ejemplares con título, año y estado de conservación (une tres tablas).
    "v_ejemplares_detalle": (
        """CREATE OR REPLACE VIEW `v_ejemplares_detalle` AS
           SELECT e.`Ejemplar_ID`, e.`Numero` AS Numero_Ejemplar, p.`Titulo` AS Pelicula,
                  p.`Anio`, es.`Nombre` AS Estado_Conservacion
           FROM `ejemplar` e
           INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
           INNER JOIN `estado` es  ON es.`Estado_ID` = e.`Estado_ID`""",
        "SELECT * FROM `v_ejemplares_detalle` ORDER BY `Pelicula`, `Numero_Ejemplar`",
    ),
    # Socios con el nombre de quien los avala; LEFT JOIN conserva a los que no tienen aval.
    "v_clientes_con_aval": (
        """CREATE OR REPLACE VIEW `v_clientes_con_aval` AS
           SELECT c.`Cliente_ID`, c.`Nombre` AS Cliente, c.`Dni`, aval.`Nombre` AS Avalado_Por
           FROM `cliente` c
           LEFT JOIN `cliente` aval ON aval.`Cliente_ID` = c.`Aval_Cliente_ID`""",
        "SELECT * FROM `v_clientes_con_aval` ORDER BY `Cliente`",
    ),
}


def main(argv):
    # Abre la conexión y la cierra al salir del bloque.
    with conexion() as con:
        # Con la opción --drop solo se eliminan las vistas y se termina.
        if "--drop" in argv:
            for nombre in VISTAS:
                # Los nombres vienen de la constante VISTAS (no de datos externos).
                ejecutar(con, f"DROP VIEW IF EXISTS `{nombre}`")
                print(f"Vista eliminada: {nombre}")
            con.commit()
            return
        # Modo normal: crea (o reemplaza) cada vista y muestra su contenido.
        for nombre, (crear, consulta) in VISTAS.items():
            ejecutar(con, crear)
            imprimir(nombre, consultar(con, consulta))
        con.commit()


# Al lanzar el archivo, pasa a main() los argumentos (sin el nombre del script).
if __name__ == "__main__":
    main(sys.argv[1:])
