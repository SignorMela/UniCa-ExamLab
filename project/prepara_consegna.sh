#!/usr/bin/env bash
# ==============================================================================
# UniCa-ExamLab: Student exam submission package script for Moodle
# ==============================================================================
set -e

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WORKSPACE_DIR"

OUTPUT_ZIP="consegna_esame.zip"
rm -f "$OUTPUT_ZIP"

echo "[*] Creazione archivio ZIP dell'intero progetto in corso..."
# Exclude IDE configuration directory (.vscode), packaging script, and the output archive itself
zip -r -FS "$OUTPUT_ZIP" . -x "$OUTPUT_ZIP" -x ".vscode/*" -x ".vscode" -x "prepara_consegna.sh" > /dev/null

echo ""
echo "=========================================================="
echo "CONTENUTO VERIFICATO ARCHIVIO ZIP (Nomi e Dimensioni):"
echo "=========================================================="
unzip -l "$OUTPUT_ZIP"
echo ""
echo "=========================================================="
echo "[+] Archivio pronto: $(pwd)/$OUTPUT_ZIP"
echo "[+] Ora puoi andare su Moodle (elearning.unica.it) e caricare questo file!"
echo "=========================================================="
