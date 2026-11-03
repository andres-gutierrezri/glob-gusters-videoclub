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
 */
public class Tcl {

    static final String DNI_CLIENTE = "1000000004"; // Andrés Torres
    static final String TITULO = "Interstellar";
    static final int ANIO = 2014;
    static final int NUMERO_EJEMPLAR = 2;

    public static void main(String[] args) throws SQLException {
        try (Connection con = Conexion.conectar()) {
            List<Map<String, Object>> cliente = Conexion.consultar(con,
                    "SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = ?", DNI_CLIENTE);
            List<Map<String, Object>> ejemplar = Conexion.consultar(con, """
                    SELECT e.`Ejemplar_ID` FROM `ejemplar` e
                    INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                    WHERE p.`Titulo` = ? AND p.`Anio` = ? AND e.`Numero` = ?""",
                    TITULO, ANIO, NUMERO_EJEMPLAR);
            if (cliente.isEmpty() || ejemplar.isEmpty()) {
                System.err.println("Faltan datos de ejemplo: ejecuta glob_gusters_insert.sql primero.");
                System.exit(1);
            }
            Object idCliente = cliente.get(0).get("Cliente_ID");
            Object idEjemplar = ejemplar.get(0).get("Ejemplar_ID");

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
                    long idRenta = insertarRenta(con, idCliente);
                    Savepoint sp = con.setSavepoint("sp_renta_creada");
                    try {
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
                    con.rollback();
                    throw error;
                }
            }
            con.commit();

            // --- Ejemplo 2: cambio que se descarta -------------------------------------
            Conexion.ejecutar(con, "UPDATE `cliente` SET `Direccion` = ? WHERE `Dni` = ?",
                    "Dirección temporal de prueba", "1000000001");
            List<Map<String, Object>> dentro = Conexion.consultar(con,
                    "SELECT `Direccion` FROM `cliente` WHERE `Dni` = ?", "1000000001");
            con.rollback();
            List<Map<String, Object>> fuera = Conexion.consultar(con,
                    "SELECT `Direccion` FROM `cliente` WHERE `Dni` = ?", "1000000001");
            Conexion.imprimir("Dirección dentro de la transacción", dentro);
            Conexion.imprimir("Dirección tras el ROLLBACK", fuera);
        }
    }

    /** Inserta el encabezado de la renta y devuelve su llave autoincremental. */
    private static long insertarRenta(Connection con, Object idCliente) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO `renta` (`Cliente_ID`, `Inicia`, `Termina`) VALUES (?, CURDATE(), NULL)",
                PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setObject(1, idCliente);
            ps.executeUpdate();
            try (ResultSet claves = ps.getGeneratedKeys()) {
                claves.next();
                return claves.getLong(1);
            }
        }
    }
}
