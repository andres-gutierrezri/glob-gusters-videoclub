#!/usr/bin/env bash
# =====================================================================================
# ejecutar-todo.sh — Ejecuta SQL, Python y Java en orden (Linux y macOS)
# =====================================================================================
# Llama a ejecutar-sql.sh, ejecutar-python.sh y ejecutar-java.sh, y se detiene en el
# primer fallo. Acepta --sin-python y --sin-java para omitir un lenguaje.
#
# Uso (desde cualquier carpeta):
#     bash shell/bash/ejecutar-todo.sh [--sin-python] [--sin-java]
# =====================================================================================
set -u
AQUI=$(cd "$(dirname "$0")" && pwd)
. "$AQUI/lib.sh"

uso() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; }
PY=1; JV=1
for arg in "$@"; do
    case "$arg" in
        -h|--help) uso; exit 0 ;;
        --sin-python) PY=0 ;;
        --sin-java) JV=0 ;;
        *) falla "Opción desconocida: $arg"; uso; exit 2 ;;
    esac
done

bash "$AQUI/ejecutar-sql.sh" || exit 1
[ "$PY" -eq 1 ] && { bash "$AQUI/ejecutar-python.sh" || exit 1; }
[ "$JV" -eq 1 ] && { bash "$AQUI/ejecutar-java.sh" || exit 1; }
ok "Todo el proyecto se ejecutó correctamente."
