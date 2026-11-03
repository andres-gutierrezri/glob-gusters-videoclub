"""Conexión de Python a la base de datos glob_gusters (XAMPP MariaDB).

Equivale al comando de consola:
    mysql -u root -p -h localhost -P 3306 -D glob_gusters

Los valores por defecto son los de una instalación de XAMPP (root sin contraseña) y
pueden cambiarse con variables de entorno, sin tocar el código:
    GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER,
    GLOB_GUSTERS_PASSWORD, GLOB_GUSTERS_DB

Dependencia: pip install -r py/requirements.txt

Prueba rápida de la conexión:
    python py/conexion.py
"""

import os
from contextlib import contextmanager

import pymysql
from pymysql.cursors import DictCursor

CONFIG = {
    "host": os.getenv("GLOB_GUSTERS_HOST", "localhost"),
    "port": int(os.getenv("GLOB_GUSTERS_PORT", "3306")),
    "user": os.getenv("GLOB_GUSTERS_USER", "root"),
    "password": os.getenv("GLOB_GUSTERS_PASSWORD", ""),
    "database": os.getenv("GLOB_GUSTERS_DB", "glob_gusters"),
    "charset": "utf8mb4",
    "cursorclass": DictCursor,
}


def conectar(**cambios):
    """Abre una conexión nueva. `cambios` sobrescribe CONFIG (p.e. user=..., password=...).

    autocommit queda apagado: cada script decide cuándo hacer commit/rollback.
    """
    try:
        return pymysql.connect(**{**CONFIG, **cambios}, autocommit=False)
    except pymysql.err.OperationalError as error:
        if error.args[0] == 1049:
            raise SystemExit(
                "La base de datos no existe todavía: ejecuta primero "
                "sql/mariadb/glob_gusters.sql y glob_gusters_insert.sql (ver README)."
            ) from error
        raise


@contextmanager
def conexion(**cambios):
    """Context manager: entrega la conexión y la cierra al salir (aunque haya error)."""
    con = conectar(**cambios)
    try:
        yield con
    finally:
        con.close()


def consultar(con, sql, params=None):
    """Ejecuta un SELECT/SHOW y devuelve todas las filas como lista de dicts."""
    with con.cursor() as cur:
        cur.execute(sql, params)
        return cur.fetchall()


def ejecutar(con, sql, params=None):
    """Ejecuta una sentencia de escritura (sin commit) y devuelve las filas afectadas."""
    with con.cursor() as cur:
        return cur.execute(sql, params)


def imprimir(titulo, filas):
    """Imprime un resultado como tabla de texto alineada."""
    print(f"\n== {titulo} ==")
    if not filas:
        print("(sin filas)")
        return
    columnas = list(filas[0].keys())
    anchos = {c: max(len(str(c)), *(len(str(f[c])) for f in filas)) for c in columnas}
    print(" | ".join(str(c).ljust(anchos[c]) for c in columnas))
    print("-+-".join("-" * anchos[c] for c in columnas))
    for fila in filas:
        print(" | ".join(str(fila[c]).ljust(anchos[c]) for c in columnas))


if __name__ == "__main__":
    with conexion() as con:
        imprimir("Servidor", consultar(con, "SELECT VERSION() AS version, DATABASE() AS base_de_datos, CURRENT_USER() AS cuenta"))
