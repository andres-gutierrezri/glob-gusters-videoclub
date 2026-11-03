import java.sql.Connection;
import java.sql.SQLException;

/**
 * DML (Data Manipulation Language) — equivalente a sql/mariadb/commands/02_DML.sql.
 *
 * INSERT (nuevo socio), UPDATE (estado de un ejemplar y duración de una película) y
 * DELETE (una fila de reparto). Todo se localiza por llave natural y es repetible.
 * Requiere glob_gusters_insert.sql y Ddl (columnas Email y Duracion_Minutos).
 * Las sentencias llevan parámetros (?), nunca valores concatenados en el SQL.
 */
public class Dml {

    public static void main(String[] args) throws SQLException {
        try (Connection con = Conexion.conectar()) {
            // INSERT: socio nuevo avalado por Laura Gómez (se busca por DNI). IGNORE evita el
            // duplicado en reejecuciones (Dni es UNIQUE). El aval va en tabla derivada porque
            // MariaDB no deja leer `cliente` directo dentro de un INSERT sobre `cliente`.
            int n = Conexion.ejecutar(con, """
                    INSERT IGNORE INTO `cliente`
                        (`Dni`, `Nombre`, `Direccion`, `Telefono`, `Aval_Cliente_ID`, `Email`)
                    VALUES (?, ?, ?, ?,
                            (SELECT `Cliente_ID` FROM
                                (SELECT `Cliente_ID` FROM `cliente` WHERE `Dni` = ?) AS `aval`),
                            ?)""",
                    "1000000005", "Sofía Ramírez", "Calle 50 # 20-30", "3011122334",
                    "1000000001", "sofia.ramirez@example.com");
            System.out.println("INSERT cliente: " + n + " fila(s)");

            // UPDATE: Quo Vadis (1951), ejemplar 2, queda como 'Dañado'.
            n = Conexion.ejecutar(con, """
                    UPDATE `ejemplar` e
                    INNER JOIN `pelicula` p ON p.`Pelicula_ID` = e.`Pelicula_ID`
                    SET e.`Estado_ID` = (SELECT `Estado_ID` FROM `estado` WHERE `Nombre` = ?)
                    WHERE p.`Titulo` = ? AND p.`Anio` = ? AND e.`Numero` = ?""",
                    "Dañado", "Quo Vadis", 1951, 2);
            System.out.println("UPDATE ejemplar: " + n + " fila(s)");

            // UPDATE: duración de Interstellar.
            n = Conexion.ejecutar(con,
                    "UPDATE `pelicula` SET `Duracion_Minutos` = ? WHERE `Titulo` = ? AND `Anio` = ?",
                    169, "Interstellar", 2014);
            System.out.println("UPDATE pelicula: " + n + " fila(s)");

            // DELETE: quita a Anne Hathaway del reparto de Interstellar.
            n = Conexion.ejecutar(con, """
                    DELETE r FROM `reparto` r
                    INNER JOIN `pelicula` p ON p.`Pelicula_ID` = r.`Pelicula_ID`
                    INNER JOIN `actor` a ON a.`Actor_ID` = r.`Actor_ID`
                    WHERE p.`Titulo` = ? AND p.`Anio` = ? AND a.`Nombre` = ?""",
                    "Interstellar", 2014, "Anne Hathaway");
            System.out.println("DELETE reparto: " + n + " fila(s)");

            con.commit();

            Conexion.imprimir("Cliente nuevo", Conexion.consultar(con,
                    "SELECT `Cliente_ID`, `Nombre`, `Email` FROM `cliente` WHERE `Dni` = ?", "1000000005"));
        }
    }
}
