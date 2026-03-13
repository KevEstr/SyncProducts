@echo off
title Prueba del Scheduler (CTRL+C para detener)
cd /d "%~dp0"

echo.
echo ============================================================
echo   PRUEBA DEL SCHEDULER
echo   Presiona CTRL+C para detener
echo ============================================================
echo.

if not exist "venv\Scripts\python.exe" (
    echo [ERROR] Entorno virtual no encontrado
    echo         Ejecuta primero: instalar_servicio_shopify.bat
    pause
    exit /b 1
)

if not exist ".env" (
    echo [ERROR] Archivo .env no encontrado
    echo         Copia .env.example a .env y configura las credenciales
    pause
    exit /b 1
)

echo [..] Iniciando service_wrapper.py en modo prueba...
echo.
echo NOTA: Este script mostrara cuando esta programada la proxima
echo       ejecucion. Para probar inmediatamente, usa probar_servicio.bat
echo.
venv\Scripts\python.exe service_wrapper.py

pause
