---
description: Jira-Ticket auslesen, simpel erklaeren, Aufgaben zwischen KI und mir aufteilen, offene Fragen finden
---

Lies ein Jira-Ticket ueber das Jira MCP und bereite es so auf, dass ich in unter 2 Minuten weiss:
was zu tun ist, was du uebernehmen kannst, was meine Aufgabe ist und was noch unklar ist.

Ticket-Key: $ARGUMENTS

## 1. Ticket finden
- Key angegeben -> dieses Ticket nehmen.
- Kein Key -> JQL: `assignee = currentUser() AND statusCategory = "In Progress" ORDER BY updated DESC`
  - 1 Treffer -> nehmen.
  - Mehrere -> Liste (Key, Titel, Status) zeigen und nachfragen. Nicht raten.
  - 0 Treffer -> sagen und stoppen.

## 2. Ticket-Kontext sammeln (read-only)
- Titel, Beschreibung, Akzeptanzkriterien, Status, Prioritaet, Reporter, Assignee
- **Alle Kommentare** -- dort stehen oft Aenderungen, die nicht in der Beschreibung sind
- Sub-Tasks, verlinkte Tickets, Epic (Titel + Status)
- Verlinkte Confluence-Seiten kurz lesen, wenn relevant

**Im Ticket nichts aendern.** Kein Kommentar, kein Statuswechsel, keine Zuweisung.

## 3. Repo finden
Ziel: Die Einschaetzung basiert auf echtem Code, nicht auf Vermutungen.
- Ist das aktuelle Verzeichnis ein Git-Repo (`git rev-parse --show-toplevel`) und passt es zum Ticket -> dieses nutzen.
- Sonst in `~/work/` suchen. Die Repos liegen dort flach, Ordnername entspricht meist Kunde bzw. Jira-Projekt-Key (z.B. `nrwb`, `pec`, `sta`). Zuordnung ueber Projekt-Key, Komponenten, Labels, Repo-Links im Ticket und `git remote -v`.
- Nicht lokal vorhanden -> mit `glab repo search` / `glab repo list` auf `gitlab.hirschtec.eu` suchen.
  - Eindeutiger Treffer -> `glab repo clone <pfad> ~/work/<name>`.
  - Mehrdeutig -> Kandidaten zeigen und nachfragen.
- Kein Repo noetig (z.B. reine Orga-/Content-Aufgabe) -> Schritt ueberspringen und das erwaehnen.

Im Repo: `AGENTS.md` / `README.md` lesen, betroffene Stellen suchen. **Keine Code-Aenderungen**, nur lesen.

## 4. Kritisch pruefen
Ticket ist Input, nicht Wahrheit. Achte auf:
- Widersprueche zwischen Beschreibung, Kommentaren und Code
- Fehlende oder nicht pruefbare Akzeptanzkriterien
- Veraltete Infos (altes Ticket, Bezug auf Dinge, die im Code nicht mehr existieren)
- Versteckten Scope ("und dann noch kurz ...")

## 5. Ausgabe
Deutsch, Tech-Begriffe englisch. Bullets, kurze Saetze, kein Filler.
Einschaetzungen markieren: ✅ [fact] · 🔶 [assumption] · 💡 [opinion]

### 🎫 [KEY] Titel
Status · Prioritaet · Reporter · Link · Repo (Pfad)

### TL;DR
2-3 Saetze, einfache Sprache: Worum geht's, warum ist es wichtig?

### Was konkret zu tun ist
Nummerierte Schritte, so klein wie sinnvoll. Betroffene Dateien als `pfad:zeile`.

### 🤖 Was die KI uebernehmen kann
Pro Punkt: Aufgabe · Confidence (hoch/mittel/niedrig) · kurze Begruendung.

### 🧑 Deine Aufgabe
Was nur ich tun kann/sollte: Entscheidungen, Abstimmung mit Personen, Zugaenge/Credentials, Review, manuelles Testen, Deployment-Freigaben.

### ❓ Offene Fragen
Pro Frage: Was ist unklar · **wen** fragen (falls ersichtlich) · ❌ blockiert oder ⚠️ nur unschoen.

### ⚠️ Risiken & Ungereimtheiten
Nur wenn vorhanden, sonst weglassen.

### ➡️ Naechster Schritt
Genau **eine** konkrete Aktion, mit der ich jetzt starten sollte.
