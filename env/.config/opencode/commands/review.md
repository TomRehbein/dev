---
description: Systematisches Code Review des aktuellen Diffs
agent: plan
---

Fuehre ein systematisches Code Review durch.

Analysiere den aktuellen Git-Diff (`git diff` und `git diff --staged`):

1. **Korrektheit** -- Logikfehler, Edge Cases, fehlendes Error-Handling
2. **Security** -- Injection, Auth-Luecken, Secret-Leaks
3. **Performance** -- N+1 Queries, unnoetige Re-Renders, Memory Leaks
4. **Maintainability** -- Naming, Komplexitaet, DRY-Verstoesse
5. **Tests** -- Fehlende Tests, schwache Assertions

Ergebnis als kompakte Liste mit Severity (`critical` / `warning` / `nit`) und konkretem Fix-Vorschlag pro Punkt.

$ARGUMENTS
