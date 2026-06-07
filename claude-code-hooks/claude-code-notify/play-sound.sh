#!/bin/bash
# Play notification sound for Claude Code hooks (macOS/Linux version)
# Usage: play-sound.sh [prompt|done]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOUND_TYPE="${1:-prompt}"

# Determine sound file
case "$SOUND_TYPE" in
  prompt) SOUND_FILE="$SCRIPT_DIR/sounds/Hero.aiff" ;;
  done)   SOUND_FILE="$SCRIPT_DIR/sounds/Sosumi.aiff" ;;
  *)      SOUND_FILE="$SCRIPT_DIR/sounds/Hero.aiff" ;;
esac

# --- Platform-specific playback ---

detect_and_play() {
  local os
  os="$(uname -s)"

  case "$os" in
    Darwin)
      play_macos "$SOUND_FILE"
      ;;
    Linux)
      play_linux "$SOUND_FILE"
      ;;
    *)
      play_fallback "$SOUND_FILE"
      ;;
  esac
}

play_macos() {
  local file="$1"
  afplay "$file" 2>/dev/null &
}

play_linux() {
  local file="$1"
  # Try players in order of preference
  if command -v paplay >/dev/null 2>&1; then
    paplay "$file" 2>/dev/null &
  elif command -v aplay >/dev/null 2>&1; then
    aplay "$file" 2>/dev/null &
  elif command -v ffplay >/dev/null 2>&1; then
    ffplay -nodisp -autoexit "$file" 2>/dev/null &
  elif command -v mpv >/dev/null 2>&1; then
    mpv --no-video "$file" 2>/dev/null &
  elif command -v pwplay >/dev/null 2>&1; then
    pwplay "$file" 2>/dev/null &
  else
    # Last resort: terminal bell
    printf '\a' &
  fi
}

play_fallback() {
  local file="$1"
  if command -v afplay >/dev/null 2>&1; then
    afplay "$file" 2>/dev/null &
  elif command -v paplay >/dev/null 2>&1; then
    paplay "$file" 2>/dev/null &
  elif command -v aplay >/dev/null 2>&1; then
    aplay "$file" 2>/dev/null &
  elif command -v ffplay >/dev/null 2>&1; then
    ffplay -nodisp -autoexit "$file" 2>/dev/null &
  elif command -v mpv >/dev/null 2>&1; then
    mpv --no-video "$file" 2>/dev/null &
  else
    printf '\a' &
  fi
}

# Run
detect_and_play
