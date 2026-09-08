# Browser-Zugriff für Agents ohne Credential-Leak

**Status:** aktiv (Phase 1)

## Ziel

OpenCode-Agents sollen Kundensysteme im Browser bedienen können, ohne dass
1Password-Zugänge (Passwort, TOTP, Master-Unlock) je im Modell-Kontext
landen — weder als Tool-Output noch in Transcripts, die an einen LLM-Provider
gehen.

## Sicherheitsmodell

**Geschützt:** Langlebige Secrets (Kunden-Passwörter, TOTP-Seeds,
1Password-Zugang). Sie laufen ausschließlich durch Prozesse, deren Output
nie ins Agent-Transcript geht — der `dev-browser login`-Schritt, den nur Tom
manuell ausführt.

**Nicht geschützt, aber bewusst akzeptiert:** Die **Session** (Cookies +
localStorage) des Kundensystems. Ohne die kann der Agent dort nicht arbeiten.
Sessions sind kurzlebig (siehe `maxAgeHours` pro Profil) und einzeln per
`dev-browser logout <profil>` widerrufbar.

**Was das *nicht* leistet:** OpenCode läuft als derselbe Unix-User wie
`dev-browser`. Ein Agent mit freiem Bash-Zugriff könnte technisch `op`/`op.exe`
selbst aufrufen oder die Session-Dateien lesen. Die Deny-Regeln in
`env/.config/opencode/opencode.json` (`permission.bash`) sind Defense-in-Depth
gegen versehentliches Leaken — Bash-Pattern-Matching lässt sich mit z. B.
`o""p read …` umgehen. Das ist bewusst zurückgestellt, keine Fehlannahme:
eine echte Grenze bräuchte einen eigenen Systemuser oder Container für den
Browser/Credential-Broker, den der Agent nur noch über einen CDP-Socket
erreicht.

## Nutzung

```bash
# einmalig pro Kundensystem, von Tom, headed Browser:
dev-browser login kunde-xyz

# danach vom Agent (oder Tom) beliebig oft:
dev-browser use kunde-xyz
playwright-cli snapshot
```

Profile: `~/.config/dev-browser/profiles.json` (Template wird beim ersten
Lauf angelegt). Details und Befehlsreferenz: `dev-browser --help`, Skill
`env/.config/opencode/skills/dev-browser/SKILL.md`.

## Migrationspfad: harte Isolation (Stufe 2, nicht umgesetzt)

Falls ein Kundensystem das verlangt (z. B. weil ein Agent auch mit
weniger vertrauenswürdigem/generiertem Code hantiert):

- Browser + `dev-browser login` laufen als eigener Systemuser (z. B.
  `devbrowser`), Dateirechte erzwingen die Trennung statt Konvention.
- Der Agent-User erreicht den Browser nur über einen CDP-Socket
  (`playwright-cli attach --cdp`), nicht über Dateisystem-Zugriff auf die
  Session-Datei.
- WSL-Besonderheiten: eigener User braucht eigenen WSLg-Zugriff (`DISPLAY`,
  `WAYLAND_DISPLAY`) für den headed Login-Schritt, oder der Login läuft
  weiterhin unter Toms User und nur `use` wechselt den Kontext.
- 1Password-Service-Account statt persönlichem Account, falls Phase 2
  (automatischer Login) unbeaufsichtigt laufen soll — Token liegt dann aber
  selbst langlebig auf Platte, das ist der neue schwächste Punkt.

## Offene Punkte

- **1Password-Unlock in WSL:** `op.exe` läuft unter WSL über die
  Windows-Installation (Windows-Hello/Desktop-App-Unlock). Ob ein
  automatisierter `op.exe read` ohne interaktiven Prompt durchläuft, ist für
  Phase 2 noch zu klären.
- **`--allowed-origins`:** playwright-cli liest optional eine Config
  (`--config`) mit `allowedOrigins`. Pro Profil eine Config zu generieren
  würde den Agent-Browser hart auf die Kunden-Domain einsperren — sinnvolle
  Ergänzung, noch nicht umgesetzt.
- **Phase 2 (automatischer Login via `op`):** noch nicht gebaut. Kommt erst,
  wenn klar ist, welche Systeme den manuellen Login-Schritt wirklich stören.
