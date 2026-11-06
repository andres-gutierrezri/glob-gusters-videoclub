// Conexión JDBC y excepción de errores SQL.
import java.sql.Connection;
import java.sql.SQLException;
// LinkedHashMap conserva el orden de inserción de las consultas.
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DQL (Data Query Language) — equivalente a sql/mariadb/commands/03_DQL.sql.
 *
 * Consultas de solo lectura: SELECT con condición, JOIN y GROUP BY.
 * Sin argumentos ejecuta todas; con un nombre ejecuta una sola:
 *     java -cp "out:lib/*" Dql disponibles
 *
 * Requisitos: JDK 17 o superior, el driver java/lib/mariadb-java-client-3.5.3.jar (se descarga
 * una sola vez; ver README.md), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters
 * ya creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
 * «Dependencias requeridas» y «Guía de ejecución por sistema operativo».
 * Compilación y ejecución, desde la carpeta java/:
 *     javac -encoding UTF-8 -d out *.java        (Windows PowerShell: (Get-ChildItem *.java).Name)
 *     java -cp "out:lib/*" Dql          (Windows: java -cp "out;lib/*" Dql)
 */
public class Dql {

    // Una consulta: título para mostrar y sentencia SQL (record = clase inmutable de datos, Java 16+).
    record Consulta(String titulo, String sql) {}

    // Catálogo de consultas: nombre corto -> Consulta.
    static final Map<String, Consulta> CONSULTAS = new LinkedHashMap<>();

    // Bloque estático: se ejecuta una vez al cargar la clase y llena el catálogo.
    static {
        // SELECT con condición: ejemplares sin una devolución pendiente (Entrega NULL).
        CONSULTAS.put("disponibles", new Consulta("Ejemplares disponibles para alquilar", """
                SELECT e.`Ejemplar_ID`, e.`Numero`, p.`Titulo`
                FROM `ejemplar` e
                INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                WHERE e.`Ejemplar_ID` NOT IN (
                    SELECT er.`Ejemplar_ID` FROM `ejemplar_renta` er WHERE er.`Entrega` IS NULL
                )"""));
        // JOIN de cinco tablas: rentas que aún no tienen fecha de devolución.
        CONSULTAS.put("rentas_activas", new Consulta("Rentas activas (sin fecha de devolución)", """
                SELECT c.`Nombre` AS Cliente, r.`Renta_ID`, r.`Inicia`,
                       pe.`Titulo` AS Pelicula, ej.`Numero` AS Numero_Ejemplar
                FROM `renta` r
                INNER JOIN `cliente` c         ON c.`Cliente_ID` = r.`Cliente_ID`
                INNER JOIN `ejemplar_renta` er ON er.`Renta_ID` = r.`Renta_ID`
                INNER JOIN `ejemplar` ej       ON ej.`Ejemplar_ID` = er.`Ejemplar_ID`
                INNER JOIN `pelicula` pe       ON pe.`Pelicula_ID` = ej.`Pelicula_ID`
                WHERE r.`Termina` IS NULL
                ORDER BY r.`Inicia`"""));
        // GROUP BY: cuántas películas hay por país, de mayor a menor.
        CONSULTAS.put("peliculas_por_nacionalidad", new Consulta("Películas por nacionalidad", """
                SELECT n.`Nombre` AS Nacionalidad, COUNT(*) AS Total_Peliculas
                FROM `pelicula` p
                INNER JOIN `nacionalidad` n ON n.`Nacionalidad_ID` = p.`Nacionalidad_ID`
                GROUP BY n.`Nombre`
                ORDER BY Total_Peliculas DESC"""));
        // GROUP BY: cuántos ejemplares hay en cada estado de conservación.
        CONSULTAS.put("ejemplares_por_estado", new Consulta("Ejemplares por estado de conservación", """
                SELECT es.`Nombre` AS Estado, COUNT(*) AS Total_Ejemplares
                FROM `ejemplar` e
                INNER JOIN `estado` es ON es.`Estado_ID` = e.`Estado_ID`
                GROUP BY es.`Nombre`"""));
    }

    public static void main(String[] args) throws SQLException {
        Conexion.configurarSalida();
        // Sin argumentos se ejecutan todas las consultas; con argumentos, solo las nombradas.
        List<String> nombres = args.length == 0 ? List.copyOf(CONSULTAS.keySet()) : List.of(args);
        // Detecta nombres que no existan en el catálogo para fallar antes de conectar.
        List<String> desconocidas = nombres.stream().filter(n -> !CONSULTAS.containsKey(n)).toList();
        if (!desconocidas.isEmpty()) {
            // Mensaje de error con las opciones válidas y salida con código 1.
            System.err.println("Consulta desconocida: " + String.join(", ", desconocidas)
                    + ". Opciones: " + String.join(", ", CONSULTAS.keySet()));
            System.exit(1);
        }
        // Una sola conexión para todas las consultas.
        try (Connection con = Conexion.conectar()) {
            for (String nombre : nombres) {
                // Recupera la consulta y muestra su resultado como tabla.
                Consulta c = CONSULTAS.get(nombre);
                Conexion.imprimir(c.titulo(), Conexion.consultar(con, c.sql()));
            }
        }
    }
}
