@echo off
cd /d "%~dp0backend"
echo Iniciando Synapse Health Control Center en http://127.0.0.1:4178 ...
start "" "http://127.0.0.1:4178"
node admin/server.mjs
pause
