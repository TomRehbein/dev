---
description: Projektstand, nächster Step, offene Entscheidungen und liegengebliebene Changes
---

Gib mir den aktuellen Stand dieses Projekts. Ziel: In unter 2 Minuten weiß ich, wo wir stehen und was ich tun muss.

Fokus (optional): $ARGUMENTS

## Quellen (read-only, nichts ändern)
- `git status`, `git branch -vv`, `git log --oneline -15`, `git stash list`, `git worktree list`
- Plan-/Step-Docs im Repo (z.B. `docs/`, `PLAN.md`, `steps/`) und neueste `~/.claude/plans/*.md` passend zum Projekt
- Laufende Prozesse, die zu diesem Projekt gehören (Orchestrator, tmux-Sessions, Dev-Server), nur wenn Hinweise darauf existieren

## Ausgabe
Einschätzungen markieren: ✅ [fact] · 🔶 [assumption] · 💡 [opinion]

### Stand
2-3 Sätze: was ist fertig, was läuft gerade.

### Git-Hygiene
- Uncommittete Changes, unpushte Branches, ungemergte Feature-Branches, Stashes. Nichts gefunden → eine Zeile "sauber".

### Nächster Step
Was genau, wie groß (S/M/L mit kurzer Begründung), ist er startklar? Wenn nicht: was fehlt.

### Deine Aufgaben
- ❓ Entscheidungen, die nur ich treffen kann (mit deiner Empfehlung)
- 🧪 Was ich manuell testen muss
- ❌ Blocker

Nichts davon starten. Erst nach meinem Go.
