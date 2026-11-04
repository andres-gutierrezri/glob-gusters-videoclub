// Conexión JDBC y excepción de errores SQL.
import java.sql.Connection;
import java.sql.SQLException;
// LinkedHashMap conserva el orden de las cuentas.
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * DCL (Data Control Language) — equivalente a sql/mariadb/commands/05_DCL.sql.
 *
 * CREATE USER / GRANT / REVOKE / FLUSH PRIVILEGES / SHOW GRANTS. Requiere una cuenta
 * administrativa (por defecto root de XAMPP). Es repetible: CREATE USER usa IF NOT EXISTS.
 *
 * Las contraseñas de las cuentas de ejemplo se pueden cambiar con las variables de
 * entorno GLOB_GUSTERS_PASS_REPORTES y GLOB_GUSTERS_PASS_MOSTRADOR; los valores por
 * defecto son los mismos del .sql.
 */
public class Dcl {

    // Base de datos sobre la que se conceden los permisos.
    static final String BD = "glob_gusters";

    /** Cuenta de ejemplo: contraseña y privilegios concedidos. */
    record Cuenta(String clave, String privilegios) {}

    // Cuentas de ejemplo: nombre de usuario -> datos de la cuenta.
    static final Map<String, Cuenta> USUARIOS = new LinkedHashMap<>();

    // Bloque estático: llena el catálogo al cargar la clase. Conexion.env lee el sistema o el .env.
    static {
        // Cuenta de solo lectura para reportes.
        USUARIOS.put("glob_gusters_reportes",
                new Cuenta(Conexion.env("GLOB_GUSTERS_PASS_REPORTES", "Reportes#2024"), "SELECT"));
        // Cuenta de mostrador: puede consultar, insertar y actualizar (el DELETE se revoca abajo).
        USUARIOS.put("glob_gusters_mostrador",
                new Cuenta(Conexion.env("GLOB_GUSTERS_PASS_MOSTRADOR", "Mostrador#2024"), "SELECT, INSERT, UPDATE"));
    }

    public static void main(String[] args) throws SQLException {
        // Requiere privilegios administrativos (root) para crear usuarios y conceder permisos.
        try (Connection con = Conexion.conectar()) {
            for (Map.Entry<String, Cuenta> usuario : USUARIOS.entrySet()) {
                // Cuenta completa en formato MariaDB: 'usuario'@'host'.
                String cuenta = "'" + usuario.getKey() + "'@'localhost'";
                Cuenta datos = usuario.getValue();
                // La contraseña va como parámetro; el resto son nombres fijos definidos arriba.
                Conexion.ejecutar(con, "CREATE USER IF NOT EXISTS " + cuenta + " IDENTIFIED BY ?", datos.clave());
                // Concede los privilegios sobre todas las tablas de la base del proyecto.
                Conexion.ejecutar(con, "GRANT " + datos.privilegios() + " ON `" + BD + "`.* TO " + cuenta);
                System.out.println("Usuario " + cuenta + ": GRANT " + datos.privilegios());
            }

            // El personal de mostrador no puede borrar historial de rentas.
            Conexion.ejecutar(con, "REVOKE DELETE ON `" + BD + "`.* FROM 'glob_gusters_mostrador'@'localhost'");
            // Recarga las tablas de permisos para que los cambios apliquen de inmediato.
            Conexion.ejecutar(con, "FLUSH PRIVILEGES");

            // Muestra los permisos finales de cada cuenta de ejemplo.
            for (String usuario : USUARIOS.keySet()) {
                System.out.println("\n== Privilegios de " + usuario + " ==");
                for (Map<String, Object> fila : Conexion.consultar(con,
                        "SHOW GRANTS FOR '" + usuario + "'@'localhost'")) {
                    // Cada fila tiene una sola columna (con nombre variable): se toma su único valor.
                    System.out.println(fila.values().iterator().next());
                }
            }
        }
    }
}
