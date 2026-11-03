import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Conexión de Java (JDBC) a la base de datos glob_gusters (XAMPP MariaDB).
 *
 * Equivale al comando de consola:
 *     mysql -u root -p -h localhost -P 3306 -D glob_gusters
 *
 * Los valores por defecto son los de una instalación de XAMPP (root sin contraseña) y
 * pueden cambiarse con variables de entorno, sin tocar el código:
 *     GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER,
 *     GLOB_GUSTERS_PASSWORD, GLOB_GUSTERS_DB
 *
 * Dependencia: java/lib/mariadb-java-client-*.jar (ver README).
 *
 * Prueba rápida de la conexión:
 *     java -cp "out:lib/*" Conexion
 */
public class Conexion {

    static final String HOST = env("GLOB_GUSTERS_HOST", "localhost");
    static final int PORT = Integer.parseInt(env("GLOB_GUSTERS_PORT", "3306"));
    static final String USER = env("GLOB_GUSTERS_USER", "root");
    static final String PASSWORD = env("GLOB_GUSTERS_PASSWORD", "");
    static final String DB = env("GLOB_GUSTERS_DB", "glob_gusters");

    private static String env(String nombre, String defecto) {
        String valor = System.getenv(nombre);
        return valor == null ? defecto : valor;
    }

    /** Abre una conexión nueva con la cuenta por defecto. */
    static Connection conectar() throws SQLException {
        return conectar(USER, PASSWORD);
    }

    /**
     * Abre una conexión nueva con la cuenta indicada.
     * autocommit queda apagado: cada script decide cuándo hacer commit/rollback.
     */
    static Connection conectar(String usuario, String clave) throws SQLException {
        String url = "jdbc:mariadb://" + HOST + ":" + PORT + "/" + DB + "?characterEncoding=utf8";
        try {
            Connection con = DriverManager.getConnection(url, usuario, clave);
            con.setAutoCommit(false);
            return con;
        } catch (SQLException error) {
            if (error.getErrorCode() == 1049) {
                throw new IllegalStateException("La base de datos no existe todavía: ejecuta primero "
                        + "sql/mariadb/glob_gusters.sql y glob_gusters_insert.sql (ver README).", error);
            }
            throw error;
        }
    }

    /** Ejecuta un SELECT/SHOW y devuelve todas las filas como lista de mapas (columna -> valor). */
    static List<Map<String, Object>> consultar(Connection con, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = preparar(con, sql, params); ResultSet rs = ps.executeQuery()) {
            ResultSetMetaData meta = rs.getMetaData();
            List<Map<String, Object>> filas = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    fila.put(meta.getColumnLabel(i), rs.getObject(i));
                }
                filas.add(fila);
            }
            return filas;
        }
    }

    /** Ejecuta una sentencia de escritura (sin commit) y devuelve las filas afectadas. */
    static int ejecutar(Connection con, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = preparar(con, sql, params)) {
            return ps.executeUpdate();
        }
    }

    private static PreparedStatement preparar(Connection con, String sql, Object[] params) throws SQLException {
        PreparedStatement ps = con.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
        return ps;
    }

    /** Imprime un resultado como tabla de texto alineada. */
    static void imprimir(String titulo, List<Map<String, Object>> filas) {
        System.out.println("\n== " + titulo + " ==");
        if (filas.isEmpty()) {
            System.out.println("(sin filas)");
            return;
        }
        List<String> columnas = new ArrayList<>(filas.get(0).keySet());
        Map<String, Integer> anchos = new LinkedHashMap<>();
        for (String c : columnas) {
            int ancho = c.length();
            for (Map<String, Object> fila : filas) {
                ancho = Math.max(ancho, String.valueOf(fila.get(c)).length());
            }
            anchos.put(c, ancho);
        }
        System.out.println(unir(columnas, anchos, null, " | "));
        List<String> guiones = new ArrayList<>();
        for (String c : columnas) {
            guiones.add("-".repeat(anchos.get(c)));
        }
        System.out.println(String.join("-+-", guiones));
        for (Map<String, Object> fila : filas) {
            System.out.println(unir(columnas, anchos, fila, " | "));
        }
    }

    private static String unir(List<String> columnas, Map<String, Integer> anchos,
                               Map<String, Object> fila, String separador) {
        List<String> celdas = new ArrayList<>();
        for (String c : columnas) {
            String texto = fila == null ? c : String.valueOf(fila.get(c));
            celdas.add(String.format("%-" + anchos.get(c) + "s", texto));
        }
        return String.join(separador, celdas);
    }

    public static void main(String[] args) throws SQLException {
        try (Connection con = conectar()) {
            imprimir("Servidor", consultar(con,
                    "SELECT VERSION() AS version, DATABASE() AS base_de_datos, CURRENT_USER() AS cuenta"));
        }
    }
}
