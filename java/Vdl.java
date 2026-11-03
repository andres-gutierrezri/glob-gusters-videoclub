import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * VDL (View Definition Language) — equivalente a sql/mariadb/commands/04_VDL.sql.
 *
 * CREATE OR REPLACE VIEW de las dos vistas del proyecto y consulta de cada una.
 * El DROP VIEW queda detrás de la opción --drop, igual que está comentado en el .sql:
 *     java -cp "out:lib/*" Vdl --drop
 */
public class Vdl {

    /** Cada vista: sentencia de creación y consulta de verificación. */
    record Vista(String crear, String consulta) {}

    static final Map<String, Vista> VISTAS = new LinkedHashMap<>();

    static {
        VISTAS.put("v_ejemplares_detalle", new Vista("""
                CREATE OR REPLACE VIEW `v_ejemplares_detalle` AS
                SELECT e.`Ejemplar_ID`, e.`Numero` AS Numero_Ejemplar, p.`Titulo` AS Pelicula,
                       p.`Anio`, es.`Nombre` AS Estado_Conservacion
                FROM `ejemplar` e
                INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                INNER JOIN `estado` es  ON es.`Estado_ID` = e.`Estado_ID`""",
                "SELECT * FROM `v_ejemplares_detalle` ORDER BY `Pelicula`, `Numero_Ejemplar`"));
        VISTAS.put("v_clientes_con_aval", new Vista("""
                CREATE OR REPLACE VIEW `v_clientes_con_aval` AS
                SELECT c.`Cliente_ID`, c.`Nombre` AS Cliente, c.`Dni`, aval.`Nombre` AS Avalado_Por
                FROM `cliente` c
                LEFT JOIN `cliente` aval ON aval.`Cliente_ID` = c.`Aval_Cliente_ID`""",
                "SELECT * FROM `v_clientes_con_aval` ORDER BY `Cliente`"));
    }

    public static void main(String[] args) throws SQLException {
        try (Connection con = Conexion.conectar()) {
            if (List.of(args).contains("--drop")) {
                for (String nombre : VISTAS.keySet()) {
                    Conexion.ejecutar(con, "DROP VIEW IF EXISTS `" + nombre + "`");
                    System.out.println("Vista eliminada: " + nombre);
                }
                con.commit();
                return;
            }
            for (Map.Entry<String, Vista> vista : VISTAS.entrySet()) {
                Conexion.ejecutar(con, vista.getValue().crear());
                Conexion.imprimir(vista.getKey(), Conexion.consultar(con, vista.getValue().consulta()));
            }
            con.commit();
        }
    }
}
