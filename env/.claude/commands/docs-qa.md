---
description: QA über Projekt-Docs und Pläne auf Widersprüche, offene Fragen und Blocker
---

Unterziehe die Docs dieses Projekts einer QA. Die Docs sind großteils KI-geschrieben, also kritisch lesen.

Scope (optional, sonst alle Docs/Pläne im Repo): $ARGUMENTS

## Vorgehen
1. Alle relevanten Docs finden (`docs/`, `*.md` im Root, Pläne, ADRs). Liste zeigen.
2. Bei mehr als ~5 Docs: parallele read-only Subagents (`sonnet`), je ein Doc-Cluster. Jeder liefert Befunde mit `pfad:zeile`.
3. Docs gegen Code prüfen, wo sie konkrete Behauptungen machen (Pfade, Funktionen, Commands, Configs).
4. Nichts ändern. Nur berichten.

## Prüfen auf
- Widersprüche zwischen Docs oder zwischen Doc und Code
- Missverständnisse und mehrdeutige Formulierungen, die ein Agent falsch umsetzen würde
- Offene Fragen und stillschweigende Annahmen
- Blocker für die Umsetzung
- Veraltetes (Dinge, die im Code nicht mehr existieren)
- IDs ohne Klartext-Erklärung

## Ausgabe
Einschätzungen markieren: ✅ [fact] · 🔶 [assumption] · 💡 [opinion]

Pro Befund: Was · Wo (`pfad:zeile`) · Severity (❌ Blocker / ⚠️ Problem / nit) · Vorschlag.
Sortiert nach Severity. Am Ende: Fragen an mich, gebündelt, jeweils mit deiner Empfehlung.
