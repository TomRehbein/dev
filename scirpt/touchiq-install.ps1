# Sets up touchiq on a fresh Windows 10 or 11 machine. Safe to run again.
# Run it with: powershell -ExecutionPolicy Bypass -File install.ps1
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Repo = 'git@github.com:TomRehbein/TouchIQ.git'
$GnuToolchain = 'stable-x86_64-pc-windows-gnu'

function Say($text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Info($text) { Write-Host "    $text" }

function Ask($prompt, $default) {
    $label = if ($default) { "$prompt [$default]" } else { $prompt }
    $answer = Read-Host $label
    if ($answer) { $answer.Trim() } else { $default }
}

function Wait-Enter($text) { [void](Read-Host "`n$text") }

# PowerShell does not stop on a failing program, only on failing cmdlets.
function Exec([scriptblock]$command) {
    & $command
    if ($LASTEXITCODE -ne 0) { throw "Befehl fehlgeschlagen ($LASTEXITCODE): $command" }
}

# Installers change PATH only for new windows, so read it again from the registry.
function Update-Path {
    $env:Path = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User'),
        "$HOME\.bun\bin",
        "$HOME\.cargo\bin"
    ) -join ';'
}

# Only the winget source. The Microsoft Store source fails without a working Store
# and then stops every search, even for packages from winget.
function Install-Winget($id, $label) {
    $ErrorActionPreference = 'Continue'
    winget list --id $id -e --source winget --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) { return }
    Say "$label installieren"
    Info 'Fragt Windows "Änderungen zulassen?", klick auf "Ja".'
    winget install --id $id -e --source winget --silent --accept-source-agreements --accept-package-agreements
    # Already installed, found by install but not by list: 0x8A15002B, 0x8A150061.
    if ($LASTEXITCODE -notin 0, -1978335189, -1978335135) { throw "winget install $id fehlgeschlagen ($LASTEXITCODE)" }
    Update-Path
}

function Get-Details {
    Say 'Ein paar Angaben'
    Info 'Name und E-Mail stehen später an deinen Änderungen im Repo.'
    Info 'Nimm die E-Mail, mit der du bei GitHub angemeldet bist.'
    $oldName = ''
    $oldEmail = ''
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $oldName = git config --global user.name
        $oldEmail = git config --global user.email
    }
    $script:Name = Ask 'Dein Name' $oldName
    while (-not $script:Name) { $script:Name = Ask 'Dein Name' }
    $script:Email = Ask 'Deine GitHub-E-Mail' $oldEmail
    while ($script:Email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') { $script:Email = Ask 'Bitte eine gültige E-Mail' }
    $script:Dir = Ask 'Ordner für touchiq' "$HOME\TouchIQ"
}

function Install-Tools {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget fehlt. Installier im Microsoft Store den "App-Installer" und starte das Script neu.'
    }
    Install-Winget 'Git.Git' 'git'
    Install-Winget 'Gyan.FFmpeg' 'ffmpeg'
    Install-Winget 'BrechtSanders.WinLibs.POSIX.UCRT' 'MinGW (für Rust)'
    $chrome = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    ) | Where-Object { Test-Path $_ }
    if (-not $chrome) { Install-Winget 'Google.Chrome' 'Google Chrome' }
}

function Get-BunVersion {
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { return [version]'0.0' }
    [version]((bun --version) -replace '[^0-9.].*$', '')
}

function Install-Bun {
    Update-Path
    if ((Get-BunVersion) -lt [version]'1.4') {
        Say 'Bun installieren'
        Exec { powershell -NoProfile -ExecutionPolicy Bypass -Command 'irm https://bun.sh/install.ps1 | iex' }
        Update-Path
    }
    $version = Get-BunVersion
    if ($version -lt [version]'1.4') { throw "Bun $version ist zu alt, touchiq braucht 1.4 oder neuer." }
}

function Install-Rust {
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Say 'Rust aktualisieren'
        Exec { rustup toolchain install $GnuToolchain --profile minimal }
        return
    }
    Say 'Rust installieren'
    $installer = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe -OutFile $installer -UseBasicParsing
    Exec { & $installer -y --default-host x86_64-pc-windows-gnu --default-toolchain stable --profile minimal }
    Update-Path
}

function Set-GitConfig {
    Exec { git config --global user.name $script:Name }
    Exec { git config --global user.email $script:Email }
    Exec { git config --global pull.ff only }
}

# SSH runs through the Git Bash that comes with git, the same ssh git uses.
function Invoke-Bash($command) {
    & "$env:ProgramFiles\Git\bin\bash.exe" -lc $command
}

# ssh -T exits with 1 even when GitHub accepts the key, so check the message.
function Test-GitHub {
    $ErrorActionPreference = 'Continue'
    $out = Invoke-Bash 'ssh -T -o StrictHostKeyChecking=accept-new -o BatchMode=yes git@github.com 2>&1'
    ($out -join "`n") -match 'successfully authenticated'
}

