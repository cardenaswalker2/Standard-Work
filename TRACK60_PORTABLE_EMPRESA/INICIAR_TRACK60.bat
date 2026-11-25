@echo off
title TRACK60 V2 - Torre de Control Corporativa - Grupo Darnel
chcp 65001 >nul
color 0B
setlocal EnableDelayedExpansion

:MENU
cls
echo ================================================================================
echo        GRUPO DARNEL - STANDARD WORK DIGITAL - TRACK60 V2
echo        Lanzador Ejecutivo y Servidor Portable Empresarial
echo ================================================================================
echo.
echo   Estado del paquete:
if exist "%~dp0app_web\index.html" (
    echo     [OK] Aplicacion Web V2 lista
) else (
    echo     [!] Falta carpeta app_web
)
if exist "%~dp0TRACK60_V2_RELEASE.apk" (
    echo     [OK] Instalador Android APK V2 listo
) else (
    echo     [!] Falta TRACK60_V2_RELEASE.apk
)
if exist "%~dp0PRESENTACION_EJECUTIVA_TRACK60.html" (
    echo     [OK] Presentacion Ejecutiva lista
) else (
    echo     [!] Falta Presentacion Ejecutiva
)
echo.
echo --------------------------------------------------------------------------------
echo   Selecciona una opcion:
echo.
echo     [1] Iniciar Servidor Portable + App Web + Codigo QR para Celulares
echo     [2] Abrir Presentacion Ejecutiva (Gerencia / Direccion)
echo     [3] Abrir Propuesta Tecnica de Arquitectura e Infraestructura TI
echo     [4] Abrir App en la Nube (Render Produccion)
echo     [5] Mostrar Ubicacion del Instalador Android (.APK)
echo     [0] Salir
echo.
echo --------------------------------------------------------------------------------
set "OPCION="
set /p OPCION="  Ingresa tu opcion [1-5, Enter = 1]: "
if "%OPCION%"=="" set "OPCION=1"

if "%OPCION%"=="1" goto START_SERVER
if "%OPCION%"=="2" goto OPEN_PRES
if "%OPCION%"=="3" goto OPEN_TI
if "%OPCION%"=="4" goto OPEN_CLOUD
if "%OPCION%"=="5" goto OPEN_APK
if "%OPCION%"=="0" exit /b 0
goto MENU

:START_SERVER
cls
echo ================================================================================
echo   INICIANDO SERVIDOR CORPORATIVO TRACK60 V2...
echo ================================================================================
echo.
echo   [1/2] Verificando motor de ejecucion (Python / PowerShell)...
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo   [2/2] Motor Python detectado. Abriendo consola de conexion y QR...
    python "%~dp0iniciar_track60.py"
    goto AFTER_SERVER
)
where py >nul 2>nul
if %errorlevel% equ 0 (
    echo   [2/2] Launcher Python (py) detectado. Abriendo consola de conexion y QR...
    py "%~dp0iniciar_track60.py"
    goto AFTER_SERVER
)
echo   [2/2] Usando servidor HTTP nativo de Windows PowerShell (sin permisos admin)...
powershell -ExecutionPolicy Bypass -File "%~dp0servidor_powershell.ps1"

:AFTER_SERVER
echo.
echo   Servidor detenido.
pause
goto MENU

:OPEN_PRES
start "" "%~dp0PRESENTACION_EJECUTIVA_TRACK60.html"
goto MENU

:OPEN_TI
start "" "%~dp0PROPUESTA_TECNICA_TI_DARNEL.html"
goto MENU

:OPEN_CLOUD
start "" "https://track60-1.onrender.com"
goto MENU

:OPEN_APK
explorer /select,"%~dp0TRACK60_V2_RELEASE.apk"
goto MENU