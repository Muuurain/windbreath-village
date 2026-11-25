# Contributing to 风息村落物语 (Windbreath Village)

Thank you for helping improve **Windbreath Village**!

## Development Requirements
- **Godot 4.7.2** (Standard or Mono; project uses typed GDScript 2.0 + GL Compatibility)
- **Python 3.11+** (`Pillow`, `numpy`) & **FFmpeg** (only needed when regenerating art/audio assets)

## Verifying Changes Locally
Before opening a Pull Request, run the headless test suite:

```powershell
powershell -ExecutionPolicy Bypass -File tools\verify_project.ps1
```

## Coding Conventions
- Keep core simulation (`src/core/`) strictly decoupled from scene tree rendering so headless tests stay fast and deterministic.
- Follow `.editorconfig` (tabs in `.gd`, UTF-8 LF).
- Preserve Android Safe Area padding and `TouchScrollContainer` drag ergonomics across all portrait UI panels.
