# Better CMD

An all-in-one, menu-driven batch toolkit that puts the Windows commands you actually use in one place: updates, networking, repair, cleanup, services, disk checks, security and more. No install, no dependencies, one file.

## Features

| Category                 | Highlights                                                                                                           |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| **System Info**          | `systeminfo`, OS version, CPU/RAM/BIOS, drivers, installed apps, patches, activation, battery report                 |
| **Network**              | `ipconfig`, public IP, `ping`, `tracert`, `nslookup`, flush DNS, renew IP, open ports, Wi-Fi profiles, network reset |
| **Updates**              | `winget`, Chocolatey, Scoop, npm, pip, Windows Update                                                                |
| **Repair**               | `sfc`, `DISM`, `chkdsk`, re-register Store apps, icon cache rebuild, Windows Update reset, restore point             |
| **Cleanup**              | Temp files, Recycle Bin, component cleanup, startup programs                                                         |
| **Processes & Services** | List, find, kill, start/stop/restart services, top memory users                                                      |
| **Disk**                 | Free space, disk health, TRIM/optimize, folder sizes                                                                 |
| **Security**             | Defender update and scans, status, firewall state, user accounts                                                     |
| **Files**                | List, tree, search by name or content, compare, `robocopy`                                                           |
| **Quick Launch**         | Task Manager, Device Manager, Services, Registry, Event Viewer, etc.                                                 |
| **Power**                | Shutdown, restart, timer, sleep, advanced startup, power plans                                                       |
| **Update Everything**    | One option that runs every installed updater                                                                         |
| **Favorites**            | Your own saved commands, one keypress away                                                                           |
| **Themes**               | Ocean, Matrix, Sunset, Violet or Classic                                                                             |
| **Action log**           | Timestamped record of what you ran                                                                                   |
| **Self-update**          | Checks this GitHub repo for a newer version                                                                          |

Tools that are not installed (Chocolatey, Scoop, npm, Python) are skipped automatically.

## Requirements

- Windows 10 or Windows 11
- [winget](https://learn.microsoft.com/windows/package-manager/) for the winget options
- Administrator rights for repair, system cleanup, services and network reset

## Installation

```
git clone https://github.com/dev-fahim-code/BetterCMD.git
cd BetterCMD
```

Or open `bettercmd.bat` in this repository and click **Download raw file**.

## Usage

1. Right-click `bettercmd.bat` and choose **Run as administrator** (or run it normally and press `E` to relaunch elevated).
2. Type a menu number or letter and press **Enter**.
3. Press `0` to go back or exit.

### Favorites

Press `F` in the main menu. Choose **A** to add a command, **R** to remove one, or type its number to run it. Favorites are plain text, one per line, in `%APPDATA%\BetterCMD\favorites.txt`:

```
Flush DNS|ipconfig /flushdns
Show IPv4 address|ipconfig | findstr /i "IPv4"
```

Avoid the `!` character in favorites, because batch delayed expansion removes it.

### Themes

Press `T`, then `1`. If colors look like garbled `[96m` text on your console, choose **Classic**, or run Better CMD inside Windows Terminal.

### Action log

Every menu action is appended to `%APPDATA%\BetterCMD\bettercmd.log`, for example:

```
[2026-11-20 14:03:11] Network Tools > Flush DNS cache
```

View, open or clear it from **Settings** (`T`), or turn logging off there. Nothing is ever sent anywhere.

## Self-update

Better CMD checks this repository once a day for a newer `version.txt`. When one is found, you see an "Update available" banner, or you can press `U` at any time. Installing downloads `bettercmd.bat` from the `main` branch, replaces the running file and restarts. The check can be turned off in Settings.

### For maintainers and forks

1. In `bettercmd.bat`, set `GH_USER`, `GH_REPO` and `GH_BRANCH` near the top.
2. Keep a `version.txt` in the repo root containing only the version, for example `1.1.0`.
3. To release a new version: change `VER` in `bettercmd.bat`, change `version.txt` to match, update `CHANGELOG.md`, commit and push.

If `GH_USER` is still `YOUR-USERNAME`, self-update is disabled.

## Safety notes

- Some options change your system (network reset, Windows Update reset, killing processes, deleting temp files). Read the menu text before confirming.
- The Wi-Fi password option only shows passwords for networks saved on **your own** PC.
- Create a restore point (Repair menu, option 10) before major repairs.
- Review the script before running it. It is plain text and easy to audit.

## Project structure

```
BetterCMD/
├── bettercmd.bat    # the tool
├── version.txt      # latest version, read by the self-updater
├── README.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
└── .gitattributes   # keeps CRLF line endings for .bat files
```

## Contributing

1. Fork the repo and create a branch: `git checkout -b feature/my-command`
2. Copy an existing menu block in `bettercmd.bat` and adapt it
3. Test on Windows 10 and 11, as standard user and as administrator
4. Update `CHANGELOG.md` and open a pull request

Guidelines: keep menu numbering consistent, escape `&` `(` `)` with `^` inside `echo`, add a `call :LOG "Section > Action"` line for new options, and always ask for confirmation before destructive actions.

## License

[MIT](LICENSE)
