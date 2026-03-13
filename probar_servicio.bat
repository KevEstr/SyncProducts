@echo off
title Prueba de Sincronizacion Shopify
cd /d "%~dp0"

echo.
echo ============================================================
echo   PRUEBA DE SINCRONIZACION SHOPIFY
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

echo [..] Ejecutando sincronizacion de prueba...
echo.
venv\Scripts\python.exe sync_shopify_products.py

echo.
echo ============================================================
echo   PRUEBA COMPLETADA
echo ============================================================
echo.
echo Revisa el archivo sync.log para ver los detalles
echo.
pause
