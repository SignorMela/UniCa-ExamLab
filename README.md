# UniCa-ExamLab: Ambiente d'Esame C/C++ Moderno, Sicuro e Portabile

Proposta tecnica e prototipo open-source indipendente per la modernizzazione e la sicurezza degli esami pratici di programmazione presso l'**Università degli Studi di Cagliari**.

Il progetto integra un ambiente **Visual Studio Code C/C++** completo e standardizzato con la modalità Kiosk di **Safe Exam Browser (SEB)**, adottando un'architettura **a calcolo locale** che non sovraccarica l'infrastruttura server d'Ateneo.

---

## Motivazione e Vantaggi per UniCa

1. **Nessun sovraccarico dei server centrali (Soluzione al problema delle risorse)**:
   * Nei laboratori o negli esami con molti studenti (50-200 contemporaneamente), eseguire decine di ambienti completi di compilazione su un singolo server richiede macchine dedicate costose e rischia rallentamenti o crash.
   * **UniCa-ExamLab** sfrutta le risorse CPU/RAM dei singoli computer (fissi di laboratorio o portatili degli studenti): ogni macchina esegue la propria istanza Docker locale.
2. **Ambiente di sviluppo professionale e uniforme**:
   * Gli studenti lavorano su **Visual Studio Code** (tramite `code-server` via browser), con compilatore C standard (`gcc`), debugger (`gdb`), estensioni C/C++ e formattatore preconfigurati.
   * Nessun problema di incompatibilità di sistema operativo o versioni di compilatori tra studenti.
3. **Lockdown rigoroso contro frodi e comunicazioni non autorizzate**:
   * L'accesso avviene tramite **Safe Exam Browser**, che blocca l'intero sistema operativo (modalità Kiosk) impedendo l'uso di altre finestre, app di messaggistica o browser esterni.
   * La navigazione è consentita **esclusivamente** su:
     * `https://elearning.unica.it` (Moodle UniCa per traccia e consegna)
     * `https://idp.unica.it` (Accesso SSO Shibboleth UniCa)
     * `http://localhost:8080` (VS Code locale)
     * **Qualsiasi altro sito web o indirizzo IP è categoricamente bloccato**.
4. **Sicurezza interna al container**:
   * Marketplace delle estensioni di VS Code **completamente disabilitato** (`--disable-marketplace`).
   * Rimozione di `sudo` e `apt` all'interno del container: lo studente non può installare pacchetti o manomettere il container dal terminale integrato.
5. **Consegna facile su Moodle**:
   * Il codice sorgente risiede in tempo reale sul disco del PC ospitante nella cartella `student_submission/`.
   * A fine prova lo studente prepara l'archivio verificato (`consegna_esame.zip`) direttamente da VS Code con un clic e lo carica sulla pagina Moodle dell'esame aperta in SEB.

---

## Struttura del Progetto

```
UniCa-ExamLab/
├── Dockerfile                  # Immagine Docker unificata C/C++ (Windows/macOS/Linux)
├── docker-compose.yml          # Orchestrazione container locale (porta 8080, volumi)
├── docker-entrypoint.sh        # Entrypoint del container con opzioni di sicurezza d'esame
├── settings.json               # Impostazioni predefinite code-server (auto-save, formattazione)
├── project/                    # Template d'esame master (main.c, .vscode/tasks.json, launch.json)
├── student_submission/         # Spazio di lavoro montato nel container (salvato sul disco host)
├── seb/
│   ├── exam_config.seb         # File pronto per Safe Exam Browser (apre localhost:8080)
│   └── seb_settings.plist      # Configurazione sorgente XML per SEB
├── scripts/
│   ├── start-exam.bat          # Script di avvio per Windows
│   └── start-exam.sh           # Script di avvio per macOS e Linux
├── LICENSE                     # Licenza MIT
├── .gitignore                  # Esclusioni file temporanei, compilati e archivi zip
└── README.md
```

---

## Istruzioni per l'Uso

