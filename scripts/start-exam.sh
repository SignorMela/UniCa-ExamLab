#!/usr/bin/env bash
# ==============================================================================
# UniCa-ExamLab: Exam Launch Script (macOS / Linux)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "      Università degli Studi di Cagliari - UniCa-ExamLab   "
echo "        Ambiente d'Esame: VS Code C/C++ + SEB            "
echo "=========================================================="

# 1. Check if Docker daemon is running (auto-start on macOS if installed)
if ! docker info >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]] && [ -d "/Applications/Docker.app" ]; then
        echo "[*] Docker non è attivo. Avvio automatico di Docker Desktop..."
        open -a Docker
        echo -n "[*] Attesa che il motore Docker sia pronto"
        while ! docker info >/dev/null 2>&1; do
            echo -n "."
            sleep 2
        done
        echo " -> Docker è attivo!"
    else
        echo "[-] ERRORE: Docker non sembra essere in esecuzione."
        echo "    Avvia Docker Desktop (o il servizio docker) e riprova."
        exit 1
    fi
else
    echo "[+] Docker è già attivo."
fi

# 2. Ensure student submission directory exists
mkdir -p student_submission
chmod 777 student_submission 2>/dev/null || true
echo "[+] Cartella elaborato 'student_submission' pronta."

# 3. Launch VS Code container in background
echo "[*] Avvio dell'ambiente VS Code..."
docker compose up -d

# 4. Wait for code-server to become responsive on port 8080
echo -n "[*] Attesa disponibilità di VS Code"
for i in {1..30}; do
    if curl -s -I http://localhost:8080 >/dev/null 2>&1; then
        echo " -> Pronto!"
        break
    fi
    echo -n "."
    sleep 1
done

echo "[+] Ambiente VS Code C attivo su: http://localhost:8080"
echo "[+] I file di lavoro sono salvati in: $(pwd)/student_submission"

# 5. Launch Safe Exam Browser
SEB_FILE="$(pwd)/seb/exam_config.seb"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "/Applications/Safe Exam Browser.app" ]; then
        echo "[*] Apertura di Safe Exam Browser..."
        open "$SEB_FILE"
    else
        echo "[i] Safe Exam Browser non è installato in /Applications."
        echo "    Puoi testare VS Code dal browser aprendo: http://localhost:8080"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v seb >/dev/null 2>&1; then
        echo "[*] Apertura di Safe Exam Browser su Linux..."
        seb "$SEB_FILE" &
    else
        echo "[i] Safe Exam Browser non trovato nel PATH."
        echo "    Puoi testare l'ambiente aprendo nel browser: http://localhost:8080"
    fi
fi

echo "=========================================================="
echo " A fine esame, per spegnere l'ambiente esegui:"
echo "     docker compose down"
echo "=========================================================="
