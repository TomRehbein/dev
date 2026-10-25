---
description: Aktuelle Changes auf eigenem Branch committen und pushen, nie mergen
---

Committe und pushe die aktuellen Changes.

Hinweis/Commit-Scope (optional): $ARGUMENTS

1. `git status`, `git diff`, `git diff --staged`, aktuellen Branch prüfen.
2. Auf `main`/`master` → zuerst neuen Branch anlegen (`feat/…`, `fix/…`, `chore/…`, passend zum Inhalt).
3. Bei parallelen Sessions: prüfen, dass der Branch noch meiner ist, bevor committet wird.
4. Changes logisch gruppieren. Ein Befund/Thema = ein Commit. Conventional Commits.
5. Keine Secrets, keine Build-Artefakte, nichts Fremdes mitcommitten. Unklar → fragen.
6. `git push -u origin <branch>` (Remote fehlt → sagen, nicht anlegen).
7. **Nie mergen.** Kein Merge nach main, kein PR-Merge.

Am Ende: Branch, Commits (Hash + Message), Push-Status, und ob noch etwas uncommittet liegt.
