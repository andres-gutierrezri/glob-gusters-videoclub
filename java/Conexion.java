// Entrada/salida de archivos: se usa para leer el archivo .env.
import java.io.IOException;
// Files ofrece utilidades para leer archivos; Path representa una ruta de archivo.
import java.nio.file.Files;
import java.nio.file.Path;
// Clases JDBC: conexión, gestor de drivers, sentencias preparadas y resultados.
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
// Colecciones usadas para guardar variables, filas y anchos de columna.
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Conexión de Java (JDBC) a la base de datos glob_gusters (XAMPP MariaDB).
 *
 * Esta clase es la base de todos los programas de la carpeta java/: lee la configuración,
 * abre las conexiones y ofrece las funciones comunes (conectar, consultar, ejecutar e
 * imprimir) que reutilizan Ddl, Dml, Dql, Vdl, Dcl y Tcl.
 *
 * Equivale al comando de consola:
 *     mysql -u root -p -h localhost -P 3306 -D glob_gusters
 *
 * Los valores por defecto son los de una instalación de XAMPP (root sin contraseña) y
 * pueden cambiarse con variables de entorno, sin tocar el código:
 *     GLOB_GUSTERS_HOST, GLOB_GUSTERS_PORT, GLOB_GUSTERS_USER,
 *     GLOB_GUSTERS_PASSWORD, GLOB_GUSTERS_DB
 * Si existe un archivo `.env` en la raíz del proyecto, se leen de ahí (las variables ya
 * definidas en el sistema tienen prioridad). Plantilla: `.env.example`.
 *
 * Requisitos: JDK 17 o superior, el driver java/lib/mariadb-java-client-3.5.3.jar (se descarga una
 * sola vez; ver README.md) y un servidor MariaDB 10.2.1+ en marcha. Instalación y comandos para
 * Windows, macOS y Linux: README.md, secciones «Dependencias requeridas» y «Guía de
 * ejecución por sistema operativo».
 *
 * Prueba rápida de la conexión:
 *     java -cp "out:lib/*" Conexion        (Windows: java -cp "out;lib/*" Conexion)
 */
public class Conexion {

    /** Variables leídas de .env (se declara antes que las constantes que la usan). */
    private static final Map<String, String> ENV_ARCHIVO = cargarEnv();

    // Servidor de MariaDB.
    static final String HOST = env("GLOB_GUSTERS_HOST", "localhost");
    // Puerto TCP; se convierte a entero porque las variables de entorno son texto.
    static final int PORT = Integer.parseInt(env("GLOB_GUSTERS_PORT", "3306"));
    // Usuario de la conexión.
    static final String USER = env("GLOB_GUSTERS_USER", "root");
    // Contraseña; vacía por defecto (XAMPP instala root sin contraseña).
    static final String PASSWORD = env("GLOB_GUSTERS_PASSWORD", "");
    // Base de datos del proyecto.
    static final String DB = env("GLOB_GUSTERS_DB", "glob_gusters");

    /** Valor de una variable: primero el sistema, luego el archivo .env y por último el defecto. */
    static String env(String nombre, String defecto) {
        // 1) Variable definida en el sistema operativo (tiene la máxima prioridad).
        String valor = System.getenv(nombre);
        if (valor == null) {
            // 2) Si no existe en el sistema, se busca en lo leído del archivo .env.
            valor = ENV_ARCHIVO.get(nombre);
        }
        // 3) Si tampoco está en el .env, se usa el valor por defecto.
        return valor == null ? defecto : valor;
    }

