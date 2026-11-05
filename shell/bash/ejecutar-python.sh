#!/usr/bin/env bash
# =====================================================================================
# ejecutar-python.sh — Ejecuta todos los scripts de py/ (Linux y macOS)
# =====================================================================================
# Crea el entorno virtual .venv si no existe, instala requirements.txt y ejecuta, en
# orden: conexion, ddl, dml, dql, vdl, dcl, tcl y conexion_mariabd. Requiere que la base
# ya exista (ejecutar-sql.sh) y Python 3.9+.
#
# Si el paquete `mariadb` no se puede instalar (falta MariaDB Connector/C), se instala
# solo PyMySQL y se omite conexion_mariabd.py con un aviso; el resto funciona igual.
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-python.sh
# =====================================================================================
set -u
. "$(dirname "$0")/lib.sh"

uso() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; }
ayuda_si_se_pide "${1:-}"

cd "$RAIZ" || exit 1
asegurar_env

PYTHON=${PYTHON_BIN:-}
if [ -z "$PYTHON" ]; then
    for c in python3 python; do command -v "$c" >/dev/null 2>&1 && { PYTHON=$c; break; }; done
fi
[ -n "$PYTHON" ] || { falla "No se encontró Python 3.9+ (python3). Define PYTHON_BIN con su ruta."; exit 1; }
"$PYTHON" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' \
    || { falla "Se requiere Python 3.9 o superior."; exit 1; }

if [ ! -x .venv/bin/python ]; then
    info "Creando el entorno virtual .venv"
    "$PYTHON" -m venv .venv || { falla "No se pudo crear .venv (en Debian/Ubuntu: sudo apt install python3-venv)."; exit 1; }
fi
VPY=.venv/bin/python

info "Instalando dependencias (requirements.txt)"
MARIADB_PKG=1
if ! "$VPY" -m pip install --quiet -r requirements.txt; then
    aviso "No se pudo instalar el paquete 'mariadb' (necesita MariaDB Connector/C >= 3.3.1). Se instala solo PyMySQL."
    "$VPY" -m pip install --quiet "PyMySQL>=1.1" || { falla "Falló la instalación de PyMySQL."; exit 1; }
    MARIADB_PKG=0
fi

for m in conexion ddl dml dql vdl dcl tcl conexion_mariabd; do
    if [ "$m" = "conexion_mariabd" ] && [ "$MARIADB_PKG" -eq 0 ]; then
        aviso "Se omite py/conexion_mariabd.py (requiere el paquete 'mariadb')."
        continue
    fi
    info "py/$m.py"
    "$VPY" "py/$m.py" || { falla "Falló py/$m.py"; exit 1; }
done
ok "Python completado."
