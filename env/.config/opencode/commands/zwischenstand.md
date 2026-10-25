---
description: Zwischenstand im Jira-Ticket dokumentieren und Zeit in Troi buchen — ohne Statuswechsel
---

Dokumentiere den aktuellen Zwischenstand im Jira-Ticket und buche die Zeit in Troi. Das Ticket bleibt in seinem aktuellen Status — **kein Statuswechsel, nicht als fertig markieren**.

Zusaetzliche Hinweise (optional): $ARGUMENTS

## 0. Ticket ermitteln und Daten sammeln

- Key in $ARGUMENTS -> dieses Ticket nehmen.
- Sonst: Ticket aus dem Session-Kontext uebernehmen (Session lief i.d.R. mit `/ticket <KEY>`). Key + Titel kurz bestaetigen.
- Nicht ermittelbar -> JQL `assignee = currentUser() AND statusCategory = "In Progress" ORDER BY updated DESC`; 1 Treffer -> nehmen, mehrere -> Liste zeigen und nachfragen, nicht raten.

Ticket frisch aus Jira lesen (read-only): Beschreibung, Kommentare, Status, Custom Field **"Troi"** (`customfield_10700`). Daraus brauche ich spaeter: Sprache des Tickets, Troi-Nummer, evtl. angegebene Zeit/Aufwand.

Im Repo (wie in `/ticket` ermittelt) pruefen, was bisher umgesetzt wurde — der Kommentar basiert auf echtem Code, nicht auf Vermutungen.

## 1. Jira-Kommentar schreiben

Zuerst den `unslop` skill laden und befolgen.

Der Kommentar ist sachlich und informativ, aber leicht verstaendlich und schnell zum Punkt (ADHS-freundlich: kurze Absaetze, Bullets, das Wesentliche fett, kein Filler, keine Floskeln).

Struktur (sinngemaess, an Ticket anpassen):
- **Stand:** 1-2 Saetze — worum es geht und wie weit es ist
- **Erledigt:** was umgesetzt/verifiziert ist, mit Repo-Dateien
- **Offen:** was noch fehlt bzw. ungelöst ist, als nummerierte To-dos
- **Naechste Schritte:** womit weitergemacht wird; blockierende Fragen deutlich markieren

Regeln:
- **Gleiche Sprache wie das Ticket selbst.** Deutsch -> deutsch, Englisch -> englisch. Tech-Begriffe bleiben englisch.
- Als **Markdown** formatieren.
- **Keine lokalen Pfade** (`/Users/...`, `~/work/...` o.ae.). Nur Dateien referenzieren, die im Repo liegen und von der Repo-Wurzel aus erreichbar sind (z.B. `src/foo/bar.ts`).
- Keine Erwaehnung von KI/Session, keine internen Codierungen.
- Als Zwischenstand lesbar machen (z.B. "**Zwischenstand**" als erste Zeile), damit niemand Fertigstellung reinliest.

## 2. Zeit in Troi buchen

Den `troi` skill laden und dessen Ablauf befolgen (K-Nummer ermitteln -> `troi check` -> `troi book`).

- **Bereits Gebuchtes pruefen (vor jeder Buchung):** `troi week`/`troi month --json` pruefen, ob fuer dieses Ticket schon Zeit gebucht wurde. Der interne Kommentar enthaelt laut Konvention den Ticket-Key; falls dort nicht sichtbar, ueber den externen Kommentar (Ticket-Titel) matchen. Zeitraum: rueckwirkend ab Beginn der Arbeit am Ticket (z.B. aktueller Monat, bei Bedarf weiter zurueck).
  - Schon Zeit gebucht -> mir melden, wie viel bereits gebucht ist (Stunden + Datum), und **nachfragen, wie viel jetzt gebucht werden soll**. Nicht autonom buchen — die Anteils-Schaetzung unten dient dann nur als Orientierung.
  - Nichts gebucht -> wie unten beschrieben weitermachen.
- **Aufwand (Anteil, nicht die volle Schaetzung):** Es wird **nicht** die komplette Zeitschaetzung des Tickets gebucht, sondern nur ein Anteil — abhaengig von der Schaetzung im Ticket (bzw. eigener Schaetzung, falls keine angegeben) und davon, wie gross der tatsaechlich erledigte Umfang im Verhaeltnis zum Gesamtticket ist. Beispiel: 8h-Schaetzung, rund die Haelfe umgesetzt -> 4h. Der Anteil begruenden (Schaetzung x erledigter Umfang).
- **Nur ganze Stunden** aus {1, 2, 3, 4, 6, 8} — Schaetzung auf den naechstliegenden Wert aus dieser Liste runden.
- **Hartes Limit: 8h.** Niemals mehr buchen; liegt real mehr an -> mir melden statt zu buchen.
- Externer Kommentar: Ticket-Titel bzw. kurze Zusammenfassung (Konventionen siehe troi skill).
- **Keine valide Troi-Nummer im Ticket** (Feld leer oder unplausibel):
  - Zeit auf das Paket **"Einarbeitung"** buchen (Paket via `troi check` suchen).
  - Interner Kommentar (`--int`): vermerken, dass auf Einarbeitung gebucht wurde, weil die Troi-Nummer im Ticket fehlt bzw. falsch ist.
  - Im Zwischenstandskommentar ergaenzen: Bitte, das **Troi-Feld im Ticket zu aktualisieren** — und: falls das Ticket nicht wieder an mich zurueckgeht, bitte per **Teams** Nachricht mit der korrekten Troi-Nummer. (In der Sprache des Tickets.)

## 3. Abschluss

Kurzer Bericht:
- Ticket (Key + Link)
- Zwischenstandskommentar gepostet ✔/✘
- Troi-Buchung: Stunden · Paket/K-Nummer · Datum ✔/✘
- Offene Punkte (z.B. Troi-Feld fehlt, bitte aktualisieren)
