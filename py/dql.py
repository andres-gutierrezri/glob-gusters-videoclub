"""DQL (Data Query Language) — equivalente a sql/mariadb/commands/03_DQL.sql.

Consultas de solo lectura: SELECT con condición, JOIN y GROUP BY.
Sin argumentos ejecuta todas; con un nombre ejecuta una sola:
    python py/dql.py disponibles

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual activo y desde la raíz del proyecto:
    python py/dql.py          (en Windows se escribe igual)
"""

# `sys` da acceso a los argumentos de la línea de comandos (sys.argv) y a sys.exit.
import sys

# Funciones comunes de conexion.py (aquí no se necesita `ejecutar`: solo se lee).
from conexion import conexion, consultar, imprimir, principal

# Catálogo de consultas: nombre corto -> (título para mostrar, sentencia SQL).
CONSULTAS = {
    # SELECT con condición: ejemplares sin una devolución pendiente (Entrega NULL).
    "disponibles": (
        "Ejemplares disponibles para alquilar",
        """SELECT e.`Ejemplar_ID`, e.`Numero`, p.`Titulo`
           FROM `ejemplar` e
           INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
           WHERE e.`Ejemplar_ID` NOT IN (
               SELECT er.`Ejemplar_ID` FROM `ejemplar_renta` er WHERE er.`Entrega` IS NULL
           )""",
    ),
    # JOIN de cinco tablas: rentas que aún no tienen fecha de devolución.
    "rentas_activas": (
        "Rentas activas (sin fecha de devolución)",
        """SELECT c.`Nombre` AS Cliente, r.`Renta_ID`, r.`Inicia`,
                  pe.`Titulo` AS Pelicula, ej.`Numero` AS Numero_Ejemplar
           FROM `renta` r
           INNER JOIN `cliente` c         ON c.`Cliente_ID` = r.`Cliente_ID`
           INNER JOIN `ejemplar_renta` er ON er.`Renta_ID` = r.`Renta_ID`
           INNER JOIN `ejemplar` ej       ON ej.`Ejemplar_ID` = er.`Ejemplar_ID`
           INNER JOIN `pelicula` pe       ON pe.`Pelicula_ID` = ej.`Pelicula_ID`
           WHERE r.`Termina` IS NULL
           ORDER BY r.`Inicia`""",
    ),
    # GROUP BY: cuántas películas hay por país, de mayor a menor.
    "peliculas_por_nacionalidad": (
        "Películas por nacionalidad",
        """SELECT n.`Nombre` AS Nacionalidad, COUNT(*) AS Total_Peliculas
           FROM `pelicula` p
           INNER JOIN `nacionalidad` n ON n.`Nacionalidad_ID` = p.`Nacionalidad_ID`
           GROUP BY n.`Nombre`
           ORDER BY Total_Peliculas DESC""",
    ),
    # GROUP BY: cuántos ejemplares hay en cada estado de conservación.
    "ejemplares_por_estado": (
        "Ejemplares por estado de conservación",
        """SELECT es.`Nombre` AS Estado, COUNT(*) AS Total_Ejemplares
           FROM `ejemplar` e
           INNER JOIN `estado` es ON es.`Estado_ID` = e.`Estado_ID`
           GROUP BY es.`Nombre`""",
    ),
}


def main(argv):
    # Sin argumentos se ejecutan todas las consultas; con argumentos, solo las nombradas.
    nombres = argv or list(CONSULTAS)
    # Detecta nombres que no existan en el catálogo para fallar antes de conectar.
    desconocidas = [n for n in nombres if n not in CONSULTAS]
    if desconocidas:
        # sys.exit con un texto lo imprime en stderr y termina con código 1.
        sys.exit(f"Consulta desconocida: {', '.join(desconocidas)}. Opciones: {', '.join(CONSULTAS)}")
    # Una sola conexión para todas las consultas.
    with conexion() as con:
        for nombre in nombres:
            # Desempaqueta la pareja (título, SQL) y muestra el resultado como tabla.
            titulo, sql = CONSULTAS[nombre]
            imprimir(titulo, consultar(con, sql))


# Al lanzar el archivo, pasa a main() los argumentos (sin el nombre del script).
if __name__ == "__main__":
    principal(main, sys.argv[1:])
