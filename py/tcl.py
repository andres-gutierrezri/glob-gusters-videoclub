"""TCL (Transaction Control Language) — equivalente a sql/mariadb/commands/06_TCL.sql.

Ejemplo 1: START TRANSACTION + SAVEPOINT + COMMIT al registrar una renta con su detalle.
Ejemplo 2: transacción descartada con ROLLBACK.
Es repetible: si el cliente de ejemplo ya tiene ese ejemplar sin devolver, no inserta
nada (así no se acumulan préstamos hasta chocar con el trigger de máximo 4).

Requisitos: Python 3.9+, el paquete PyMySQL (`pip install -r requirements.txt` dentro del
entorno virtual .venv), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters ya
creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
«Dependencias requeridas» y «Guía de ejecución por sistema operativo».
Ejecución, con el entorno virtual activo y desde la raíz del proyecto:
    python py/tcl.py          (en Windows se escribe igual)
"""

# Módulo de PyMySQL; se usa para capturar el error que lanza el trigger de máximo 4.
import pymysql

# Funciones comunes de conexion.py.
from conexion import conexion, consultar, ejecutar, imprimir, principal, ERRORES_TABLA_DANADA

# DNI del socio de ejemplo (se busca por llave natural, no por ID fijo).
DNI_CLIENTE = "1000000004"  # Andrés Torres
# Ejemplar de ejemplo identificado por título, año y número de copia.
EJEMPLAR = ("Interstellar", 2014, 2)  # título, año, número de ejemplar


def main():
    with conexion() as con:
        # Busca el ID del cliente a partir de su DNI.
        cliente = consultar(con, "SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = %s", (DNI_CLIENTE,))
        # Busca el ID del ejemplar a partir de título, año y número.
        ejemplar = consultar(
            con,
            """SELECT e.`Ejemplar_ID` FROM `ejemplar` e
               INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
               WHERE p.`Titulo` = %s AND p.`Anio` = %s AND e.`Numero` = %s""",
            EJEMPLAR,
        )
        # Si faltan los datos de ejemplo, se detiene con un mensaje claro.
        if not cliente or not ejemplar:
            raise SystemExit("Faltan datos de ejemplo: ejecuta glob_gusters_insert.sql primero.")
        # Extrae los IDs de la primera (y única) fila de cada resultado.
        id_cliente, id_ejemplar = cliente[0]["Cliente_ID"], ejemplar[0]["Ejemplar_ID"]

        # ¿El socio ya tiene este ejemplar sin devolver? Si sí, no se vuelve a registrar.
        ya_existe = consultar(
            con,
            """SELECT 1 AS existe FROM `ejemplar_renta` er
               INNER JOIN `renta` r ON r.`Renta_ID` = er.`Renta_ID`
               WHERE r.`Cliente_ID` = %s AND er.`Ejemplar_ID` = %s AND er.`Entrega` IS NULL""",
            (id_cliente, id_ejemplar),
        )

        # --- Ejemplo 1: renta + detalle de forma atómica -----------------------------
        con.begin()  # START TRANSACTION
        if ya_existe:
            print("La renta de ejemplo ya existe; no se inserta de nuevo.")
        else:
            try:
                with con.cursor() as cur:
                    # Encabezado de la renta: hoy como fecha de inicio y sin fecha de devolución.
                    cur.execute(
                        "INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`) VALUES (%s, CURDATE(), NULL)",
                        (id_cliente,),
                    )
                    # ID autoincremental que acaba de generar el INSERT.
                    id_renta = cur.lastrowid
                    # Punto de control: permite deshacer solo lo posterior a este punto.
                    cur.execute("SAVEPOINT `sp_renta_creada`")
                    try:
                        # Detalle de la renta: aquí actúa el trigger de máximo 4 ejemplares.
                        cur.execute(
                            "INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`) VALUES (%s, %s, NULL)",
                            (id_renta, id_ejemplar),
                        )
                    except pymysql.err.OperationalError as error:
                        # Una tabla dañada no es un rechazo del trigger: sube al manejo común.
                        if error.args[0] in ERRORES_TABLA_DANADA:
                            raise
                        # Trigger de máximo 4 ejemplares: se conserva sólo el encabezado.
                        print("Detalle rechazado, ROLLBACK TO SAVEPOINT:", error.args[1])
                        cur.execute("ROLLBACK TO SAVEPOINT `sp_renta_creada`")
                    else:
                        # Sin error: renta y detalle quedaron registrados en la transacción.
                        print(f"Renta {id_renta} registrada con el ejemplar {id_ejemplar}.")
            except Exception:
                # Cualquier otro error deshace toda la transacción y se vuelve a lanzar.
                con.rollback()
                raise
        # COMMIT: confirma lo que haya quedado en la transacción.
        con.commit()

        # --- Ejemplo 2: cambio que se descarta ---------------------------------------
        con.begin()
        # Cambia temporalmente la dirección de Laura Gómez.
        ejecutar(con, "UPDATE `cliente` SET `Direccion` = %s WHERE `Dni` = %s",
                 ("Dirección temporal de prueba", "1000000001"))
        # Lee el valor dentro de la transacción (ya ve el cambio sin confirmar).
        dentro = consultar(con, "SELECT `Direccion` FROM `cliente` WHERE `Dni` = %s", ("1000000001",))
        # ROLLBACK: descarta el UPDATE.
        con.rollback()
        # Lee de nuevo: la dirección original debe haber vuelto.
        fuera = consultar(con, "SELECT `Direccion` FROM `cliente` WHERE `Dni` = %s", ("1000000001",))
        imprimir("Dirección dentro de la transacción", dentro)
        imprimir("Dirección tras el ROLLBACK", fuera)


# Ejecuta main() solo al lanzar el archivo directamente.
if __name__ == "__main__":
    principal(main)
