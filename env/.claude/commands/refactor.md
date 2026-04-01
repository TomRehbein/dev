---
description: Refactoring-Analyse und Vorschlaege fuer eine Datei oder Modul
agent: prepare
---

Analysiere den folgenden Code auf Refactoring-Moeglichkeiten:

$ARGUMENTS

Pruefe auf:
1. **Komplexitaet** -- Funktionen die zu viel tun, tiefe Verschachtelung, hohe kognitive Last
2. **DRY** -- Duplizierter Code der extrahiert oder abstrahiert werden kann
3. **Naming** -- Unklare, irrefuehrende oder inkonsistente Namen
4. **Abstraktion** -- Fehlende Abstraktion (Code-Duplizierung) oder uebertriebene Abstraktion (YAGNI-Verletzung)
5. **Error Handling** -- Inkonsistente, verschluckte oder fehlende Fehlerbehandlung
6. **Types (TS)** -- `any`-Types, fehlende Interfaces, schwache oder redundante Typisierung

Priorisiere nach Impact (hoch/mittel/nit) und zeige konkrete Code-Beispiele fuer die vorgeschlagenen Aenderungen.
