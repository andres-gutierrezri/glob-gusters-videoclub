"""Conexión de Python a la base de datos glob_gusters (XAMPP MariaDB).

Este módulo es la base de todos los scripts de la carpeta py/: define cómo se leen los
datos de conexión y ofrece las funciones comunes (conectar, consultar, ejecutar e
imprimir) que reutilizan ddl.py, dml.py, dql.py, vdl.py, dcl.py y tcl.py.

Equivale al comando de consola:
    mysql -u root -p -h localhost -P 3306 -D glob_gusters

Los valores por defecto son los de una instalación de XAMPP (root sin contraseña) y
pueden cambiarse con variables de entorno, sin tocar el código:
    GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER,
    GLOB_GUSTERS_PASSWORD, GLOB_GUSTERS_DB
Si existe un archivo `.env` en la raíz del proyecto, se leen de ahí (las variables ya
definidas en el sistema tienen prioridad). Plantilla: `.env.example`.

Requisitos: Python 3.9+, el paquete PyMySQL (pip install -r requirements.txt dentro del
entorno virtual .venv) y un servidor MariaDB 10.2.1+ en marcha. Instalación y comandos para
Windows, macOS y Linux: README.md, secciones «Dependencias requeridas» y «Guía de
ejecución por sistema operativo».

Prueba rápida de la conexión:
    python py/conexion.py
"""

# Módulo estándar para leer variables de entorno (os.getenv) y escribirlas (os.environ).
import os
# Flujos de salida estándar (sys.stdout / sys.stderr), cuya codificación se fija abajo.
import sys
# `contextmanager` convierte una función generadora en un bloque `with ... as ...`.
from contextlib import contextmanager
# `Path` representa rutas de archivos de forma portable entre Windows, macOS y Linux.
from pathlib import Path

# Conector MySQL/MariaDB escrito en Python puro (dependencia de requirements.txt).
import pymysql
# Banderas del protocolo de conexión (se usa FOUND_ROWS, ver conectar()).
from pymysql.constants import CLIENT
# Cursor que devuelve cada fila como diccionario {columna: valor} en vez de tupla.
from pymysql.cursors import DictCursor


def _salida_utf8():
    """Fuerza UTF-8 en la salida estándar para que las tildes y la ñ se impriman bien.

    Sin esto, al redirigir la salida (a un archivo, una tubería o una bitácora) Python usa la
    codificación local (cp1252 en Windows, ASCII con LANG=C en Linux) y escribe bytes que
    los demás programas no leen como UTF-8, o falla con UnicodeEncodeError. En una terminal
    no cambia nada visible, pero la terminal debe estar en UTF-8 (en Windows: `chcp 65001`;
    los lanzadores de shell/ ya lo hacen). Se ejecuta al importar este módulo, así que cubre
    ddl.py, dml.py, dql.py, vdl.py, dcl.py, tcl.py y conexion_mariabd.py.
    """
    for flujo in (sys.stdout, sys.stderr):
        try:
            flujo.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass  # flujo sustituido por otro objeto (p. ej. un IDE) que no admite reconfigure


_salida_utf8()


def _cargar_env(ruta):
    """Carga las líneas CLAVE=VALOR de `ruta` en os.environ sin pisar lo ya definido."""
    # Si el archivo .env no existe, no hay nada que cargar y se usan los valores por defecto.
    if not ruta.is_file():
        return
    # Recorre el archivo línea por línea (leído en UTF-8 para respetar las tildes).
    for linea in ruta.read_text(encoding="utf-8").splitlines():
        # Quita espacios y saltos de línea sobrantes al inicio y al final.
        linea = linea.strip()
        # Ignora líneas vacías, comentarios (#) y líneas sin signo "=" (no son CLAVE=VALOR).
        if not linea or linea.startswith("#") or "=" not in linea:
            continue
        # Admite el prefijo `export ` y parte la línea en el primer "=": clave y valor.
        clave, valor = linea.removeprefix("export ").split("=", 1)
        # setdefault solo asigna si la variable NO existe ya en el sistema (el sistema gana);
        # además se quitan espacios y las comillas simples o dobles alrededor del valor.
        os.environ.setdefault(clave.strip(), valor.strip().strip("\"'"))


