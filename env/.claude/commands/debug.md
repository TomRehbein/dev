---
description: Strukturiertes Debugging mit Root-Cause-Analyse
---

Starte eine strukturierte Debugging-Session fuer folgendes Problem:

$ARGUMENTS

Workflow:
1. **Reproduzieren** -- Beschreibe wie das Problem reproduziert werden kann
2. **Isolieren** -- Grenze den Fehler systematisch ein (binary search im Code)
3. **Root Cause** -- Identifiziere die tatsaechliche Ursache (nicht nur das Symptom)
4. **Fix** -- Implementiere den minimalen Fix
5. **Verify** -- Stelle sicher dass der Fix das Problem loest ohne neue einzufuehren
6. **Prevent** -- Schlage Tests oder Guards vor die Regression verhindern

Arbeite jeden Schritt explizit durch bevor du zum naechsten gehst.
