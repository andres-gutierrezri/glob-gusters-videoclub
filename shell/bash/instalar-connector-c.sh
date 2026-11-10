#!/usr/bin/env bash
# =====================================================================================
# instalar-connector-c.sh — Instala MariaDB Connector/C en macOS (Homebrew)
# =====================================================================================
# El paquete `mariadb` de pip necesita MariaDB Connector/C >= 3.3.1 en el sistema. El que
# trae XAMPP (3.1.x) es demasiado antiguo y `pip install -r requirements.txt` falla con
# "requires MariaDB Connector/C >= 3.3.1". Este script:
#   1. Instala mariadb-connector-c con Homebrew (si no está instalado).
#   2. Exporta LDFLAGS, CPPFLAGS y MARIADB_CONFIG para esta sesión (y para los scripts
#      que lo cargan con `source`, como ejecutar-python.sh).
#   3. Guarda esas mismas variables en ~/.zshrc, sin duplicarlas, para futuras terminales.
# Solo aplica a macOS; en Linux no hace nada (allí se usa `sudo apt install libmariadb-dev`).
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/instalar-connector-c.sh
# =====================================================================================
set -u
. "$(dirname "$0")/lib.sh"

uso() { sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; }
ayuda_si_se_pide "${1:-}"

# Termina con éxito, sin hacer nada, si no es macOS.
if [ "$(uname -s)" != "Darwin" ]; then
    info "No es macOS: se omite la instalación de MariaDB Connector/C con Homebrew."
    info "En Linux: sudo apt install libmariadb-dev build-essential python3-dev (Debian/Ubuntu)."
    exit 0
fi

# ---- 1. Homebrew y mariadb-connector-c ------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    # Homebrew en Apple Silicon e Intel puede no estar en el PATH de un shell no interactivo.
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$b" ] && { eval "$("$b" shellenv)"; break; }
    done
fi
command -v brew >/dev/null 2>&1 || { falla "Homebrew no está instalado (https://brew.sh)."; exit 1; }

info "Instalando mariadb-connector-c con Homebrew"
if brew list --formula mariadb-connector-c >/dev/null 2>&1; then
    ok "mariadb-connector-c ya está instalado."
else
    # `brew install` no tiene la opción -y: instala sin preguntar.
    brew install mariadb-connector-c || { falla "Falló brew install mariadb-connector-c."; exit 1; }
    ok "mariadb-connector-c instalado."
fi

# ---- 2. Variables para esta sesión ----------------------------------------------------
# brew --prefix da /opt/homebrew (Apple Silicon) o /usr/local (Intel).
PREFIJO=$(brew --prefix mariadb-connector-c)
export LDFLAGS="-L$PREFIJO/lib"
export CPPFLAGS="-I$PREFIJO/include"
export MARIADB_CONFIG="$PREFIJO/bin/mariadb_config"
[ -x "$MARIADB_CONFIG" ] || { falla "No se encontró $MARIADB_CONFIG."; exit 1; }
ok "Connector/C $("$MARIADB_CONFIG" --cc_version) (MARIADB_CONFIG=$MARIADB_CONFIG)"

# ---- 3. Variables permanentes en ~/.zshrc ---------------------------------------------
# Solo se agrega cada línea si todavía no existe, para poder repetir el script sin duplicar.
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
agregar_a_zshrc() {
    grep -qxF "$1" "$ZSHRC" || printf '%s\n' "$1" >> "$ZSHRC"
}
agregar_a_zshrc "export LDFLAGS=\"-L$PREFIJO/lib\""
agregar_a_zshrc "export CPPFLAGS=\"-I$PREFIJO/include\""
agregar_a_zshrc "export MARIADB_CONFIG=$PREFIJO/bin/mariadb_config"
ok "Variables guardadas en ~/.zshrc (se cargan en las terminales nuevas; no hace falta 'source')."