    /** Lee .env desde la raíz del proyecto (el directorio actual o su padre, si se ejecuta desde java/). */
    private static Map<String, String> cargarEnv() {
        // Mapa donde se guardan las parejas CLAVE -> valor encontradas.
        Map<String, String> valores = new HashMap<>();
        // Prueba primero ./.env (ejecución desde la raíz) y luego ../.env (ejecución desde java/).
        for (Path ruta : List.of(Path.of(".env"), Path.of("..", ".env"))) {
            // Si el archivo no existe en esta ubicación, prueba con la siguiente.
            if (!Files.isRegularFile(ruta)) {
                continue;
            }
            try {
                // Recorre el archivo línea por línea.
                for (String linea : Files.readAllLines(ruta)) {
                    // Quita espacios al inicio y al final.
                    linea = linea.strip();
                    // Posición del primer "=" (separa clave y valor); -1 si no hay.
                    int igual = linea.indexOf('=');
                    // Ignora líneas vacías, comentarios (#) y líneas sin "=".
                    if (linea.isEmpty() || linea.startsWith("#") || igual < 0) {
                        continue;
                    }
                    // Clave: texto antes del "=", sin espacios y sin el prefijo opcional `export `.
                    String clave = linea.substring(0, igual).strip().replaceFirst("^export\\s+", "");
                    // Valor: texto después del "=", sin espacios y sin comillas simples/dobles en los extremos.
                    valores.put(clave, linea.substring(igual + 1).strip().replaceAll("^[\"']|[\"']$", ""));
                }
            } catch (IOException error) {
                // Si el archivo no se puede leer, se avisa por la salida de error y se sigue con los defectos.
                System.err.println("No se pudo leer " + ruta + ": " + error.getMessage());
            }
            // Solo se usa el primer .env encontrado.
            break;
        }
        return valores;
    }

    /** Abre una conexión nueva con la cuenta por defecto. */
    static Connection conectar() throws SQLException {
        // Reutiliza la versión con parámetros usando USER y PASSWORD.
        return conectar(USER, PASSWORD);
    }

    /**
     * Abre una conexión nueva con la cuenta indicada.
     * autocommit queda apagado: cada script decide cuándo hacer commit/rollback.
     */
    static Connection conectar(String usuario, String clave) throws SQLException {
        // URL JDBC: protocolo, servidor, puerto, base de datos y codificación UTF-8.
        String url = "jdbc:mariadb://" + HOST + ":" + PORT + "/" + DB + "?characterEncoding=utf8";
        String claveSegura = clave == null ? "" : clave; // vacía o nula = sin contraseña
        try {
            // Abre la conexión con el driver MariaDB Connector/J.
            Connection con = DriverManager.getConnection(url, usuario, claveSegura);
            // Apaga el autocommit: las escrituras quedan en una transacción hasta el commit.
            con.setAutoCommit(false);
            return con;
        } catch (SQLException error) {
            // Error 1045 = acceso denegado. Se explica el motivo probable, sin mostrar la traza
            // técnica y sin imprimir nunca la contraseña, y se sale con código 1.
            if (error.getErrorCode() == 1045) {
                String destino = "'" + usuario + "' en " + HOST + ":" + PORT;
                if (claveSegura.isEmpty()) {
                    // No se envió contraseña: el usuario probablemente sí la necesita.
                    System.err.println("Acceso denegado para " + destino + " sin contraseña: define "
                            + "GLOB_GUSTERS_PASSWORD en el archivo .env (ver .env.example).");
                } else {
                    // Se envió una contraseña y el servidor la rechazó: usuario o clave incorrectos.
                    System.err.println("Acceso denegado para " + destino + ": el usuario o la contraseña son "
                            + "incorrectos. Revisa GLOB_GUSTERS_USER y GLOB_GUSTERS_PASSWORD en el "
                            + "archivo .env (ver .env.example) o en las variables de entorno.");
                }
                System.exit(1);
            }
            // Error 1049 = la base de datos no existe todavía. Se explica qué hacer, sin traza
            // técnica, y se sale con código 1 (igual que hace py/conexion.py).
            if (error.getErrorCode() == 1049) {
                System.err.println("La base de datos no existe todavía: ejecuta primero "
                        + "sql/mariadb/glob_gusters.sql y glob_gusters_insert.sql (ver README).");
                System.exit(1);
            }
            // Cualquier otro error se propaga sin modificar.
            throw error;
        }
    }

