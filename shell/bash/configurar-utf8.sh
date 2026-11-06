#!/usr/bin/env bash
# =====================================================================================
# configurar-utf8.sh — Configura Bash para imprimir tildes, ñ y símbolos (UTF-8)
# =====================================================================================
# Para que el cambio quede en la terminal actual hay que cargarlo con `source`:
#     source shell/bash/configurar-utf8.sh
# Si se ejecuta normalmente (./configurar-utf8.sh) las variables se pierden al terminar.
#
# Configura: LANG/LC_ALL con una configuración regional UTF-8 disponible (si la actual ya
# lo es, no la toca) y PYTHONIOENCODING. Funciona en Linux, macOS y Git Bash (Windows).
# =====================================================================================

_utf8_actual=$(locale charmap 2>/dev/null)

if [ "$_utf8_actual" != "UTF-8" ]; then
    _utf8_nueva=""
    for _l in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8 es_ES.UTF-8 es_ES.utf8 es_CO.UTF-8; do
        if locale -a 2>/dev/null | grep -qix "$_l"; then _utf8_nueva=$_l; break; fi
    done
    # Git Bash/MSYS2 y macOS aceptan en_US.UTF-8 aunque `locale -a` no lo liste
    [ -z "$_utf8_nueva" ] && _utf8_nueva="en_US.UTF-8"
    export LANG="$_utf8_nueva" LC_ALL="$_utf8_nueva"
fi
export PYTHONIOENCODING=utf-8

echo "[OK] Terminal en UTF-8 (LANG=$LANG, codificación: $(locale charmap 2>/dev/null)). Prueba: áéíóú ñ Ñ ü ¿¡ €"

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "[AVISO] Se ejecutó sin 'source': el cambio solo valió para este proceso."
    echo "        Use:  source shell/bash/configurar-utf8.sh"
fi
unset _utf8_actual _utf8_nueva _l
