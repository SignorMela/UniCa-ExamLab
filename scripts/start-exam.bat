@echo off
REM ==============================================================================
REM UniCa-ExamLab: Windows Exam Launch Script
REM ==============================================================================
setlocal EnableDelayedExpansion

echo ==========================================================
echo      Universita degli Studi di Cagliari - UniCa-ExamLab   
echo         Ambiente d'Esame: VS Code C/C++ + SEB            
echo ==========================================================

REM 1. Navigate to project root directory
cd /d "%~dp0\.."

REM 2. Verify that Docker is installed and running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [-] ERRORE: Docker non sembra essere in esecuzione.
    echo     Avvia Docker Desktop e riprova.
    pause
    exit /b 1
)
echo [+] Docker e' attivo.

REM 3. Ensure student submission directory exists
if not exist "student_submission" (
    mkdir student_submission
)
echo [+] Cartella elaborato 'student_submission' pronta.

REM 4. Launch Docker container in background
echo [*] Avvio del container VS Code per l'esame...
docker compose up -d

echo [+] Container avviato su http://localhost:8080.
echo [+] Tutti i file sono salvati in: %CD%\student_submission

REM 5. Launch Safe Exam Browser
set SEB_FILE="%CD%\seb\exam_config.seb"

if exist %SEB_FILE% (
    echo [*] Avvio di Safe Exam Browser...
    start "" %SEB_FILE%
) else (
    echo [-] File di configurazione SEB non trovato in seb\exam_config.seb.
)

echo ==========================================================
echo  A fine esame, per spegnere l'ambiente esegui:
echo      docker compose down
echo ==========================================================
pause
