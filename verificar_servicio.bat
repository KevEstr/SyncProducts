@echo off
title Estado del Servicio Shopify
cd /d "%~dp0"

set SERVICE_NAME=ShopifySyncCentroJapon

echo.
echo ============================================================
echo   ESTADO DEL SERVICIO SHOPIFY
echo ============================================================
echo.

sc query %SERVICE_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] El servicio NO esta instalado
    echo.
    echo Para instalarlo, ejecuta como administrador:
    echo   instalar_servicio_shopify.bat
    echo.
    pause
    exit /b 1
)

echo Estado del servicio:
echo.
sc query %SERVICE_NAME%

echo.
echo ============================================================
echo   LOGS RECIENTES
echo ============================================================
echo.

if exist "logs\service.log" (
    echo --- Ultimas 20 lineas de service.log ---
    powershell -Command "Get-Content 'logs\service.log' -Tail 20"
    echo.
) else (
    echo [!] No se encontro logs\service.log
    echo.
)

if exist "sync.log" (
    echo --- Ultimas 20 lineas de sync.log ---
    powershell -Command "Get-Content 'sync.log' -Tail 20"
    echo.
) else (
    echo [!] No se encontro sync.log
    echo.
)

echo.
echo ============================================================
echo   COMANDOS UTILES
echo ============================================================
echo.
echo   Iniciar:    sc start %SERVICE_NAME%
echo   Detener:    sc stop %SERVICE_NAME%
echo   Reiniciar:  sc stop %SERVICE_NAME% ^& sc start %SERVICE_NAME%
echo   Estado:     sc query %SERVICE_NAME%
echo.
pause
