@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0test\load\probar_carga_interactiva.ps1"
pause