# Ejecuta la carga al importar el módulo. La ruta sube dos niveles desde este archivo:
# py/conexion.py -> py/ -> raíz del proyecto, donde vive el .env.
_cargar_env(Path(__file__).resolve().parent.parent / ".env")

# Parámetros de conexión que entiende pymysql.connect(); cada uno sale del entorno o,
# si no está definido, toma el valor por defecto de XAMPP.
CONFIG = {
    # Servidor de MariaDB.
    "host": os.getenv("GLOB_GUSTERS_HOST", "localhost"),
    # Puerto TCP; se convierte a entero porque las variables de entorno son texto.
    "port": int(os.getenv("GLOB_GUSTERS_PORT", "3306")),
    # Usuario de la conexión.
    "user": os.getenv("GLOB_GUSTERS_USER", "root"),
    # Vacía o inexistente equivale a "sin contraseña" (el valor de XAMPP para root).
    "password": os.getenv("GLOB_GUSTERS_PASSWORD") or "",
    # Base de datos a la que se conecta.
    "database": os.getenv("GLOB_GUSTERS_DB", "glob_gusters"),
    # Juego de caracteres completo (tildes, ñ, emojis).
    "charset": "utf8mb4",
    # Las consultas devuelven filas como diccionarios.
    "cursorclass": DictCursor,
}


def conectar(**cambios):
    """Abre una conexión nueva. `cambios` sobrescribe CONFIG (p.e. user=..., password=...).

    autocommit queda apagado: cada script decide cuándo hacer commit/rollback.
    """
    # Combina CONFIG con los cambios recibidos; lo que venga en `cambios` tiene prioridad.
    datos = {**CONFIG, **cambios}
    datos["password"] = datos.get("password") or ""  # None también significa "sin contraseña"
    try:
        # Abre la conexión con autocommit apagado: las escrituras quedan en una transacción.
        # FOUND_ROWS hace que un UPDATE informe las filas que coinciden con el WHERE (aunque
        # no cambien), igual que el cliente de MariaDB y el driver JDBC de java/; sin ella
        # PyMySQL cuenta solo las filas realmente modificadas y Python y Java discreparían.
        return pymysql.connect(**datos, autocommit=False, client_flag=CLIENT.FOUND_ROWS)
    except pymysql.err.OperationalError as error:
        # Error 1045 = acceso denegado. Se explica el motivo probable sin mostrar la traza
        # técnica y sin imprimir nunca la contraseña.
        if error.args[0] == 1045:
            destino = f"'{datos['user']}' en {datos['host']}:{datos['port']}"
            if not datos["password"]:
                # No se envió contraseña: el usuario probablemente sí la necesita.
                motivo = (f"Acceso denegado para {destino} sin contraseña: define "
                          "GLOB_GUSTERS_PASSWORD en el archivo .env (ver .env.example).")
            else:
                # Se envió una contraseña y el servidor la rechazó: usuario o clave incorrectos.
                motivo = (f"Acceso denegado para {destino}: el usuario o la contraseña son "
                          "incorrectos. Revisa GLOB_GUSTERS_USER y GLOB_GUSTERS_PASSWORD en el "
                          "archivo .env (ver .env.example) o en las variables de entorno.")
            raise SystemExit(motivo) from error
        # Error 1049 = la base de datos no existe todavía.
        if error.args[0] == 1049:
            raise SystemExit(
                "La base de datos no existe todavía: ejecuta primero "
                "sql/mariadb/glob_gusters.sql y glob_gusters_insert.sql (ver README)."
            ) from error
        # Cualquier otro error de conexión se propaga sin modificar.
        raise


# Texto que se muestra cuando una tabla del servidor está dañada en disco (por ejemplo, las
# tablas de permisos del esquema mysql, que usan el motor Aria).
AYUDA_TABLA_DANADA = r"""El servidor MariaDB informó una tabla dañada: {detalle}
Suele pasar tras un cierre sucio de XAMPP; las tablas de permisos del esquema mysql
usan el motor Aria. Esto no es un fallo del proyecto. Para repararla:
  1. Con MariaDB encendido, busca la tabla dañada:
       mysqlcheck -u root -p --check --databases mysql
  2. Repárala (o usa REPAIR TABLE mysql.<tabla>;):
       mysqlcheck -u root -p --repair --databases mysql
  3. Si no repara: detén MySQL en XAMPP, copia la carpeta mysql\data como respaldo y
       cd C:\xampp\mysql\data\mysql
       ..\..\bin\aria_chk.exe --recover --force *.MAI
     Si aún falla, con el servidor apagado borra data\aria_log.* y data\aria_log_control
     (MariaDB los recrea) o restaura data\mysql desde mysql\backup\mysql.
  4. Arranca MySQL y vuelve a ejecutar el script.
Para evitarlo, detén MySQL con el botón Stop de XAMPP antes de apagar el equipo."""

