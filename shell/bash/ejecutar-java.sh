#!/usr/bin/env bash
# =====================================================================================
# ejecutar-java.sh — Compila y ejecuta todas las clases de java/ (Linux y macOS)
# =====================================================================================
# Primero actualiza el driver JDBC: consulta en Maven Central la última versión 3.x
# estable de MariaDB Connector/J y, si java/lib/ no la tiene, la descarga y borra las
# anteriores (sin Internet usa el driver que haya; si no hay ninguno, baja la 3.5.3).
# Solo se actualiza dentro de la serie 3.x: la 4.x exige TLS y no conecta con el MariaDB
# de XAMPP sin configurarlo. Después compila con javac y ejecuta, en orden: Conexion,
# Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere JDK 17+ y que la base ya exista (ejecutar-sql.sh).
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-java.sh
# =====================================================================================
set -u
. "$(dirname "$0")/lib.sh"

uso() { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; }
ayuda_si_se_pide "${1:-}"

MAVEN=https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client
LINEA=3            # serie del driver que se mantiene actualizada
JAR_BASE=3.5.3     # versión que se baja si no hay Internet y aún no hay driver

command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1 \
    || { falla "No se encontró el JDK (javac/java). Instala JDK 17 o superior."; exit 1; }

cd "$RAIZ/java" || exit 1
asegurar_env

# Escribe en la salida estándar el contenido de una URL (arg 1) con un límite de segundos (arg 2).
leer_url() {
    if command -v curl >/dev/null 2>&1; then curl -fsSL --max-time "$2" "$1"
    elif command -v wget >/dev/null 2>&1; then wget -q -T "$2" -O - "$1"
    else return 1; fi
}

mkdir -p lib
info "Actualizando el driver JDBC (última versión $LINEA.x de MariaDB Connector/J)"
ULTIMA=$(leer_url "$MAVEN/maven-metadata.xml" 20 2>/dev/null \
    | grep -o "<version>$LINEA\.[0-9]*\.[0-9]*</version>" | sed 's/<[^>]*>//g' \
    | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
EXISTENTES=$(ls lib/mariadb-java-client-*.jar 2>/dev/null)
if [ -z "$ULTIMA" ]; then
    if [ -n "$EXISTENTES" ]; then
        aviso "No se pudo consultar la última versión (¿sin conexión a Internet?). Se usa el driver de java/lib."
    else
        ULTIMA=$JAR_BASE
    fi
fi
if [ -n "$ULTIMA" ]; then
    JAR=mariadb-java-client-$ULTIMA.jar
    if [ -f "lib/$JAR" ]; then
        ok "Driver al día: $JAR"
        for f in lib/mariadb-java-client-*.jar; do [ "$f" = "lib/$JAR" ] || rm -f "$f"; done
    else
        info "Descargando $JAR"
        if leer_url "$MAVEN/$ULTIMA/$JAR" 120 > "lib/$JAR.part" 2>/dev/null && [ -s "lib/$JAR.part" ]; then
            mv "lib/$JAR.part" "lib/$JAR"
            # Deja solo este driver: con varios en lib/* el classpath mezclaría versiones.
            for f in lib/mariadb-java-client-*.jar; do [ "$f" = "lib/$JAR" ] || rm -f "$f"; done
        else
            rm -f "lib/$JAR.part"
            if [ -n "$EXISTENTES" ]; then
                aviso "No se pudo descargar $JAR. Se usa el driver de java/lib."
            else
                falla "No se pudo descargar el driver desde $MAVEN/$ULTIMA/$JAR (se necesita curl o wget)."; exit 1
            fi
        fi
    fi
fi

info "Compilando java/*.java"
javac -encoding UTF-8 -d out *.java || { falla "Falló la compilación (¿JDK 17+?)."; exit 1; }

for c in Conexion Ddl Dml Dql Vdl Dcl Tcl; do
    info "java $c"
    java -cp "out:lib/*" "$c" || { falla "Falló la clase $c"; exit 1; }
done
ok "Java completado."
