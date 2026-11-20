# Changelog

## [1.1.0] - 2026-11-20
### Added
- **Color themes:** Ocean, Matrix, Sunset, Violet and Classic (no ANSI), with a
  nicer header and colored menus. Saved between runs.
- **Favorites menu:** add, run and remove your own commands
  (stored in `%APPDATA%\BetterCMD\favorites.txt`).
- **Action logging:** every menu action is written to
  `%APPDATA%\BetterCMD\bettercmd.log` (view, open or clear it from Settings,
  or turn it off).
- **Self-update from GitHub:** daily automatic check (can be disabled) and a
  manual check with one-step install. Reads `version.txt` from your repository.
- Settings menu (theme, logging, update check, data folder).

### Changed
- Log file moved from the script folder to `%APPDATA%\BetterCMD`.

## [1.0.0] - 2026-11-20
### Added
- Initial release with 11 menu categories: System Info, Network, Updates,
  Repair, Cleanup, Processes & Services, Disk, Security, Files,
  Quick Launch and Power.
- One-click "Update Everything" (winget, Chocolatey, Scoop, npm, pip,
  Defender, Windows Update) with a log file.
- Administrator detection and self-elevation (option `E`).
