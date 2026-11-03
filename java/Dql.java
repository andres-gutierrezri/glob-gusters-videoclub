import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DQL (Data Query Language) — equivalente a sql/mariadb/commands/03_DQL.sql.
 *
 * Consultas de solo lectura: SELECT con condición, JOIN y GROUP BY.
 * Sin argumentos ejecuta todas; con un nombre ejecuta una sola:
 *     java -cp "out:lib/*" Dql disponibles
 */
public class Dql {

    record Consulta(String titulo, String sql) {}

    static final Map<String, Consulta> CONSULTAS = new LinkedHashMap<>();

    static {
        CONSULTAS.put("disponibles", new Consulta("Ejemplares disponibles para alquilar", """
                SELECT e.`Ejemplar_ID`, e.`Numero`, p.`Titulo`
                FROM `ejemplar` e
                INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                WHERE e.`Ejemplar_ID` NOT IN (
                    SELECT er.`Ejemplar_ID` FROM `ejemplar_renta` er WHERE er.`Entrega` IS NULL
                )"""));
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
        CONSULTAS.put("peliculas_por_nacionalidad", new Consulta("Películas por nacionalidad", """
                SELECT n.`Nombre` AS Nacionalidad, COUNT(*) AS Total_Peliculas
                FROM `pelicula` p
                INNER JOIN `nacionalidad` n ON n.`Nacionalidad_ID` = p.`Nacionalidad_ID`
                GROUP BY n.`Nombre`
                ORDER BY Total_Peliculas DESC"""));
        CONSULTAS.put("ejemplares_por_estado", new Consulta("Ejemplares por estado de conservación", """
                SELECT es.`Nombre` AS Estado, COUNT(*) AS Total_Ejemplares
                FROM `ejemplar` e
                INNER JOIN `estado` es ON es.`Estado_ID` = e.`Estado_ID`
                GROUP BY es.`Nombre`"""));
    }

    public static void main(String[] args) throws SQLException {
        List<String> nombres = args.length == 0 ? List.copyOf(CONSULTAS.keySet()) : List.of(args);
        List<String> desconocidas = nombres.stream().filter(n -> !CONSULTAS.containsKey(n)).toList();
        if (!desconocidas.isEmpty()) {
            System.err.println("Consulta desconocida: " + String.join(", ", desconocidas)
                    + ". Opciones: " + String.join(", ", CONSULTAS.keySet()));
            System.exit(1);
        }
        try (Connection con = Conexion.conectar()) {
            for (String nombre : nombres) {
                Consulta c = CONSULTAS.get(nombre);
                Conexion.imprimir(c.titulo(), Conexion.consultar(con, c.sql()));
            }
        }
    }
}
