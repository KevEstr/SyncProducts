@echo off
title Instalador Servicio - Sincronizacion Shopify Centro Japon
cd /d "%~dp0"

echo.
echo ============================================================
echo   INSTALADOR - SINCRONIZACION SHOPIFY CENTRO JAPON
echo   Ejecuta sync_shopify_products.py todos los dias a las 23:59
echo ============================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ejecutar como ADMINISTRADOR: clic derecho - Ejecutar como administrador
    pause
    exit /b 1
)
echo [OK] Ejecutando como administrador

set PYTHON=
echo [..] Buscando Python...
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command ^
    "$paths = @(); " ^
    "'HKLM','HKCU' | ForEach-Object { " ^
    "  $base = $_+':SOFTWARE\Python\PythonCore'; " ^
    "  if (Test-Path $base) { " ^
    "    Get-ChildItem $base | ForEach-Object { " ^
    "      $ip = $_.PSPath+'\InstallPath'; " ^
    "      if (Test-Path $ip) { " ^
    "        $v = (Get-ItemProperty $ip -ErrorAction SilentlyContinue).'(default)'; " ^
    "        if ($v -and (Test-Path ($v+'python.exe'))) { $paths += $v+'python.exe' } " ^
    "        $ep = (Get-ItemProperty $ip -ErrorAction SilentlyContinue).ExecutablePath; " ^
    "        if ($ep -and (Test-Path $ep)) { $paths += $ep } " ^
    "      } " ^
    "    } " ^
    "  } " ^
    "}; " ^
    "$paths | Select-Object -First 1"`) do (
    if exist "%%P" ( set PYTHON=%%P & goto :python_found )
)

for %%V in (314 313 312 311 310 39 38) do (
    if exist "%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe" (
        set "PYTHON=%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe" & goto :python_found
    )
    if exist "C:\Python%%V\python.exe" (
        set "PYTHON=C:\Python%%V\python.exe" & goto :python_found
    )
    if exist "C:\Program Files\Python%%V\python.exe" (
        set "PYTHON=C:\Program Files\Python%%V\python.exe" & goto :python_found
    )
    if exist "C:\Program Files (x86)\Python%%V\python.exe" (
        set "PYTHON=C:\Program Files (x86)\Python%%V\python.exe" & goto :python_found
    )
    if exist "D:\Python%%V\python.exe" (
        set "PYTHON=D:\Python%%V\python.exe" & goto :python_found
    )
)
if exist "D:\Python\python.exe" ( set "PYTHON=D:\Python\python.exe" & goto :python_found )

echo [..] Buscando python.exe en disco...
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command ^
    "Get-ChildItem 'C:\' -Recurse -Filter 'python.exe' -ErrorAction SilentlyContinue ^| " ^
    "Where-Object { $_.FullName -notmatch 'WindowsApps|store' } ^| " ^
    "Select-Object -First 1 -ExpandProperty FullName"`) do (
    if exist "%%P" ( set PYTHON=%%P & goto :python_found )
)

echo [ERROR] Python no encontrado. Instala desde https://python.org
pause
exit /b 1

:python_found
echo [OK] Python: %PYTHON%

echo.
echo [..] Verificando archivo .env...
if not exist ".env" (
    echo [ERROR] Archivo .env no encontrado
    echo         Copia .env.example a .env y configura las credenciales
    pause
    exit /b 1
)
echo [OK] Archivo .env encontrado

echo.
echo [..] Creando entorno virtual...
if not exist "venv" (
    %PYTHON% -m venv venv
    if %errorlevel% neq 0 ( echo [ERROR] No se pudo crear venv. & pause & exit /b 1 )
)
echo [OK] Entorno virtual listo

echo [..] Instalando dependencias...
venv\Scripts\pip.exe install -r requirements.txt --quiet
if %errorlevel% neq 0 ( echo [ERROR] Fallo instalacion de dependencias. & pause & exit /b 1 )
echo [OK] Dependencias instaladas

echo.
echo [..] Creando directorio de logs...
if not exist "logs" mkdir logs
echo [OK] Directorio logs creado

set NSSM_DIR=%~dp0tools\nssm
set NSSM=%NSSM_DIR%\nssm.exe

if exist "%NSSM%" goto :nssm_found