### Prerequisiti
1. **Docker Desktop** (o Docker Engine) installato e avviato sul computer.
2. **Safe Exam Browser (SEB)** installato:
   * [Download ufficiale per Windows e macOS](https://safeexambrowser.org/download_en.html)

---

### Svolgimento dell'Esame (Windows, macOS, Linux)

1. **Avvio dell'Esame**:
   * **Windows**: doppio clic su `scripts\start-exam.bat` (oppure da PowerShell/CMD: `.\scripts\start-exam.bat`).
   * **macOS / Linux**: apri il terminale nella cartella ed esegui:
     ```bash
     ./scripts/start-exam.sh
     ```
   * Lo script verifica Docker, avvia il container in background e lancia automaticamente Safe Exam Browser direttamente sulla schermata di **VS Code** (`http://localhost:8080`).

2. **Programmazione**:
   * Scrivi il codice in `main.c` (o crea nuovi file).
   * I file si salvano automaticamente e risiedono sul disco locale nella cartella `student_submission`.
   * Puoi compilare ed eseguire con il pulsante **Run Code** in alto a destra o dal terminale integrato con `gcc`.

3. **Preparazione Consegna**:
   * Direttamente dentro VS Code:
     * Vai nel menu: **Terminal -> Run Task... -> Prepara e Verifica Consegna Moodle (.ZIP)**  
     *(oppure digita `./prepara_consegna.sh` nel terminale).*
   * Verrà creato `consegna_esame.zip` (escludendo `.vscode`) e a video comparirà la verifica con l'elenco dei file e le loro dimensioni.
   * Carica `consegna_esame.zip` su Moodle.

4. **Chiusura**:
   * Esci da Safe Exam Browser.
   * Per spegnere il container Docker, esegui:
     ```bash
     docker compose down
     ```

---

## Note per il Docente

UniCa-ExamLab è progettato per essere estremamente semplice da configurare da parte del corpo docente:

1. **Personalizzazione della Traccia**:
   * I file base forniti allo studente risiedono nella cartella `project/` (`main.c`, `main.cpp`, eventuali file header `.h` o dataset).
   * Qualsiasi file inserito dal docente in `project/` viene automaticamente distribuito all'avvio del container se lo spazio di lavoro dello studente è nuovo.

2. **Sicurezza e Password di Safe Exam Browser**:
   * Il file `seb/exam_config.seb` è già impostato con `startURL` su `http://localhost:8080`, blocco di download, blocco di combinazioni di tasti di sistema e whitelist di rete limitata ai domini UniCa.
   * Il docente può aprire `seb/seb_settings.plist` o usare lo strumento di configurazione di SEB per impostare la **password di uscita dell'esame** (Quit Password) e la **password di sblocco configurazione**.

3. **Valutazione delle Consegne**:
   * I file consegnati dagli studenti su Moodle sono archivi `.zip` standard contenenti esclusivamente i sorgenti, pronti per essere scompattati ed esaminati manualmente o tramite script di correzione automatica.

---

## Gestione di Docker nei Laboratori d'Ateneo

Nei laboratori didattici con PC fissi gestiti da UniCa (Windows o Linux):
1. **Docker Service**: Il demone Docker viene eseguito come servizio di sistema amministrato dall'ufficio tecnico.
2. **Account Studente Limitato**: Lo studente accede al PC con un account `studente` standard, senza privilegi amministrativi (`non-admin`) e senza appartenere al gruppo `docker`.
3. **Avvio Automatico**: All'accesso dello studente o tramite script di logon, il container e Safe Exam Browser si avviano automaticamente.
4. Lo studente non ha a disposizione né l'interfaccia di Docker Desktop né il comando `docker` da linea di comando: l'ambiente è completamente blindato e trasparente.

---

## Evoluzioni Future (Roadmap)

1. **Integrazione Moodle & Safe Exam Browser**:
   * Creazione di un'attività o blocco dedicato su Moodle con collegamento diretto a VS Code (`http://localhost:8080`), per consentire allo studente di passare comodamente dalla traccia su Moodle all'ambiente di programmazione all'interno di SEB.
2. **Supporto ad altri linguaggi di programmazione**:
   * Predisposizione di immagini container dedicate per altri corsi d'Ateneo (es. Python, JavaScript, Java), dotate dei rispettivi interpreti, runtime ed estensioni ufficiali preconfigurate.
3. **Modalità Cluster Server / Cloud**:
   * Qualora l'Ateneo desideri in futuro allestire un'infrastruttura server centralizzata, le immagini container potranno essere erogate direttamente su cluster Kubernetes o cloud istituzionale.

---

## Autore

* **Federico Farci**
  * Ideazione dell'architettura e sviluppo del prototipo indipendente per la modernizzazione, la sicurezza e la portabilità degli esami pratici di programmazione.

---

## Licenza

Rilasciato con licenza [MIT](LICENSE) — Copyright (c) 2026 Federico Farci.