# Códigos de error de tabla dañada: 1030 (error del motor), 144/145 (tabla marcada como
# dañada) y 1194/1195 (tabla dañada según CHECK TABLE).
ERRORES_TABLA_DANADA = (144, 145, 1030, 1194, 1195)


def explicar_tabla_danada(codigo, detalle):
    """Si `codigo` es de tabla dañada, termina el programa con los pasos de reparación.

    No hace nada con otros códigos: quien llama debe propagar el error original.
    """
    if codigo in ERRORES_TABLA_DANADA:
        raise SystemExit(AYUDA_TABLA_DANADA.format(detalle=detalle))


def principal(funcion, *args):
    """Ejecuta `funcion(*args)`; una tabla dañada se explica sin mostrar la traza técnica."""
    try:
        return funcion(*args)
    except pymysql.err.OperationalError as error:
        explicar_tabla_danada(error.args[0], error.args[1] if len(error.args) > 1 else error)
        # Cualquier otro error se propaga sin modificar.
        raise


@contextmanager
def conexion(**cambios):
    """Context manager: entrega la conexión y la cierra al salir (aunque haya error)."""
    # Abre la conexión; `cambios` se reenvía a conectar().
    con = conectar(**cambios)
    try:
        # Entrega la conexión al bloque `with`.
        yield con
    finally:
        # Se ejecuta siempre al salir del bloque, con o sin excepción.
        con.close()


def consultar(con, sql, params=None):
    """Ejecuta un SELECT/SHOW y devuelve todas las filas como lista de dicts."""
    # El cursor se cierra solo al terminar el bloque `with`.
    with con.cursor() as cur:
        # Los valores van en `params` (marcadores %s): pymysql los escapa, no se concatenan.
        cur.execute(sql, params)
        # Trae todas las filas del resultado.
        return cur.fetchall()


def ejecutar(con, sql, params=None):
    """Ejecuta una sentencia de escritura (sin commit) y devuelve las filas afectadas."""
    with con.cursor() as cur:
        # execute() devuelve el número de filas afectadas; el commit lo hace quien llama.
        return cur.execute(sql, params)


def imprimir(titulo, filas):
    """Imprime un resultado como tabla de texto alineada."""
    # Título de la tabla precedido de una línea en blanco.
    print(f"\n== {titulo} ==")
    # Si la consulta no devolvió nada, se avisa y se termina.
    if not filas:
        print("(sin filas)")
        return
    # Los nombres de columna salen de las llaves de la primera fila.
    columnas = list(filas[0].keys())
    # Ancho de cada columna: el mayor entre su nombre y cualquiera de sus valores.
    anchos = {c: max(len(str(c)), *(len(str(f[c])) for f in filas)) for c in columnas}
    # Fila de encabezados, cada celda rellenada con espacios a su ancho.
    print(" | ".join(str(c).ljust(anchos[c]) for c in columnas))
    # Línea separadora con guiones del ancho de cada columna.
    print("-+-".join("-" * anchos[c] for c in columnas))
    # Una línea por cada fila de datos.
    for fila in filas:
        print(" | ".join(str(fila[c]).ljust(anchos[c]) for c in columnas))


# Solo se ejecuta al lanzar el archivo directamente (python py/conexion.py), no al importarlo.
if __name__ == "__main__":
    # Abre la conexión, consulta versión del servidor, base actual y cuenta, y lo imprime.
    def _servidor():
        with conexion() as con:
            imprimir("Servidor", consultar(con, "SELECT VERSION() AS version, DATABASE() AS base_de_datos, CURRENT_USER() AS cuenta"))
    principal(_servidor)
