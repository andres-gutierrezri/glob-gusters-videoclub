import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * DDL (Data Definition Language) — equivalente a sql/mariadb/commands/01_DDL.sql.
 *
 * CREATE / ALTER / CREATE INDEX / DROP. Idempotente: todo usa IF [NOT] EXISTS.
 * Requiere haber ejecutado antes sql/mariadb/glob_gusters.sql.
 */
public class Ddl {

    static final List<String> SENTENCIAS = List.of(
            // CREATE: tabla de prueba para demostrar CREATE TABLE.
            """
            CREATE TABLE IF NOT EXISTS `tabla_prueba` (
                `Tabla_Prueba_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
                `Descripcion` VARCHAR(100) NOT NULL,
                PRIMARY KEY (`Tabla_Prueba_ID`)
            ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
              COMMENT = 'Tabla temporal usada únicamente para demostrar sentencias DDL.'""",
            // ALTER: correo del socio.
            """
            ALTER TABLE `cliente`
                ADD COLUMN IF NOT EXISTS `Email` VARCHAR(120) NULL
                COMMENT 'Correo electrónico de contacto del socio (opcional).'""",
            // ALTER: duración de la película.
            """
            ALTER TABLE `pelicula`
                ADD COLUMN IF NOT EXISTS `Duracion_Minutos` SMALLINT UNSIGNED NULL
                COMMENT 'Duración de la película en minutos.'""",
            // ALTER: amplía el teléfono para indicativos internacionales.
            """
            ALTER TABLE `cliente`
                MODIFY COLUMN `Telefono` VARCHAR(25) NOT NULL
                COMMENT 'Teléfono de contacto del socio, incluye indicativo internacional.'""",
            // CREATE INDEX: búsquedas por título.
            "CREATE INDEX IF NOT EXISTS `idx_pelicula_titulo` ON `pelicula` (`Titulo`)",
            // DROP: elimina la tabla de prueba.
            "DROP TABLE IF EXISTS `tabla_prueba`");

    public static void main(String[] args) throws SQLException {
        try (Connection con = Conexion.conectar()) {
            for (String sql : SENTENCIAS) {
                Conexion.ejecutar(con, sql);
                String resumen = sql.trim().replaceAll("\\s+", " ");
                System.out.println("OK: " + resumen.substring(0, Math.min(90, resumen.length())));
            }
            con.commit();

            Conexion.imprimir("Columnas agregadas", Conexion.consultar(con, """
                    SELECT table_name AS tabla, column_name AS columna, column_type AS tipo
                    FROM information_schema.columns
                    WHERE table_schema = DATABASE()
                      AND (table_name, column_name) IN
                          (('cliente', 'Email'), ('cliente', 'Telefono'), ('pelicula', 'Duracion_Minutos'))
                    ORDER BY table_name, column_name"""));
        }
    }
}
