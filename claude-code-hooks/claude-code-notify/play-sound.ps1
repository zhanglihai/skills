# Play notification sound for Claude Code hooks (Windows version)
# Usage: play-sound.ps1 [prompt|done]

param(
    [string]$SoundType = "prompt"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

switch ($SoundType) {
    "prompt" { $SoundFile = Join-Path $ScriptDir "sounds\notify.wav" }
    "done"   { $SoundFile = Join-Path $ScriptDir "sounds\done.wav" }
    default  { $SoundFile = Join-Path $ScriptDir "sounds\notify.wav" }
}

if (Test-Path $SoundFile) {
    try {
        $player = New-Object System.Media.SoundPlayer
        $player.SoundLocation = $SoundFile
        $player.Play()
    }
    catch {
        # Fallback to console beep
        [Console]::Beep(800, 200)
    }
}
else {
    # Sound file not found, use console beep
    [Console]::Beep(800, 200)
}
