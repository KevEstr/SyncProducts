@echo off
title Diagnostico de Conexion a la API
cd /d "%~dp0"

echo.
echo ============================================================
echo   DIAGNOSTICO DE CONEXION A LA API
echo ============================================================
echo.

set API_HOST=186.97.200.50
set API_PORT=8090

echo [1] Probando PING al servidor API...
ping -n 4 %API_HOST%
echo.

echo [2] Probando conexion al puerto %API_PORT%...
powershell -Command "Test-NetConnection -ComputerName %API_HOST% -Port %API_PORT% -InformationLevel Detailed"
echo.

echo [3] Intentando hacer request HTTP a la API...
if not exist "venv\Scripts\python.exe" (
    echo [!] Entorno virtual no encontrado, usando curl...
    curl -v -m 30 "http://%API_HOST%:%API_PORT%/api/inventario?api_key=cj2026-K9mPxLw8Q2nR5jT3bY7dH0AC1fE4"
) else (
    venv\Scripts\python.exe -c "import requests; import time; start=time.time(); resp=requests.get('http://%API_HOST%:%API_PORT%/api/inventario?api_key=cj2026-K9mPxLw8Q2nR5jT3bY7dH0AC1fE4', timeout=30); print(f'Status: {resp.status_code}'); print(f'Tiempo: {time.time()-start:.2f}s'); print(f'Productos: {len(resp.json().get(\"data\", []))}')"
)
echo.

echo [4] Verificando ruta de red...
tracert -h 10 %API_HOST%
echo.

echo ============================================================
echo   DIAGNOSTICO COMPLETADO
echo ============================================================
echo.
echo Si hay errores de timeout o conexion rechazada:
echo   - Verifica que la API este corriendo
echo   - Verifica firewall del servidor remoto
echo   - Verifica que no haya VPN desconectada
echo.
pause
