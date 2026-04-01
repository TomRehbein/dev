---
description: Tests ausfuehren und Fehler analysieren
---

Fuehre die Test-Suite aus und analysiere die Ergebnisse.

1. **Erkenne das Framework** -- jest, vitest, bun test, pytest, cargo test, go test, etc. (schau in package.json / Cargo.toml / etc.)
2. **Fuehre Tests aus** -- mit dem passenden Befehl
3. **Bei Fehlern:**
   - Root Cause pro fehlgeschlagenem Test
   - Konkreter Fix-Vorschlag (ist es ein Test-Fehler oder ein Bug?)
4. **Bei Erfolg:**
   - Pruefe Coverage wenn verfuegbar
   - Schlage fehlende Tests fuer uncovered Pfade vor

$ARGUMENTS
