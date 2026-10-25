---
description: Alle mir zugewiesenen offenen Jira-Tickets (todo/doing) einschaetzen und priorisieren
---

Verschaffe mir einen Ueberblick ueber alle Jira-Tickets, die mir zugewiesen sind und offen bzw. in Arbeit sind.
Ziel: Ich weiss in unter 3 Minuten, was ansteht, was die KI uebernehmen kann, wo ich ran muss und wo Fragen offen sind.

Zusaetzliche Hinweise (optional): $ARGUMENTS

## 1. Tickets laden
JQL: `assignee = currentUser() AND statusCategory in ("To Do", "In Progress") ORDER BY priority DESC, updated DESC`
- Pruefe die tatsaechlichen Status-Namen. Tickets in Backlog-artigen Status (z.B. "Backlog", "Idee") separat am Ende auflisten, nicht analysieren.
- 0 Treffer -> sagen und stoppen.

## 2. Pro Ticket Kontext sammeln (read-only)
- Titel, Beschreibung, Akzeptanzkriterien, Status, Prioritaet, Faelligkeit, Reporter
- **Kommentare** (vor allem die neuesten), Sub-Tasks, verlinkte Tickets
- Repo zuordnen: Ordner in `~/work/` (flach, Ordnername ~ Kunde/Jira-Projekt-Key, z.B. `nrwb`, `pec`). Nur zuordnen und bei Bedarf kurz reinschauen -- **keine Deep-Dives** pro Ticket, das macht `/ticket <KEY>`.
- Fehlt ein Repo lokal -> nur vermerken (mit `glab repo search` Kandidat nennen), **nicht** automatisch klonen.

**In Jira nichts aendern. Keine Code-Aenderungen.**

Ticket ist Input, nicht Wahrheit: Widersprueche, fehlende Akzeptanzkriterien, veraltete Infos und versteckten Scope markieren.

## 3. Ausgabe
Deutsch, Tech-Begriffe englisch. Bullets, kurze Saetze, kein Filler.
Einschaetzungen markieren: ✅ [fact] · 🔶 [assumption] · 💡 [opinion]

### 📋 Uebersicht
Tabelle: Key · Titel (kurz) · Status · Prio · Faellig · Repo · KI-Anteil (hoch/mittel/niedrig) · Blocker (❌/–)

### Pro Ticket (Reihenfolge = empfohlene Bearbeitung)
#### 🎫 [KEY] Titel
- **TL;DR:** 1-2 Saetze, einfache Sprache
- **🤖 KI:** was die KI uebernehmen kann (mit Confidence)
- **🧑 Du:** was ich selbst tun muss
- **❓ Offen:** Fragen · wen fragen · ❌ blockiert / ⚠️ unschoen. Keine -> weglassen.

### 🔁 Querschnitt
Nur wenn vorhanden: Abhaengigkeiten zwischen Tickets, Duplikate, Tickets die man buendeln kann, Ueberlastung/Deadline-Konflikte.

### ➡️ Empfehlung
- Womit ich **jetzt** starten sollte und warum (1 Ticket)
- Welche Fragen ich **heute** stellen sollte, damit nichts blockiert (gebuendelt nach Person)
- Fuer Details: `/ticket <KEY>`
