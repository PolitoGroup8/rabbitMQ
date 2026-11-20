@echo off
setlocal

if /i "%~1"=="local" goto deploy
if /i "%~1"=="down" goto shutdown

echo Usage: deploy.bat [local^|down]
exit /b 1

:deploy
echo ========================================
echo    TICKETING - RABBITMQ LOCAL DEPLOY
echo ========================================

docker compose up -d

if errorlevel 1 (
    echo [ERROR] RabbitMQ deployment failed.
    exit /b 1
)

echo [SUCCESS] RabbitMQ is running.
echo Management UI: http://localhost:15672
goto end

:shutdown
echo ========================================
echo       TICKETING - RABBITMQ DOWN
echo ========================================

docker compose down -v

if errorlevel 1 (
    echo [ERROR] Failed to stop RabbitMQ.
    exit /b 1
)

echo [SUCCESS] RabbitMQ stopped.
echo [INFO] Containers and volumes removed.

:end
endlocal