echo.
echo [..] Descargando NSSM...
mkdir "%NSSM_DIR%" >nul 2>&1
powershell -Command "Invoke-WebRequest -Uri 'https://nssm.cc/release/nssm-2.24.zip' -OutFile '%NSSM_DIR%\nssm.zip' -UseBasicParsing"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo descargar NSSM.
    echo         Descarga manual: https://nssm.cc/download
    echo         Coloca nssm.exe en: %NSSM_DIR%\nssm.exe
    pause & exit /b 1
)
powershell -Command "Expand-Archive -Path '%NSSM_DIR%\nssm.zip' -DestinationPath '%NSSM_DIR%\extracted' -Force"
copy /y "%NSSM_DIR%\extracted\nssm-2.24\win64\nssm.exe" "%NSSM%" >nul
del "%NSSM_DIR%\nssm.zip" >nul 2>&1
rmdir /s /q "%NSSM_DIR%\extracted" >nul 2>&1

:nssm_found
echo [OK] NSSM listo

set SERVICE_NAME=ShopifySyncCentroJapon
set APP_DIR=%~dp0
if "%APP_DIR:~-1%"=="\" set APP_DIR=%APP_DIR:~0,-1%
set PYTHON_EXE=%APP_DIR%\venv\Scripts\python.exe
set APP_SCRIPT=%APP_DIR%\service_wrapper.py

echo.
echo ============================================================
echo   CREDENCIALES DE WINDOWS
echo   El servicio necesita correr bajo tu usuario para acceder
echo   a rutas de red y variables de entorno.
echo ============================================================
echo.
set /p SVC_USER="   Usuario (ej: Administrador o dominio\usuario): "
set /p SVC_PASS="   Contrasena: "
echo.

echo [..] Configurando servicio...
"%NSSM%" stop %SERVICE_NAME% >nul 2>&1
"%NSSM%" remove %SERVICE_NAME% confirm >nul 2>&1
"%NSSM%" install %SERVICE_NAME% "%PYTHON_EXE%"
"%NSSM%" set %SERVICE_NAME% AppParameters "\"%APP_SCRIPT%\""
"%NSSM%" set %SERVICE_NAME% DisplayName "Sincronizacion Shopify - Centro Japon"
"%NSSM%" set %SERVICE_NAME% Description "Sincroniza productos a Shopify todos los dias a las 23:59"
"%NSSM%" set %SERVICE_NAME% AppDirectory "%APP_DIR%"
"%NSSM%" set %SERVICE_NAME% ObjectName "%SVC_USER%" "%SVC_PASS%"
"%NSSM%" set %SERVICE_NAME% Start SERVICE_AUTO_START
"%NSSM%" set %SERVICE_NAME% AppRestartDelay 10000
"%NSSM%" set %SERVICE_NAME% AppStdout "%APP_DIR%\logs\service_out.log"
"%NSSM%" set %SERVICE_NAME% AppStderr "%APP_DIR%\logs\service_err.log"
"%NSSM%" set %SERVICE_NAME% AppRotateFiles 1
"%NSSM%" set %SERVICE_NAME% AppRotateBytes 10485760
echo [OK] Servicio registrado

echo.
echo [..] Iniciando servicio...
"%NSSM%" start %SERVICE_NAME%
timeout /t 3 /nobreak >nul
"%NSSM%" status %SERVICE_NAME%

echo.
echo.
echo ============================================================
echo   INSTALACION COMPLETADA
echo ============================================================
echo.
echo   Servicio: %SERVICE_NAME%
echo   Horario: Todos los dias a las 23:59 (11:59 PM)
echo   Script: sync_shopify_products.py
echo.
echo   Logs del servicio:
echo     %APP_DIR%\logs\service_out.log
echo     %APP_DIR%\logs\service_err.log
echo.
echo   Logs de sincronizacion:
echo     %APP_DIR%\logs\service.log
echo     %APP_DIR%\sync.log
echo.
echo   Gestionar servicio:
echo     sc start %SERVICE_NAME%
echo     sc stop  %SERVICE_NAME%
echo     sc query %SERVICE_NAME%
echo.
echo   Para desinstalar:
echo     sc stop %SERVICE_NAME%
echo     sc delete %SERVICE_NAME%
echo.
pause
