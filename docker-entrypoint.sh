#!/usr/bin/env bash
set -e
shopt -s dotglob

TARGETDIR="$VSCODE_SRV_DIR/workspace"
PORT="${EXAMLAB_LISTEN_PORT:-8080}"

# Parse arguments
for ARGUMENT in "$@"; do
    if [ "$ARGUMENT" == "--disable-marketplace" ] ; then
        export EXTENSIONS_GALLERY='{"serviceUrl": ""}'
        echo "[UniCa-ExamLab] Extension marketplace disabled for exam security."
    fi
    if [ "$ARGUMENT" == "--load-example" ] ; then
        # Populate starter project only if student workspace is empty
        if [ ! -f "$VSCODE_SRV_DIR/workspace/main.c" ] && [ ! -f "$VSCODE_SRV_DIR/workspace/main.cpp" ]; then
            echo "[UniCa-ExamLab] Initializing workspace with exam C/C++ template..."
            mkdir -p "$VSCODE_SRV_DIR/workspace/.vscode/"
            cp -R /example_project/* "$VSCODE_SRV_DIR/workspace/" 2>/dev/null || true
            touch "$VSCODE_SRV_DIR/workspace/.vscode/.startup" 2>/dev/null || true
        fi
    fi
    if [ -d "$ARGUMENT" ] ; then
        TARGETDIR="$ARGUMENT"
    fi
done

echo "[UniCa-ExamLab] Starting VS Code (code-server) on port ${PORT}..."

exec \
code-server \
--disable-update-check \
--auth none \
--bind-addr 0.0.0.0:"${PORT}" \
--user-data-dir "$VSCODE_SRV_DIR/data" \
--extensions-dir "$VSCODE_SRV_DIR/extensions" \
--disable-telemetry \
"$TARGETDIR"
