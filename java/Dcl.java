import java.sql.Connection;
import java.sql.SQLException;
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

    static final String BD = "glob_gusters";

    /** Cuenta de ejemplo: contraseña y privilegios concedidos. */
    record Cuenta(String clave, String privilegios) {}

    static final Map<String, Cuenta> USUARIOS = new LinkedHashMap<>();

    static {
        USUARIOS.put("glob_gusters_reportes",
                new Cuenta(env("GLOB_GUSTERS_PASS_REPORTES", "Reportes#2024"), "SELECT"));
        USUARIOS.put("glob_gusters_mostrador",
                new Cuenta(env("GLOB_GUSTERS_PASS_MOSTRADOR", "Mostrador#2024"), "SELECT, INSERT, UPDATE"));
    }

    private static String env(String nombre, String defecto) {
        String valor = System.getenv(nombre);
        return valor == null ? defecto : valor;
    }

    public static void main(String[] args) throws SQLException {
        try (Connection con = Conexion.conectar()) {
            for (Map.Entry<String, Cuenta> usuario : USUARIOS.entrySet()) {
                String cuenta = "'" + usuario.getKey() + "'@'localhost'";
                Cuenta datos = usuario.getValue();
                // La contraseña va como parámetro; el resto son nombres fijos definidos arriba.
                Conexion.ejecutar(con, "CREATE USER IF NOT EXISTS " + cuenta + " IDENTIFIED BY ?", datos.clave());
                Conexion.ejecutar(con, "GRANT " + datos.privilegios() + " ON `" + BD + "`.* TO " + cuenta);
                System.out.println("Usuario " + cuenta + ": GRANT " + datos.privilegios());
            }

            // El personal de mostrador no puede borrar historial de rentas.
            Conexion.ejecutar(con, "REVOKE DELETE ON `" + BD + "`.* FROM 'glob_gusters_mostrador'@'localhost'");
            Conexion.ejecutar(con, "FLUSH PRIVILEGES");

            for (String usuario : USUARIOS.keySet()) {
                System.out.println("\n== Privilegios de " + usuario + " ==");
                for (Map<String, Object> fila : Conexion.consultar(con,
                        "SHOW GRANTS FOR '" + usuario + "'@'localhost'")) {
                    System.out.println(fila.values().iterator().next());
                }
            }
        }
    }
}
