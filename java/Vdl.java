// Conexión JDBC y excepción de errores SQL.
import java.sql.Connection;
import java.sql.SQLException;
// LinkedHashMap conserva el orden de las vistas.
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * VDL (View Definition Language) — equivalente a sql/mariadb/commands/04_VDL.sql.
 *
 * CREATE OR REPLACE VIEW de las dos vistas del proyecto y consulta de cada una.
 * El DROP VIEW queda detrás de la opción --drop, igual que está comentado en el .sql:
 *     java -cp "out:lib/*" Vdl --drop
 *
 * Requisitos: JDK 17 o superior, el driver java/lib/mariadb-java-client-3.5.3.jar (se descarga
 * una sola vez; ver README.md), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters
 * ya creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
 * «Dependencias requeridas» y «Guía de ejecución por sistema operativo».
 * Compilación y ejecución, desde la carpeta java/:
 *     javac -encoding UTF-8 -d out *.java        (Windows PowerShell: (Get-ChildItem *.java).Name)
 *     java -cp "out:lib/*" Vdl          (Windows: java -cp "out;lib/*" Vdl)
 */
public class Vdl {

    /** Cada vista: sentencia de creación y consulta de verificación. */
    record Vista(String crear, String consulta) {}

    // Catálogo de vistas: nombre -> Vista.
    static final Map<String, Vista> VISTAS = new LinkedHashMap<>();

    // Bloque estático: se ejecuta una vez al cargar la clase y llena el catálogo.
    static {
        // Ejemplares con título, año y estado de conservación (une tres tablas).
        VISTAS.put("v_ejemplares_detalle", new Vista("""
                CREATE OR REPLACE VIEW `v_ejemplares_detalle` AS
                SELECT e.`Ejemplar_ID`, e.`Numero` AS Numero_Ejemplar, p.`Titulo` AS Pelicula,
                       p.`Anio`, es.`Nombre` AS Estado_Conservacion
                FROM `ejemplar` e
                INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                INNER JOIN `estado` es  ON es.`Estado_ID` = e.`Estado_ID`""",
                "SELECT * FROM `v_ejemplares_detalle` ORDER BY `Pelicula`, `Numero_Ejemplar`"));
        // Socios con el nombre de quien los avala; LEFT JOIN conserva a los que no tienen aval.
        VISTAS.put("v_clientes_con_aval", new Vista("""
                CREATE OR REPLACE VIEW `v_clientes_con_aval` AS
                SELECT c.`Cliente_ID`, c.`Nombre` AS Cliente, c.`Dni`, aval.`Nombre` AS Avalado_Por
                FROM `cliente` c
                LEFT JOIN `cliente` aval ON aval.`Cliente_ID` = c.`Aval_Cliente_ID`""",
                "SELECT * FROM `v_clientes_con_aval` ORDER BY `Cliente`"));
    }

    public static void main(String[] args) throws SQLException {
        Conexion.configurarSalida();
        // Abre la conexión y la cierra automáticamente al terminar.
        try (Connection con = Conexion.conectar()) {
            // Con la opción --drop solo se eliminan las vistas y se termina.
            if (List.of(args).contains("--drop")) {
                for (String nombre : VISTAS.keySet()) {
                    // Los nombres vienen de la constante VISTAS (no de datos externos).
                    Conexion.ejecutar(con, "DROP VIEW IF EXISTS `" + nombre + "`");
                    System.out.println("Vista eliminada: " + nombre);
                }
                con.commit();
                return;
            }
            // Modo normal: crea (o reemplaza) cada vista y muestra su contenido.
            for (Map.Entry<String, Vista> vista : VISTAS.entrySet()) {
                Conexion.ejecutar(con, vista.getValue().crear());
                Conexion.imprimir(vista.getKey(), Conexion.consultar(con, vista.getValue().consulta()));
            }
            con.commit();
        }
    }
}
