@echo off
rem ====================================================================================
rem configurar-utf8.cmd - Configura CMD para imprimir tildes, enie y simbolos (UTF-8)
rem ====================================================================================
rem Para que el cambio quede en la ventana actual hay que cargarlo con CALL:
rem     call shell\cmd\configurar-utf8.cmd
rem Si se hace doble clic o se ejecuta en otra ventana, la pagina de codigos solo cambia
rem dentro de ese proceso. (Este script no usa SETLOCAL a proposito.)
rem
rem Configura: pagina de codigos 65001 y PYTHONIOENCODING=utf-8.
rem Nota: la ventana debe usar una fuente TrueType (Consolas, Cascadia Mono, Lucida Console).
rem ====================================================================================
chcp 65001 >nul
set "PYTHONIOENCODING=utf-8"

echo [OK] Consola en UTF-8 (pagina de codigos 65001).
echo Prueba: áéíóú ñ Ñ ü ¿¡ €
echo Si ves simbolos raros, cambia la fuente de la ventana a Consolas o Cascadia Mono.
