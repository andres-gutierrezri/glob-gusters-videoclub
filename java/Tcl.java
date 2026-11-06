// Clases JDBC: conexión, sentencias preparadas, resultados, excepciones y puntos de guardado.
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.util.List;
import java.util.Map;

/**
 * TCL (Transaction Control Language) — equivalente a sql/mariadb/commands/06_TCL.sql.
 *
 * Ejemplo 1: START TRANSACTION + SAVEPOINT + COMMIT al registrar una renta con su detalle.
 * Ejemplo 2: transacción descartada con ROLLBACK.
 * Es repetible: si el cliente de ejemplo ya tiene ese ejemplar sin devolver, no inserta
 * nada (así no se acumulan préstamos hasta chocar con el trigger de máximo 4).
 *
 * Requisitos: JDK 17 o superior, el driver java/lib/mariadb-java-client-3.5.3.jar (se descarga
 * una sola vez; ver README.md), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters
 * ya creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
 * «Dependencias requeridas» y «Guía de ejecución por sistema operativo».
 * Compilación y ejecución, desde la carpeta java/:
 *     javac -encoding UTF-8 -d out *.java        (Windows PowerShell: (Get-ChildItem *.java).Name)
 *     java -cp "out:lib/*" Tcl          (Windows: java -cp "out;lib/*" Tcl)
 */
public class Tcl {

    // DNI del socio de ejemplo (se busca por llave natural, no por ID fijo).
    static final String DNI_CLIENTE = "1000000004"; // Andrés Torres
    // Ejemplar de ejemplo identificado por título, año y número de copia.
    static final String TITULO = "Interstellar";
    static final int ANIO = 2014;
    static final int NUMERO_EJEMPLAR = 2;

    public static void main(String[] args) throws SQLException {
        Conexion.configurarSalida();
        // Abre la conexión y la cierra automáticamente al terminar.
        try (Connection con = Conexion.conectar()) {
            // Busca el ID del cliente a partir de su DNI.
            List<Map<String, Object>> cliente = Conexion.consultar(con,
                    "SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = ?", DNI_CLIENTE);
            // Busca el ID del ejemplar a partir de título, año y número.
            List<Map<String, Object>> ejemplar = Conexion.consultar(con, """
                    SELECT e.`Ejemplar_ID` FROM `ejemplar` e
                    INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                    WHERE p.`Titulo` = ? AND p.`Anio` = ? AND e.`Numero` = ?""",
                    TITULO, ANIO, NUMERO_EJEMPLAR);
            // Si faltan los datos de ejemplo, se detiene con un mensaje claro.
            if (cliente.isEmpty() || ejemplar.isEmpty()) {
                System.err.println("Faltan datos de ejemplo: ejecuta glob_gusters_insert.sql primero.");
                System.exit(1);
            }
            // Extrae los IDs de la primera (y única) fila de cada resultado.
            Object idCliente = cliente.get(0).get("Cliente_ID");
            Object idEjemplar = ejemplar.get(0).get("Ejemplar_ID");

            // ¿El socio ya tiene este ejemplar sin devolver? Si sí, no se vuelve a registrar.
            boolean yaExiste = !Conexion.consultar(con, """
                    SELECT 1 AS existe FROM `ejemplar_renta` er
                    INNER JOIN `renta` r ON r.`Renta_ID` = er.`Renta_ID`
                    WHERE r.`Cliente_ID` = ? AND er.`Ejemplar_ID` = ? AND er.`Entrega` IS NULL""",
                    idCliente, idEjemplar).isEmpty();

            // --- Ejemplo 1: renta + detalle de forma atómica ---------------------------
            // Con autocommit apagado la transacción (START TRANSACTION) ya está abierta.
            if (yaExiste) {
                System.out.println("La renta de ejemplo ya existe; no se inserta de nuevo.");
            } else {
                try {
                    // Encabezado de la renta; devuelve su ID autoincremental.
                    long idRenta = insertarRenta(con, idCliente);
                    // Punto de control: permite deshacer solo lo posterior a este punto.
                    Savepoint sp = con.setSavepoint("sp_renta_creada");
                    try {
                        // Detalle de la renta: aquí actúa el trigger de máximo 4 ejemplares.
                        Conexion.ejecutar(con,
                                "INSERT INTO `ejemplar_renta` (`Renta_ID`, `Ejemplar_ID`, `Entrega`) VALUES (?, ?, NULL)",
                                idRenta, idEjemplar);
                        System.out.println("Renta " + idRenta + " registrada con el ejemplar " + idEjemplar + ".");
                    } catch (SQLException error) {
                        // Trigger de máximo 4 ejemplares: se conserva sólo el encabezado.
                        System.out.println("Detalle rechazado, ROLLBACK TO SAVEPOINT: " + error.getMessage());
                        con.rollback(sp);
                    }
                } catch (SQLException error) {
                    // Cualquier otro error deshace toda la transacción y se vuelve a lanzar.
                    con.rollback();
                    throw error;
                }
            }
            // COMMIT: confirma lo que haya quedado en la transacción.
            con.commit();

            // --- Ejemplo 2: cambio que se descarta -------------------------------------
            // Cambia temporalmente la dirección de Laura Gómez.
            Conexion.ejecutar(con, "UPDATE `cliente` SET `Direccion` = ? WHERE `Dni` = ?",
                    "Dirección temporal de prueba", "1000000001");
            // Lee el valor dentro de la transacción (ya ve el cambio sin confirmar).
            List<Map<String, Object>> dentro = Conexion.consultar(con,
                    "SELECT `Direccion` FROM `cliente` WHERE `Dni` = ?", "1000000001");
            // ROLLBACK: descarta el UPDATE.
            con.rollback();
            // Lee de nuevo: la dirección original debe haber vuelto.
            List<Map<String, Object>> fuera = Conexion.consultar(con,
                    "SELECT `Direccion` FROM `cliente` WHERE `Dni` = ?", "1000000001");
            Conexion.imprimir("Dirección dentro de la transacción", dentro);
            Conexion.imprimir("Dirección tras el ROLLBACK", fuera);
        }
    }

    /** Inserta el encabezado de la renta y devuelve su llave autoincremental. */
    private static long insertarRenta(Connection con, Object idCliente) throws SQLException {
        // RETURN_GENERATED_KEYS pide al driver que devuelva el ID autogenerado.
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`) VALUES (?, CURDATE(), NULL)",
                PreparedStatement.RETURN_GENERATED_KEYS)) {
            // Primer (y único) parámetro: el ID del cliente.
            ps.setObject(1, idCliente);
            ps.executeUpdate();
            // Lee la llave generada: una fila con una columna.
            try (ResultSet claves = ps.getGeneratedKeys()) {
                claves.next();
                return claves.getLong(1);
            }
        }
    }
}
