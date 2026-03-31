---
description: PR-Beschreibung aus Commits und Diff generieren
---

Generiere eine PR-Beschreibung basierend auf den aktuellen Aenderungen.

Analysiere:
- `git log --oneline $(git merge-base HEAD main)..HEAD` (oder master/develop falls main nicht existiert)
- `git diff $(git merge-base HEAD main)..HEAD --stat`
- Die tatsaechlichen Code-Aenderungen

Erstelle die Beschreibung in diesem Format:

```
## Summary
<1-3 Bullet Points: Was wurde geaendert und warum>

## Changes
<Gruppierte Liste nach Kategorie: feat / fix / refactor / chore / etc.>

## Testing
<Wie wurde getestet / wie kann Reviewer testen>

## Notes
<Reviewer-Hinweise, Breaking Changes, abhaengige PRs, Known Issues>
```

$ARGUMENTS
