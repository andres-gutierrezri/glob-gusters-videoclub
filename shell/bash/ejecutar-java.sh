#!/usr/bin/env bash
# =====================================================================================
# ejecutar-java.sh — Compila y ejecuta todas las clases de java/ (Linux y macOS)
# =====================================================================================
# Descarga el driver JDBC (MariaDB Connector/J 3.5.3) a java/lib/ si falta, compila con
# javac y ejecuta, en orden: Conexion, Ddl, Dml, Dql, Vdl, Dcl y Tcl. Requiere JDK 17+
# y que la base ya exista (ejecutar-sql.sh).
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-java.sh
# =====================================================================================
set -u
. "$(dirname "$0")/lib.sh"

uso() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; }
ayuda_si_se_pide "${1:-}"

JAR=mariadb-java-client-3.5.3.jar
URL=https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.5.3/$JAR

command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1 \
    || { falla "No se encontró el JDK (javac/java). Instala JDK 17 o superior."; exit 1; }

cd "$RAIZ/java" || exit 1
asegurar_env

if [ ! -f "lib/$JAR" ]; then
    info "Descargando $JAR"
    mkdir -p lib
    if command -v curl >/dev/null 2>&1; then curl -fsSL -o "lib/$JAR" "$URL"
    elif command -v wget >/dev/null 2>&1; then wget -q -O "lib/$JAR" "$URL"
    else falla "Se necesita curl o wget para descargar el driver."; exit 1; fi
    [ -s "lib/$JAR" ] || { rm -f "lib/$JAR"; falla "No se pudo descargar el driver desde $URL"; exit 1; }
fi

info "Compilando java/*.java"
javac -encoding UTF-8 -d out *.java || { falla "Falló la compilación (¿JDK 17+?)."; exit 1; }

for c in Conexion Ddl Dml Dql Vdl Dcl Tcl; do
    info "java $c"
    java -cp "out:lib/*" "$c" || { falla "Falló la clase $c"; exit 1; }
done
ok "Java completado."
