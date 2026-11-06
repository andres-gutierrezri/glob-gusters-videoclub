// Conexión JDBC y excepción de errores SQL.
import java.sql.Connection;
import java.sql.SQLException;
// Lista inmutable para las sentencias.
import java.util.List;

/**
 * DDL (Data Definition Language) — equivalente a sql/mariadb/commands/01_DDL.sql.
 *
 * CREATE / ALTER / CREATE INDEX / DROP. Idempotente: todo usa IF [NOT] EXISTS.
 * Requiere haber ejecutado antes sql/mariadb/glob_gusters.sql.
 *
 * Requisitos: JDK 17 o superior, el driver java/lib/mariadb-java-client-3.5.3.jar (se descarga
 * una sola vez; ver README.md), un servidor MariaDB 10.2.1+ en marcha y la base glob_gusters
 * ya creada. Instalación y comandos para Windows, macOS y Linux: README.md, secciones
 * «Dependencias requeridas» y «Guía de ejecución por sistema operativo».
 * Compilación y ejecución, desde la carpeta java/:
 *     javac -encoding UTF-8 -d out *.java        (Windows PowerShell: (Get-ChildItem *.java).Name)
 *     java -cp "out:lib/*" Ddl          (Windows: java -cp "out;lib/*" Ddl)
 */
public class Ddl {

    // Sentencias DDL en el orden en que se ejecutan. Los bloques """ son text blocks (Java 15+).
    static final List<String> SENTENCIAS = List.of(
            // CREATE: tabla de prueba para demostrar CREATE TABLE.
            // IF NOT EXISTS evita el error si la tabla ya existe (re-ejecución segura).
            """
            CREATE TABLE IF NOT EXISTS `tabla_prueba` (
                `Tabla_Prueba_ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
                `Descripcion` VARCHAR(100) NOT NULL,
                PRIMARY KEY (`Tabla_Prueba_ID`)
            ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci
              COMMENT = 'Tabla temporal usada únicamente para demostrar sentencias DDL.'""",
            // ALTER: correo del socio.
            // ADD COLUMN IF NOT EXISTS agrega la columna solo si todavía no existe.
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
            // MODIFY COLUMN cambia el tipo de una columna existente (de VARCHAR(20) a VARCHAR(25)).
            """
            ALTER TABLE `cliente`
                MODIFY COLUMN `Telefono` VARCHAR(25) NOT NULL
                COMMENT 'Teléfono de contacto del socio, incluye indicativo internacional.'""",
            // CREATE INDEX: búsquedas por título.
            "CREATE INDEX IF NOT EXISTS `idx_pelicula_titulo` ON `pelicula` (`Titulo`)",
            // DROP: elimina la tabla de prueba.
            "DROP TABLE IF EXISTS `tabla_prueba`");

    public static void main(String[] args) throws SQLException {
        Conexion.configurarSalida();
        Conexion.correr(() -> principal(args));
    }

    /** Cuerpo del programa; main lo ejecuta con Conexion.correr() para explicar tablas dañadas. */
    private static void principal(String[] args) throws SQLException {
        // Abre la conexión (cuenta por defecto) y la cierra automáticamente al terminar.
        try (Connection con = Conexion.conectar()) {
            // Ejecuta cada sentencia DDL en orden.
            for (String sql : SENTENCIAS) {
                Conexion.ejecutar(con, sql);
                // Resumen: espacios múltiples colapsados en uno solo y máximo 90 caracteres.
                String resumen = sql.trim().replaceAll("\\s+", " ");
                System.out.println("OK: " + resumen.substring(0, Math.min(90, resumen.length())));
            }
            // Confirma los cambios (en MariaDB el DDL ya confirma implícitamente).
            con.commit();

            // Verifica el resultado consultando el diccionario del servidor (information_schema).
            // DATABASE() = base actual; el filtro IN compara pares (tabla, columna).
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
