@echo off
title Desinstalador Servicio - Sincronizacion Shopify
cd /d "%~dp0"

echo.
echo ============================================================
echo   DESINSTALADOR - SINCRONIZACION SHOPIFY CENTRO JAPON
echo ============================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ejecutar como ADMINISTRADOR: clic derecho - Ejecutar como administrador
    pause
    exit /b 1
)
echo [OK] Ejecutando como administrador

set SERVICE_NAME=ShopifySyncCentroJapon
set NSSM=%~dp0tools\nssm\nssm.exe

echo.
echo [..] Verificando si el servicio existe...
sc query %SERVICE_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] El servicio no esta instalado
    pause
    exit /b 0
)

echo [OK] Servicio encontrado

echo.
echo [..] Deteniendo servicio...
if exist "%NSSM%" (
    "%NSSM%" stop %SERVICE_NAME%
) else (
    sc stop %SERVICE_NAME%
)
timeout /t 2 /nobreak >nul
echo [OK] Servicio detenido

echo.
echo [..] Eliminando servicio...
if exist "%NSSM%" (
    "%NSSM%" remove %SERVICE_NAME% confirm
) else (
    sc delete %SERVICE_NAME%
)
echo [OK] Servicio eliminado

echo.
echo ============================================================
echo   DESINSTALACION COMPLETADA
echo ============================================================
echo.
echo El servicio ha sido eliminado correctamente.
echo.
echo NOTA: Los archivos del proyecto y logs NO han sido eliminados.
echo       Si deseas eliminarlos, hazlo manualmente.
echo.
pause
