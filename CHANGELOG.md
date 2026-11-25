# Changelog

## 1.1.2 - 2026-11-23

Bug fixes:

- Fixed: typing a non-number (or 0) in "Shut down in X minutes" shut the PC down immediately. The input is now checked (1 to 9999 minutes)
- Fixed: answering a Y/N prompt, searching or installing an app with winget, or comparing/copying files overwrote the menu color variables, so menus showed stray text instead of colors (cmd variable names are not case sensitive)
- Fixed: npm and Scoop (any .cmd tool) ended Better CMD after they ran because they were started without CALL, so "Update everything" never reached pip, Defender and Windows Update
- Fixed: every "press any key" return to a menu left a subroutine open, so Exit could jump back into an old menu instead of closing
- Fixed: Exit printed "ECHO is on." in the Classic theme and did not restore your console colors
- Fixed: Battery report and High Performance plan said "Saved" / "set" even when they failed (desktop PCs, PCs without that plan)
- Fixed: Reset Windows Update components, Reset network stack and Delete Windows temp files reported success without Administrator rights. They now stop with a message
- Fixed: pressing E and cancelling the administrator prompt closed Better CMD
- Fixed: battery report and winget export/import used a fixed Desktop path, which fails when the Desktop is moved to OneDrive
- Fixed: folder names with an apostrophe broke "Show folder size", "Restart as Administrator" and the updater. Paths pasted with quotes ("Copy as path") now work in the Files menu
- Changed: "Internet speed check" is now "Internet connection check", because it only pings
- Changed: Windows Update messages no longer claim that updates started. They point you to Settings

## 1.1.1 - 2026-11-21

- Fixed: Security & Defender > "Show logged-in users" failed with "'query' is not recognized" on Windows Home. It now uses PowerShell and works on every Windows edition.

## 1.1.0 - 2026-11-20

Initial public release.

- Menu-driven toolkit with 11 categories: System Information, Network Tools, Updates & Package Managers, System Repair, Cleanup & Optimization, Processes & Services, Disk & Storage, Security & Defender, Files & Folders, Quick Launch and Power & Shutdown
- Favorites: save and run your own commands
- Update Everything: winget, Chocolatey, Scoop, npm, pip, Defender definitions and Windows Update in one go
- Themes: Ocean, Matrix, Sunset, Violet and Classic
- Action log with a viewer in Settings
- Self-update from this GitHub repository, with a daily automatic check
- Restart as Administrator from inside the menu