function Set-Ssh {
    Say 'Verbindung zu GitHub'
    $key = "$HOME\.ssh\id_ed25519"
    if (-not (Test-Path $key)) {
        Invoke-Bash "mkdir -p ~/.ssh && ssh-keygen -t ed25519 -C '$($script:Email)' -f ~/.ssh/id_ed25519 -N '' -q"
        if (-not (Test-Path "$key.pub")) { throw 'SSH-Schlüssel konnte nicht angelegt werden.' }
        Info "Neuer SSH-Schlüssel angelegt: $key"
    }
    if (Test-GitHub) {
        Info 'GitHub kennt diesen Computer schon.'
        return
    }
    Get-Content "$key.pub" -Raw | Set-Clipboard
    Write-Host @'

    GitHub muss diesen Computer einmal kennenlernen. So geht's:

    1. Gleich öffnet sich github.com im Browser. Melde dich an, falls nötig.
    2. Bei "Title" trägst du einen Namen für den Computer ein, z.B. "Mein Laptop".
    3. "Key type" bleibt "Authentication Key".
    4. Ins große Feld "Key" fügst du den Schlüssel ein.
       Er ist schon kopiert, also nur einfügen (Strg+V).
    5. Klick auf "Add SSH key". GitHub fragt evtl. nochmal nach deinem Passwort.

    Der Schlüssel ist öffentlich, den darfst du ruhig weitergeben.
    Die Datei ohne ".pub" bleibt auf diesem Computer.
'@
    Wait-Enter 'Drück Enter, um github.com zu öffnen.'
    Start-Process 'https://github.com/settings/ssh/new'
    Wait-Enter 'Drück Enter, wenn du auf "Add SSH key" geklickt hast.'
    while (-not (Test-GitHub)) {
        Info 'GitHub erkennt den Schlüssel noch nicht.'
        Info 'Prüf, ob du ihn komplett eingefügt und gespeichert hast.'
        Get-Content "$key.pub" -Raw | Set-Clipboard
        Wait-Enter 'Drück Enter, um es nochmal zu versuchen.'
    }
    Info 'Verbindung zu GitHub steht.'
}

function Get-Repo {
    if (Test-Path "$script:Dir\.git") {
        Say 'touchiq aktualisieren'
        Exec { git -C $script:Dir pull --ff-only }
    } elseif ((Test-Path $script:Dir) -and (Get-ChildItem $script:Dir -Force)) {
        throw "$script:Dir existiert schon und ist nicht leer. Starte das Script neu und nimm einen anderen Ordner."
    } else {
        Say 'touchiq herunterladen'
        Exec { git clone $Repo $script:Dir }
    }
}

function Build-App {
    Say 'touchiq bauen (beim ersten Mal ein paar Minuten)'
    Push-Location $script:Dir
    try {
        Exec { rustup override set $GnuToolchain }
        Exec { cargo build --release }
        Push-Location app
        try { Exec { bun install } } finally { Pop-Location }
    } finally { Pop-Location }
    New-Item -ItemType Directory -Force "$script:Dir\data\matches" | Out-Null
}

function New-DesktopShortcut($label, $file) {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$desktop\$label.lnk")
    $shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    # -Command, not -File. A missing or broken script then shows its error, -File closes the window.
    $path = "$script:Dir\scripts\$file" -replace "'", "''"
    $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -Command `"& '$path'`""
    $shortcut.WorkingDirectory = $script:Dir
    $shortcut.Save()
}

try {
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') { throw 'Nur Windows auf Intel- oder AMD-Prozessoren wird unterstützt.' }
    Write-Host 'touchiq einrichten' -ForegroundColor White
    Write-Host 'Das Script installiert alles Nötige und fragt nur, wenn es dich braucht.'
    Get-Details
    Install-Tools
    Install-Bun
    Install-Rust
    Set-GitConfig
    Set-Ssh
    Get-Repo
    Build-App
    New-DesktopShortcut 'TouchIQ starten' 'start.ps1'
    New-DesktopShortcut 'TouchIQ aktualisieren' 'update.ps1'
    Say 'Fertig'
    Info 'Starten: Doppelklick auf "TouchIQ starten" auf dem Desktop.'
    Info 'Aktualisieren: Doppelklick auf "TouchIQ aktualisieren".'
    Info "Die Spiele kommen nach $script:Dir\data\matches\."
    Wait-Enter 'Drück Enter zum Schließen.'
} catch {
    Write-Host "`nFehler: $_" -ForegroundColor Red
    Write-Host 'Schick Tom einen Screenshot von diesem Fenster.'
    Wait-Enter 'Drück Enter zum Schließen.'
    exit 1
}
