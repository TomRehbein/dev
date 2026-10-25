---
description: Jira-Ticket abschliessen: Doku-Kommentar schreiben, Status auf QA, Zeit in Troi buchen
---

Schliesse die Arbeit am aktuellen Jira-Ticket ab: Dokumentation als Jira-Kommentar, Statuswechsel nach QA, Zeitbuchung in Troi.

Zusaetzliche Hinweise (optional): $ARGUMENTS

## 0. Ticket ermitteln und Daten sammeln

- Key in $ARGUMENTS -> dieses Ticket nehmen.
- Sonst: Ticket aus dem Session-Kontext uebernehmen (Session lief i.d.R. mit `/ticket <KEY>`). Key + Titel kurz bestaetigen.
- Nicht ermittelbar -> JQL `assignee = currentUser() AND statusCategory = "In Progress" ORDER BY updated DESC`; 1 Treffer -> nehmen, mehrere -> Liste zeigen und nachfragen, nicht raten.

Ticket frisch aus Jira lesen (read-only): Beschreibung, Kommentare, Status, Custom Field **"Troi"** (`customfield_10700`). Daraus brauche ich spaeter: Sprache des Tickets, Troi-Nummer, evtl. angegebene Zeit/Aufwand.

Im Repo (wie in `/ticket` ermittelt) pruefen, was tatsaechlich umgesetzt wurde — der Kommentar basiert auf echtem Code, nicht auf Vermutungen.

## 1. Jira-Kommentar schreiben

Zuerst den `unslop` skill laden und befolgen.

Der Kommentar ist sachlich und informativ, aber leicht verstaendlich und schnell zum Punkt (ADHS-freundlich: kurze Absaetze, Bullets, das Wesentliche fett, kein Filler, keine Floskeln).

Struktur (sinngemaess, an Ticket anpassen):
- **Was:** 1-2 Saetze — was das Ticket wollte und was umgesetzt wurde
- **Wie:** Loesungsansatz kurz; relevante Aenderungen mit Repo-Dateien
- **Verify:** wie verifiziert wurde (Tests, manuell, Lint, ...)
- **Fuer QA:** worauf beim Pruefen zu achten ist, falls es daran hakt
- **Offen:** bewusst nicht Umgesetztes / Folge-Tickets, nur falls vorhanden

Regeln:
- **Gleiche Sprache wie das Ticket selbst.** Deutsch -> deutsch, Englisch -> englisch. Tech-Begriffe bleiben englisch.
- Als **Markdown** formatieren.
- **Keine lokalen Pfade** (`/Users/...`, `~/work/...` o.ae.). Nur Dateien referenzieren, die im Repo liegen, committed sind und von der Repo-Wurzel aus erreichbar sind (z.B. `src/foo/bar.ts`).
- Keine Erwaehnung von KI/Session, keine internen Codierungen.

## 2. Status auf QA

- Verfuegbare Transitions des Tickets pruefen und die Transition auf den QA-Status ausfuehren. Exakte Statusbezeichnung (z.B. "QA", "Ready for QA") aus den Transitions nehmen, **nicht raten**.
- Keine passende Transition oder Fehler -> mir melden. Kommentar und Buchung trotzdem fertig machen, den Statuswechsel klaere ich dann manuell.

## 3. Zeit in Troi buchen

Den `troi` skill laden und dessen Ablauf befolgen (K-Nummer ermitteln -> `troi check` -> `troi book`).

- **Bereits Gebuchtes pruefen (vor jeder Buchung):** `troi week`/`troi month --json` pruefen, ob fuer dieses Ticket schon Zeit gebucht wurde. Der interne Kommentar enthaelt laut Konvention den Ticket-Key; falls dort nicht sichtbar, ueber den externen Kommentar (Ticket-Titel) matchen. Zeitraum: rueckwirkend ab Beginn der Arbeit am Ticket (z.B. aktueller Monat, bei Bedarf weiter zurueck).
  - Schon Zeit gebucht -> mir melden, wie viel bereits gebucht ist (Stunden + Datum), und **nachfragen, wie viel jetzt gebucht werden soll**. Nicht autonom buchen — die Schaetzung unten dient dann nur als Orientierung.
  - Nichts gebucht -> wie unten beschrieben weitermachen.
- **Aufwand:** angegebene Zeit im Ticket nehmen (Beschreibung, Custom Field, Kommentare — z.B. "Aufwand: 3h"; neueste Angabe gewinnt). Keine Angabe -> selbst realistisch schaetzen, wie viel Arbeit ins Ticket geflossen ist.
- **Nur ganze Stunden** aus {1, 2, 3, 4, 6, 8} — Schaetzung auf den naechstliegenden Wert aus dieser Liste runden.
- **Hartes Limit: 8h.** Niemals mehr buchen; liegt real mehr an -> mir melden statt zu buchen.
- Externer Kommentar: Ticket-Titel bzw. kurze Zusammenfassung (Konventionen siehe troi skill).
- **Keine valide Troi-Nummer im Ticket** (Feld leer oder unplausibel):
  - Zeit auf das Paket **"Einarbeitung"** buchen (Paket via `troi check` suchen).
  - Interner Kommentar (`--int`): vermerken, dass auf Einarbeitung gebucht wurde, weil die Troi-Nummer im Ticket fehlt bzw. falsch ist.
  - Bereits im Kommentar aus Schritt 1 ergaenzt sein: Bitte, das **Troi-Feld im Ticket zu aktualisieren** — und: falls das Ticket nicht wieder an mich zurueckgeht, bitte per **Teams** Nachricht mit der korrekten Troi-Nummer. (In der Sprache des Tickets.)

## 4. Abschluss

Kurzer Bericht:
- Ticket (Key + Link)
- Kommentar gepostet ✔/✘
- Statuswechsel nach QA ✔/✘ (bei ✘: Grund)
- Troi-Buchung: Stunden · Paket/K-Nummer · Datum ✔/✘
- Offene Punkte (z.B. Troi-Feld fehlt, bitte aktualisieren)