    /** Ejecuta un SELECT/SHOW y devuelve todas las filas como lista de mapas (columna -> valor). */
    static List<Map<String, Object>> consultar(Connection con, String sql, Object... params) throws SQLException {
        // try-with-resources: la sentencia y el resultado se cierran solos al terminar.
        try (PreparedStatement ps = preparar(con, sql, params); ResultSet rs = ps.executeQuery()) {
            // Metadatos del resultado: número, nombre y tipo de las columnas.
            ResultSetMetaData meta = rs.getMetaData();
            List<Map<String, Object>> filas = new ArrayList<>();
            // Avanza fila por fila hasta agotar el resultado.
            while (rs.next()) {
                // LinkedHashMap conserva el orden de las columnas.
                Map<String, Object> fila = new LinkedHashMap<>();
                // JDBC numera las columnas desde 1.
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    // El driver entrega YEAR como java.sql.Date (1997-01-01); se muestra solo el año.
                    boolean esAnio = "YEAR".equalsIgnoreCase(meta.getColumnTypeName(i));
                    // Guarda el valor bajo el nombre (o alias) de la columna.
                    fila.put(meta.getColumnLabel(i), esAnio ? (Object) rs.getObject(i, Integer.class) : rs.getObject(i));
                }
                filas.add(fila);
            }
            return filas;
        }
    }

    /** Ejecuta una sentencia de escritura (sin commit) y devuelve las filas afectadas. */
    static int ejecutar(Connection con, String sql, Object... params) throws SQLException {
        try (PreparedStatement ps = preparar(con, sql, params)) {
            // executeUpdate devuelve el número de filas afectadas; el commit lo hace quien llama.
            return ps.executeUpdate();
        }
    }

    // Crea la sentencia preparada y le asigna los parámetros (marcadores ?) en orden.
    private static PreparedStatement preparar(Connection con, String sql, Object[] params) throws SQLException {
        PreparedStatement ps = con.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            // Los índices de parámetros JDBC empiezan en 1, de ahí el i + 1.
            ps.setObject(i + 1, params[i]);
        }
        return ps;
    }

    /** Imprime un resultado como tabla de texto alineada. */
    static void imprimir(String titulo, List<Map<String, Object>> filas) {
        // Título de la tabla precedido de una línea en blanco.
        System.out.println("\n== " + titulo + " ==");
        // Si no hay filas, se avisa y se termina.
        if (filas.isEmpty()) {
            System.out.println("(sin filas)");
            return;
        }
        // Los nombres de columna salen de las llaves de la primera fila.
        List<String> columnas = new ArrayList<>(filas.get(0).keySet());
        // Ancho de cada columna: el mayor entre su nombre y cualquiera de sus valores.
        Map<String, Integer> anchos = new LinkedHashMap<>();
        for (String c : columnas) {
            int ancho = c.length();
            for (Map<String, Object> fila : filas) {
                ancho = Math.max(ancho, String.valueOf(fila.get(c)).length());
            }
            anchos.put(c, ancho);
        }
        // Fila de encabezados.
        System.out.println(unir(columnas, anchos, null, " | "));
        // Línea separadora con guiones del ancho de cada columna.
        List<String> guiones = new ArrayList<>();
        for (String c : columnas) {
            guiones.add("-".repeat(anchos.get(c)));
        }
        System.out.println(String.join("-+-", guiones));
        // Una línea por cada fila de datos.
        for (Map<String, Object> fila : filas) {
            System.out.println(unir(columnas, anchos, fila, " | "));
        }
    }

    // Construye una línea de la tabla: cada celda se rellena con espacios a su ancho.
    // Si `fila` es null, se imprimen los nombres de columna (encabezado).
    private static String unir(List<String> columnas, Map<String, Integer> anchos,
                               Map<String, Object> fila, String separador) {
        List<String> celdas = new ArrayList<>();
        for (String c : columnas) {
            // Texto de la celda: el nombre de la columna (encabezado) o el valor de la fila.
            String texto = fila == null ? c : String.valueOf(fila.get(c));
            // "%-Ns" alinea a la izquierda rellenando hasta N caracteres.
            celdas.add(String.format("%-" + anchos.get(c) + "s", texto));
        }
        return String.join(separador, celdas);
    }

    // Punto de entrada de la prueba rápida de conexión.
    public static void main(String[] args) throws SQLException {
        // La conexión se cierra automáticamente al salir del bloque try.
        try (Connection con = conectar()) {
            // Muestra versión del servidor, base de datos actual y cuenta conectada.
            imprimir("Servidor", consultar(con,
                    "SELECT VERSION() AS version, DATABASE() AS base_de_datos, CURRENT_USER() AS cuenta"));
        }
    }
}
