@echo off
setlocal EnableDelayedExpansion
title Better CMD - Windows Toolkit

:: ============================================================
::  BETTER CMD v1.1.2
::  All-in-one menu for essential Windows commands.
::  License : MIT
::  Usage   : Right-click and choose "Run as administrator"
::            for full functionality (or press E in the menu).
:: ============================================================

:: ---- Edit these for your own GitHub repository -------------
set "VER=1.1.2"
set "GH_USER=dev-fahim-code"
set "GH_REPO=BetterCMD"
set "GH_BRANCH=main"
:: ------------------------------------------------------------

set "SELF=%~f0"
set "SELFDIR=%~dp0"
set "DATA=%APPDATA%\BetterCMD"
if not exist "%DATA%" mkdir "%DATA%" >nul 2>&1
set "CFG=%DATA%\settings.ini"
set "FAV=%DATA%\favorites.txt"
set "LOGFILE=%DATA%\bettercmd.log"

:: ---- Load settings (defaults first) ------------------------
set "CFG_THEME=ocean"
set "CFG_LOGGING=on"
set "CFG_AUTOCHECK=on"
set "CFG_LASTCHECK=never"
if exist "%CFG%" for /f "usebackq tokens=1,* delims==" %%a in ("%CFG%") do set "CFG_%%a=%%b"

set "ISADMIN=0"
net session >nul 2>&1 && set "ISADMIN=1"

:: ---- Create the ESC character for ANSI colors --------------
set "ESC="
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
if not defined ESC set "CFG_THEME=classic"
call :SETTHEME

if not exist "%CFG%" call :SAVECFG
call :LOG "Session started v%VER% admin=%ISADMIN%"

:: ---- Daily automatic update check --------------------------
set "UPDMSG="
if /i not "%CFG_AUTOCHECK%"=="on" goto START_DONE
if /i "%GH_USER%"=="YOUR-USERNAME" goto START_DONE
if "%CFG_LASTCHECK%"=="%date%" goto START_DONE
echo   Checking for updates...
call :DOCHECK
if "%UPDSTAT%"=="NEW" set "UPDMSG=Update available: v%UPDV% (press U to update)"
if "%UPDSTAT%"=="NEW" call :LOG "Update available v%UPDV%"
if "%UPDSTAT%"=="OK" set "CFG_LASTCHECK=%date%" & call :SAVECFG
:START_DONE

:: ============================================================
:MAIN
cls
call :HEADER
echo   %Y%[1]%R%  System Information
echo   %Y%[2]%R%  Network Tools
echo   %Y%[3]%R%  Updates ^& Package Managers
echo   %Y%[4]%R%  System Repair
echo   %Y%[5]%R%  Cleanup ^& Optimization
echo   %Y%[6]%R%  Processes ^& Services
echo   %Y%[7]%R%  Disk ^& Storage
echo   %Y%[8]%R%  Security ^& Defender
echo   %Y%[9]%R%  Files ^& Folders
echo   %Y%[10]%R% Quick Launch Windows Tools
echo   %Y%[11]%R% Power ^& Shutdown
echo.
echo   %A%--- TOOLS ---%R%
echo   %Y%[F]%R%  Favorites - your own commands
echo   %Y%[A]%R%  UPDATE EVERYTHING - one click
echo   %Y%[U]%R%  Check for Better CMD updates
echo   %Y%[T]%R%  Settings ^& themes
echo   %Y%[L]%R%  View action log
echo   %Y%[E]%R%  Restart as Administrator
echo   %Y%[0]%R%  Exit
echo.
set "ch="
set /p "ch=  Select an option: "
if "%ch%"=="1"  goto SYSINFO
if "%ch%"=="2"  goto NETWORK
if "%ch%"=="3"  goto UPDATES
if "%ch%"=="4"  goto REPAIR
if "%ch%"=="5"  goto CLEANUP
if "%ch%"=="6"  goto PROCS
if "%ch%"=="7"  goto DISK
if "%ch%"=="8"  goto SECURITY
if "%ch%"=="9"  goto FILES
if "%ch%"=="10" goto LAUNCH
if "%ch%"=="11" goto POWER
if /i "%ch%"=="F" goto FAVS
if /i "%ch%"=="A" goto UPDATEALL
if /i "%ch%"=="U" goto SELFUPDATE
if /i "%ch%"=="T" goto SETTINGS
if /i "%ch%"=="L" goto VIEWLOG
if /i "%ch%"=="E" goto ELEVATE
if "%ch%"=="0"  goto EXIT
goto MAIN

:EXIT
call :LOG "Session ended"
color
echo.%R%
exit /b

:: ------------------------------------------------------------
:HEADER
if "%ISADMIN%"=="1" (set "ADM=%G%Administrator%R%") else (set "ADM=%E%Standard user%R% %D%- some commands need admin%R%")
echo %A%============================================================%R%
echo %A%                  B E T T E R   C M D%R%  %D%v%VER%%R%
echo %A%============================================================%R%
echo   User: %USERNAME%   PC: %COMPUTERNAME%   Mode: %ADM%
if defined UPDMSG echo   %Y%%UPDMSG%%R%
echo %A%============================================================%R%
echo.
exit /b

:: ------------------------------------------------------------
:: Helpers
:: REQADMIN: returns 1 (after printing a hint) when not running as Administrator
:REQADMIN
if "%ISADMIN%"=="1" exit /b 0
echo   %E%This option needs Administrator rights.%R%
echo   Go back to the main menu and press E to restart as Administrator.
exit /b 1

:: GETDESK: sets DESK to the real Desktop folder (works when the Desktop is on OneDrive)
:GETDESK
set "DESK="
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "DESK=%%d"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
exit /b

:: UNQ: removes double quotes from the variable named in %1 (paths pasted with "Copy as path")
:UNQ
if defined %1 set "%1=!%1:"=!"
exit /b

:ELEVATE
if "%ISADMIN%"=="1" (
    echo Already running as Administrator.
    pause
    goto MAIN
)
call :LOG "Restart as administrator"
set "SELFQ=%SELF:'=''%"
powershell -NoProfile -Command "try{Start-Process -FilePath '%SELFQ%' -Verb RunAs -ErrorAction Stop}catch{exit 1}"
if errorlevel 1 goto ELEV_FAIL
exit /b
:ELEV_FAIL
echo   The administrator prompt was cancelled or failed.
pause
goto MAIN

:: ------------------------------------------------------------
:: Logging: appends a timestamped line when logging is on
:LOG
if /i not "%CFG_LOGGING%"=="on" exit /b
set "LMSG=%~1"
>>"%LOGFILE%" echo [%date% %time:~0,8%] !LMSG!
exit /b

:VIEWLOG
cls
call :HEADER
echo %A%  --- ACTION LOG - last 40 entries ---%R%
echo   %D%%LOGFILE%%R%
echo.
powershell -NoProfile -Command "$f=$env:APPDATA+'\BetterCMD\bettercmd.log'; if(Test-Path $f){Get-Content $f -Tail 40}else{'No log yet.'}"
echo.
pause
goto MAIN

:: ------------------------------------------------------------
:: Settings storage
:SAVECFG
if not defined CFG_LASTCHECK set "CFG_LASTCHECK=never"
>"%CFG%" echo THEME=%CFG_THEME%
>>"%CFG%" echo LOGGING=%CFG_LOGGING%
>>"%CFG%" echo AUTOCHECK=%CFG_AUTOCHECK%
>>"%CFG%" echo LASTCHECK=%CFG_LASTCHECK%
exit /b

:: ------------------------------------------------------------
:: Themes: sets the color variables used by every menu
:SETTHEME
set "A=" & set "Y=" & set "G=" & set "E=" & set "D=" & set "R="
if /i "%CFG_THEME%"=="classic" (
    color 0A
    exit /b
)
color 07
set "R=%ESC%[0m"
set "Y=%ESC%[93m"
set "G=%ESC%[92m"
set "E=%ESC%[91m"
set "D=%ESC%[90m"
if /i "%CFG_THEME%"=="ocean"  set "A=%ESC%[96m"
if /i "%CFG_THEME%"=="matrix" set "A=%ESC%[92m"
if /i "%CFG_THEME%"=="sunset" set "A=%ESC%[38;5;208m"
if /i "%CFG_THEME%"=="violet" set "A=%ESC%[95m"
if not defined A set "A=%ESC%[96m"
exit /b

:SETTINGS
cls
call :HEADER
echo %A%  --- SETTINGS ^& THEMES ---%R%
echo   %Y%[1]%R%  Change color theme     %D%current: %CFG_THEME%%R%
echo   %Y%[2]%R%  Action logging         %D%current: %CFG_LOGGING%%R%
echo   %Y%[3]%R%  Daily update check     %D%current: %CFG_AUTOCHECK%%R%
echo   %Y%[4]%R%  View log - last 40 entries
echo   %Y%[5]%R%  Open log in Notepad
echo   %Y%[6]%R%  Clear log
echo   %Y%[7]%R%  Open data folder
echo   %Y%[0]%R%  Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" goto THEMEPICK
if "%c%"=="2" goto SET_LOGGING
if "%c%"=="3" goto SET_AUTOCHECK
if "%c%"=="4" powershell -NoProfile -Command "$f=$env:APPDATA+'\BetterCMD\bettercmd.log'; if(Test-Path $f){Get-Content $f -Tail 40}else{'No log yet.'}" & echo. & pause & goto SETTINGS
if "%c%"=="5" start "" notepad "%LOGFILE%" & goto SETTINGS
if "%c%"=="6" del /q "%LOGFILE%" >nul 2>&1 & echo Log cleared. & echo. & pause & goto SETTINGS
if "%c%"=="7" start "" explorer "%DATA%" & goto SETTINGS
if "%c%"=="0" goto MAIN
goto SETTINGS

:SET_LOGGING
if /i "%CFG_LOGGING%"=="on" (set "CFG_LOGGING=off") else (set "CFG_LOGGING=on")
call :SAVECFG
goto SETTINGS

:SET_AUTOCHECK
if /i "%CFG_AUTOCHECK%"=="on" (set "CFG_AUTOCHECK=off") else (set "CFG_AUTOCHECK=on")
call :SAVECFG
goto SETTINGS

:THEMEPICK
cls
call :HEADER
echo %A%  --- CHOOSE A THEME ---%R%
echo   %Y%[1]%R%  %ESC%[96mOcean%R%    cyan
echo   %Y%[2]%R%  %ESC%[92mMatrix%R%   green
echo   %Y%[3]%R%  %ESC%[38;5;208mSunset%R%   orange
echo   %Y%[4]%R%  %ESC%[95mViolet%R%   purple
echo   %Y%[5]%R%  Classic  green text, no ANSI colors - use this if colors look broken
echo   %Y%[0]%R%  Back
echo.
set "tc="
set /p "tc=  Select: "
if not defined tc goto SETTINGS
if "%tc%"=="0" goto SETTINGS
if "%tc%"=="1" set "CFG_THEME=ocean"
if "%tc%"=="2" set "CFG_THEME=matrix"
if "%tc%"=="3" set "CFG_THEME=sunset"
if "%tc%"=="4" set "CFG_THEME=violet"
if "%tc%"=="5" set "CFG_THEME=classic"
call :SETTHEME
call :SAVECFG
call :LOG "Theme set > %CFG_THEME%"
goto SETTINGS

:: ============================================================
:: FAVORITES - your own commands, stored in favorites.txt as
::   Name|command
:FAV_INIT
if exist "%FAV%" exit /b
>"%FAV%" echo Update all apps^|winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
>>"%FAV%" echo Flush DNS^|ipconfig /flushdns
>>"%FAV%" echo Show IPv4 address^|ipconfig ^| findstr /i "IPv4"
>>"%FAV%" echo List open ports^|netstat -ano
exit /b

:FAVS
cls
call :HEADER
call :FAV_INIT
echo %A%  --- FAVORITES ---%R%
set /a "fi=0"
for /f "usebackq tokens=1,* delims=|" %%a in ("%FAV%") do (
    set /a fi+=1
    echo   %Y%[!fi!]%R% %%a  %D%- %%b%R%
)
if %fi%==0 echo   No favorites yet - press A to add one.
echo.
echo   %Y%[A]%R% Add   %Y%[R]%R% Remove   %Y%[E]%R% Edit in Notepad   %Y%[0]%R% Back
echo   Type a number to run that favorite.
echo.
set "fsel="
set /p "fsel=  Select: "
if not defined fsel goto FAVS
if "%fsel%"=="0" goto MAIN
if /i "%fsel%"=="A" goto FAV_ADD
if /i "%fsel%"=="R" goto FAV_DEL
if /i "%fsel%"=="E" start /wait "" notepad "%FAV%" & goto FAVS
goto FAV_RUN

:FAV_RUN
set "FCMD="
set "FNAME="
set /a "fj=0"
for /f "usebackq tokens=1,* delims=|" %%a in ("%FAV%") do (
    set /a fj+=1
    if "!fj!"=="%fsel%" (
        set "FNAME=%%a"
        set "FCMD=%%b"
    )
)
if not defined FCMD (
    echo   Invalid selection.
    pause
    goto FAVS
)
echo.
echo   %A%Running:%R% !FCMD!
echo.
call :LOG "Favorite run > !FNAME!"
cmd /v:off /c "!FCMD!"
echo.
pause
goto FAVS

:FAV_ADD
set "fn="
set "fcm="
set /p "fn=  Name (e.g. Flush DNS): "
set /p "fcm=  Command (e.g. ipconfig /flushdns): "
if not defined fn goto FAVS
if not defined fcm goto FAVS
set "fn=!fn:|=-!"
>>"%FAV%" echo !fn!^|!fcm!
call :LOG "Favorite added > !fn!"
goto FAVS

:FAV_DEL
set "dn="
set /p "dn=  Number to remove: "
if not defined dn goto FAVS
set /a "fk=0"
>"%FAV%.tmp" (
    for /f "usebackq delims=" %%L in ("%FAV%") do (
        set /a fk+=1
        if "!fk!" neq "%dn%" echo %%L
    )
)
move /y "%FAV%.tmp" "%FAV%" >nul
call :LOG "Favorite removed > #%dn%"
goto FAVS

:: ============================================================
:: SELF-UPDATE - compares VER with version.txt in your GitHub repo
:DOCHECK
set "UPDSTAT=ERR"
set "UPDV="
if /i "%GH_USER%"=="YOUR-USERNAME" (
    set "UPDSTAT=NOCFG"
    exit /b
)
set "URLV=https://raw.githubusercontent.com/%GH_USER%/%GH_REPO%/%GH_BRANCH%/version.txt"
for /f "usebackq tokens=1,2" %%a in (`powershell -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $l=(Invoke-WebRequest -UseBasicParsing -TimeoutSec 6 '%URLV%').Content.Trim(); if([version]$l -gt [version]'%VER%'){'NEW '+$l}else{'OK '+$l}}catch{'ERR x'}"`) do (
    set "UPDSTAT=%%a"
    set "UPDV=%%b"
)
exit /b

:SELFUPDATE
cls
call :HEADER
echo %A%  --- CHECK FOR UPDATES ---%R%
echo   Installed version: v%VER%
echo.
call :LOG "Manual update check"
if /i "%GH_USER%"=="YOUR-USERNAME" goto SU_NOCFG
echo   Contacting GitHub...
call :DOCHECK
if "%UPDSTAT%"=="NEW" goto SU_NEW
if "%UPDSTAT%"=="OK" goto SU_OK
goto SU_ERR

:SU_NOCFG
echo   %E%Self-update is not configured yet.%R%
echo   Open bettercmd.bat in a text editor and set GH_USER and GH_REPO
echo   near the top to your GitHub username and repository name.
echo.
pause
goto MAIN

:SU_ERR
echo   %E%Could not check for updates.%R%
echo   Check your internet connection and that this file exists:
echo   %D%%URLV%%R%
echo.
pause
goto MAIN

:SU_OK
echo   %G%You are up to date.%R% Latest version: v%UPDV%
set "CFG_LASTCHECK=%date%"
set "UPDMSG="
call :SAVECFG
echo.
pause
goto MAIN

:SU_NEW
echo   %Y%New version available: v%UPDV%%R%
echo   %D%https://github.com/%GH_USER%/%GH_REPO%/releases%R%
echo.
set "yn="
set /p "yn=  Download and install it now? (Y/N): "
if /i not "%yn%"=="Y" goto MAIN

:SU_APPLY
set "NEWF=%SELFDIR%bettercmd.update.tmp"
set "NEWQ=%NEWF:'=''%"
set "URLB=https://raw.githubusercontent.com/%GH_USER%/%GH_REPO%/%GH_BRANCH%/bettercmd.bat"
echo   Downloading...
powershell -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $t=(Invoke-WebRequest -UseBasicParsing -TimeoutSec 20 '%URLB%').Content; if($t -notmatch '@echo off'){throw 'bad file'}; $t=$t -replace '\r?\n',[Environment]::NewLine; [IO.File]::WriteAllText('%NEWQ%',$t,[Text.Encoding]::ASCII)}catch{exit 1}"
if errorlevel 1 goto SU_ERR
if not exist "%NEWF%" goto SU_ERR
set "UPDS=%TEMP%\bettercmd_apply.cmd"
>"%UPDS%" echo @echo off
>>"%UPDS%" echo timeout /t 2 /nobreak ^>nul
>>"%UPDS%" echo move /y "%NEWF%" "%SELF%" ^>nul
>>"%UPDS%" echo if errorlevel 1 goto fail
>>"%UPDS%" echo start "" "%SELF%"
>>"%UPDS%" echo exit /b
>>"%UPDS%" echo :fail
>>"%UPDS%" echo echo Update failed. Try running Better CMD as administrator.
>>"%UPDS%" echo pause
call :LOG "Updating to v%UPDV%"
echo   Installing and restarting...
start "" "%UPDS%"
exit

:: ============================================================
:SYSINFO
cls
call :HEADER
echo %A%  --- SYSTEM INFORMATION ---%R%
echo   %Y%[1]%R% Full system info
echo   %Y%[2]%R% Windows version
echo   %Y%[3]%R% CPU, RAM and BIOS summary
echo   %Y%[4]%R% Installed drivers
echo   %Y%[5]%R% Installed programs
echo   %Y%[6]%R% Installed Windows patches
echo   %Y%[7]%R% Windows activation status
echo   %Y%[8]%R% Environment variables
echo   %Y%[9]%R% Battery report (laptops)
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "System Information > Full system info"
if "%c%"=="1" systeminfo & goto SYSINFO_B
if "%c%"=="2" call :LOG "System Information > Windows version"
if "%c%"=="2" ver & powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem) | Select Caption,Version,BuildNumber,OSArchitecture | Format-List" & goto SYSINFO_B
if "%c%"=="3" call :LOG "System Information > CPU, RAM and BIOS summary"
if "%c%"=="3" powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select Name,NumberOfCores,NumberOfLogicalProcessors | Format-List; Get-CimInstance Win32_ComputerSystem | Select Manufacturer,Model,@{n='RAM_GB';e={[math]::Round($_.TotalPhysicalMemory/1GB,1)}} | Format-List; Get-CimInstance Win32_BIOS | Select SMBIOSBIOSVersion,ReleaseDate | Format-List" & goto SYSINFO_B
if "%c%"=="4" call :LOG "System Information > Installed drivers"
if "%c%"=="4" driverquery /v | more & goto SYSINFO_B
if "%c%"=="5" call :LOG "System Information > Installed programs"
if "%c%"=="5" winget list & goto SYSINFO_B
if "%c%"=="6" call :LOG "System Information > Installed Windows patches"
if "%c%"=="6" powershell -NoProfile -Command "Get-HotFix | Sort InstalledOn -Descending | Format-Table -AutoSize" & goto SYSINFO_B
if "%c%"=="7" call :LOG "System Information > Windows activation status"
if "%c%"=="7" cscript //nologo %windir%\system32\slmgr.vbs /xpr & goto SYSINFO_B
if "%c%"=="8" call :LOG "System Information > Environment variables"
if "%c%"=="8" set | more & goto SYSINFO_B
if "%c%"=="9" call :LOG "System Information > Battery report (laptops)"
if "%c%"=="9" goto SYS_BATT
if "%c%"=="0" goto MAIN
goto SYSINFO
:SYS_BATT
call :GETDESK
del /q "!DESK!\battery-report.html" >nul 2>&1
powercfg /batteryreport /output "!DESK!\battery-report.html"
if exist "!DESK!\battery-report.html" echo Saved to "!DESK!\battery-report.html"
if not exist "!DESK!\battery-report.html" echo No battery report was created. This PC may not have a battery.
goto SYSINFO_B
:SYSINFO_B
echo.
pause
goto SYSINFO

:: ============================================================
:NETWORK
cls
call :HEADER
echo %A%  --- NETWORK TOOLS ---%R%
echo   %Y%[1]%R%  Show IP configuration
echo   %Y%[2]%R%  Show public IP address
echo   %Y%[3]%R%  Ping a host
echo   %Y%[4]%R%  Trace route to a host
echo   %Y%[5]%R%  DNS lookup
echo   %Y%[6]%R%  Flush DNS cache
echo   %Y%[7]%R%  Release and renew IP
echo   %Y%[8]%R%  Active connections and ports
echo   %Y%[9]%R%  Saved Wi-Fi networks
echo   %Y%[10]%R% Show password of a saved Wi-Fi
echo   %Y%[11]%R% Available Wi-Fi networks nearby
echo   %Y%[12]%R% Reset network stack (admin, restart needed)
echo   %Y%[13]%R% Show MAC addresses
echo   %Y%[14]%R% ARP table
echo   %Y%[15]%R% Internet connection check (ping Google/Cloudflare)
echo   %Y%[0]%R%  Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Network Tools > Show IP configuration"
if "%c%"=="1"  ipconfig /all & goto NET_B
if "%c%"=="2" call :LOG "Network Tools > Show public IP address"
if "%c%"=="2"  powershell -NoProfile -Command "try{(Invoke-RestMethod https://api.ipify.org)}catch{'Could not reach the internet'}" & goto NET_B
if "%c%"=="3" call :LOG "Network Tools > Ping a host"
if "%c%"=="3"  goto NET_PING
if "%c%"=="4" call :LOG "Network Tools > Trace route to a host"
if "%c%"=="4"  goto NET_TRACE
if "%c%"=="5" call :LOG "Network Tools > DNS lookup"
if "%c%"=="5"  goto NET_DNS
if "%c%"=="6" call :LOG "Network Tools > Flush DNS cache"
if "%c%"=="6"  ipconfig /flushdns & goto NET_B
if "%c%"=="7" call :LOG "Network Tools > Release and renew IP"
if "%c%"=="7"  ipconfig /release & ipconfig /renew & goto NET_B
if "%c%"=="8" call :LOG "Network Tools > Active connections and ports"
if "%c%"=="8"  netstat -ano | more & goto NET_B
if "%c%"=="9" call :LOG "Network Tools > Saved Wi-Fi networks"
if "%c%"=="9"  netsh wlan show profiles & goto NET_B
if "%c%"=="10" call :LOG "Network Tools > Show password of a saved Wi-Fi"
if "%c%"=="10" goto NET_WIFIPASS
if "%c%"=="11" call :LOG "Network Tools > Available Wi-Fi networks nearby"
if "%c%"=="11" netsh wlan show networks mode=bssid | more & goto NET_B
if "%c%"=="12" call :LOG "Network Tools > Reset network stack (admin, restart needed)"
if "%c%"=="12" goto NET_RESET
if "%c%"=="13" call :LOG "Network Tools > Show MAC addresses"
if "%c%"=="13" getmac /v & goto NET_B
if "%c%"=="14" call :LOG "Network Tools > ARP table"
if "%c%"=="14" arp -a & goto NET_B
if "%c%"=="15" call :LOG "Network Tools > Internet connection check (ping Google/Cloudflare)"
if "%c%"=="15" ping -n 4 8.8.8.8 & ping -n 4 1.1.1.1 & goto NET_B
if "%c%"=="0"  goto MAIN
goto NETWORK
:NET_PING
set "h="
set /p "h=  Host or IP to ping: "
if defined h ping "%h%"
goto NET_B
:NET_TRACE
set "h="
set /p "h=  Host or IP to trace: "
if defined h tracert "%h%"
goto NET_B
:NET_DNS
set "h="
set /p "h=  Domain to look up: "
if defined h nslookup "%h%"
goto NET_B
:NET_WIFIPASS
set "w="
set /p "w=  Wi-Fi profile name: "
if defined w netsh wlan show profile name="%w%" key=clear | findstr /i "SSID Authentication Key"
goto NET_B
:NET_RESET
call :REQADMIN || goto NET_B
echo This resets Winsock, TCP/IP and DNS. A restart is required afterward.
set "yn="
set /p "yn=  Continue? (Y/N): "
if /i not "%yn%"=="Y" goto NETWORK
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
echo Done. Please restart your PC.
goto NET_B
:NET_B
echo.
pause
goto NETWORK

:: ============================================================
:UPDATES
cls
call :HEADER
echo %A%  --- UPDATES ^& PACKAGE MANAGERS ---%R%
echo   %Y%[1]%R%  winget: list available upgrades
echo   %Y%[2]%R%  winget: upgrade ALL apps
echo   %Y%[3]%R%  winget: upgrade ALL (include unknown versions)
echo   %Y%[4]%R%  winget: search an app
echo   %Y%[5]%R%  winget: install an app by name or ID
echo   %Y%[6]%R%  winget: uninstall an app
echo   %Y%[7]%R%  winget: export installed apps to Desktop
echo   %Y%[8]%R%  winget: import apps from Desktop list
echo   %Y%[9]%R%  Chocolatey: upgrade all
echo   %Y%[10]%R% Scoop: update all
echo   %Y%[11]%R% npm: update global packages
echo   %Y%[12]%R% pip: upgrade pip
echo   %Y%[13]%R% Windows Update: scan and install
echo   %Y%[14]%R% Open Windows Update settings
echo   %Y%[0]%R%  Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Updates And Package Managers > winget: list available upgrades"
if "%c%"=="1"  winget upgrade & goto UPD_B
if "%c%"=="2" call :LOG "Updates And Package Managers > winget: upgrade ALL apps"
if "%c%"=="2"  winget upgrade --all --silent --accept-package-agreements --accept-source-agreements & goto UPD_B
if "%c%"=="3" call :LOG "Updates And Package Managers > winget: upgrade ALL (include unknown versions)"
if "%c%"=="3"  winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements & goto UPD_B
if "%c%"=="4" call :LOG "Updates And Package Managers > winget: search an app"
if "%c%"=="4"  goto UPD_SEARCH
if "%c%"=="5" call :LOG "Updates And Package Managers > winget: install an app by name or ID"
if "%c%"=="5"  goto UPD_INSTALL
if "%c%"=="6" call :LOG "Updates And Package Managers > winget: uninstall an app"
if "%c%"=="6"  goto UPD_UNINSTALL
if "%c%"=="7" call :LOG "Updates And Package Managers > winget: export installed apps to Desktop"
if "%c%"=="7"  call :GETDESK & winget export -o "!DESK!\apps.json" & goto UPD_B
if "%c%"=="8" call :LOG "Updates And Package Managers > winget: import apps from Desktop list"
if "%c%"=="8"  call :GETDESK & winget import -i "!DESK!\apps.json" --accept-package-agreements --accept-source-agreements & goto UPD_B
if "%c%"=="9" call :LOG "Updates And Package Managers > Chocolatey: upgrade all"
if "%c%"=="9"  call :RUNIF choco "choco upgrade all -y" & goto UPD_B
if "%c%"=="10" call :LOG "Updates And Package Managers > Scoop: update all"
if "%c%"=="10" call :RUNIF scoop "scoop update *" & goto UPD_B
if "%c%"=="11" call :LOG "Updates And Package Managers > npm: update global packages"
if "%c%"=="11" call :RUNIF npm "npm update -g" & goto UPD_B
if "%c%"=="12" call :LOG "Updates And Package Managers > pip: upgrade pip"
if "%c%"=="12" call :RUNIF python "python -m pip install --upgrade pip" & goto UPD_B
if "%c%"=="13" call :LOG "Updates And Package Managers > Windows Update: scan and install"
if "%c%"=="13" usoclient StartScan & usoclient StartDownload & usoclient StartInstall & echo Windows Update commands sent. Open Windows Update in Settings to see progress. & goto UPD_B
if "%c%"=="14" call :LOG "Updates And Package Managers > Open Windows Update settings"
if "%c%"=="14" start ms-settings:windowsupdate & goto UPDATES
if "%c%"=="0"  goto MAIN
goto UPDATES
:UPD_SEARCH
set "app="
set /p "app=  App name to search: "
if defined app winget search "%app%"
goto UPD_B
:UPD_INSTALL
set "app="
set /p "app=  App name or ID to install: "
if defined app winget install "%app%" --accept-package-agreements --accept-source-agreements
goto UPD_B
:UPD_UNINSTALL
set "app="
set /p "app=  App name or ID to uninstall: "
if defined app winget uninstall "%app%"
goto UPD_B
:UPD_B
echo.
pause
goto UPDATES

:: helper: run a command only if the tool exists
:RUNIF
where %~1 >nul 2>&1
if errorlevel 1 (
    echo [skipped] %~1 is not installed.
) else (
    call %~2
)
exit /b

:: ============================================================
:UPDATEALL
cls
call :HEADER
echo %A%  --- UPDATING EVERYTHING ---%R%
call :LOG "Update everything started"
echo.
echo %Y%[1/7]%R% winget
call :LOG "Update everything step 1/7 > winget"
call :RUNIF winget "winget upgrade --all --silent --accept-package-agreements --accept-source-agreements"
echo.
echo %Y%[2/7]%R% Chocolatey
call :LOG "Update everything step 2/7 > Chocolatey"
call :RUNIF choco "choco upgrade all -y"
echo.
echo %Y%[3/7]%R% Scoop
call :LOG "Update everything step 3/7 > Scoop"
call :RUNIF scoop "scoop update *"
echo.
echo %Y%[4/7]%R% npm global packages
call :LOG "Update everything step 4/7 > npm global packages"
call :RUNIF npm "npm update -g"
echo.
echo %Y%[5/7]%R% pip
call :LOG "Update everything step 5/7 > pip"
call :RUNIF python "python -m pip install --upgrade pip"
echo.
echo %Y%[6/7]%R% Microsoft Defender definitions
call :LOG "Update everything step 6/7 > Microsoft Defender definitions"
if exist "%ProgramFiles%\Windows Defender\MpCmdRun.exe" "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
echo.
echo %Y%[7/7]%R% Windows Update
call :LOG "Update everything step 7/7 > Windows Update"
usoclient StartScan
usoclient StartDownload
usoclient StartInstall
echo   Windows Update commands sent. Open Windows Update in Settings to see progress.
call :LOG "Update everything finished"
echo.
echo %G%All done.%R% Log: %LOGFILE%
echo.
pause
goto MAIN

:: ============================================================
:REPAIR
cls
call :HEADER
echo %A%  --- SYSTEM REPAIR (admin required) ---%R%
echo   %Y%[1]%R% SFC: scan and repair system files
echo   %Y%[2]%R% DISM: check image health
echo   %Y%[3]%R% DISM: scan image health
echo   %Y%[4]%R% DISM: restore image health
echo   %Y%[5]%R% CHKDSK: scan C: drive (read-only)
echo   %Y%[6]%R% CHKDSK: fix C: on next restart
echo   %Y%[7]%R% Re-register all Store apps
echo   %Y%[8]%R% Rebuild icon cache
echo   %Y%[9]%R% Reset Windows Update components
echo   %Y%[10]%R% Create a system restore point
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "System Repair > SFC: scan and repair system files"
if "%c%"=="1"  sfc /scannow & goto REP_B
if "%c%"=="2" call :LOG "System Repair > DISM: check image health"
if "%c%"=="2"  DISM /Online /Cleanup-Image /CheckHealth & goto REP_B
if "%c%"=="3" call :LOG "System Repair > DISM: scan image health"
if "%c%"=="3"  DISM /Online /Cleanup-Image /ScanHealth & goto REP_B
if "%c%"=="4" call :LOG "System Repair > DISM: restore image health"
if "%c%"=="4"  DISM /Online /Cleanup-Image /RestoreHealth & goto REP_B
if "%c%"=="5" call :LOG "System Repair > CHKDSK: scan C: drive (read-only)"
if "%c%"=="5"  chkdsk C: & goto REP_B
if "%c%"=="6" call :LOG "System Repair > CHKDSK: fix C: on next restart"
if "%c%"=="6"  chkdsk C: /f /r & goto REP_B
if "%c%"=="7" call :LOG "System Repair > Re-register all Store apps"
if "%c%"=="7"  powershell -NoProfile -Command "Get-AppxPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\" -ErrorAction SilentlyContinue}" & goto REP_B
if "%c%"=="8" call :LOG "System Repair > Rebuild icon cache"
if "%c%"=="8"  goto REP_ICON
if "%c%"=="9" call :LOG "System Repair > Reset Windows Update components"
if "%c%"=="9"  goto REP_WU
if "%c%"=="10" call :LOG "System Repair > Create a system restore point"
if "%c%"=="10" powershell -NoProfile -Command "Enable-ComputerRestore -Drive 'C:\'; Checkpoint-Computer -Description 'BetterCMD restore point' -RestorePointType MODIFY_SETTINGS" & goto REP_B
if "%c%"=="0"  goto MAIN
goto REPAIR
:REP_ICON
taskkill /f /im explorer.exe >nul 2>&1
del /a /q "%localappdata%\IconCache.db" >nul 2>&1
del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
start explorer.exe
echo Icon cache rebuilt.
goto REP_B
:REP_WU
call :REQADMIN || goto REP_B
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1
rd /s /q "%windir%\SoftwareDistribution" >nul 2>&1
rd /s /q "%windir%\System32\catroot2" >nul 2>&1
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
echo Windows Update components reset.
goto REP_B
:REP_B
echo.
pause
goto REPAIR

:: ============================================================
:CLEANUP
cls
call :HEADER
echo %A%  --- CLEANUP ^& OPTIMIZATION ---%R%
echo   %Y%[1]%R% Delete user temp files
echo   %Y%[2]%R% Delete Windows temp files (admin)
echo   %Y%[3]%R% Empty Recycle Bin
echo   %Y%[4]%R% Clean old Windows Update files (admin)
echo   %Y%[5]%R% Open Disk Cleanup
echo   %Y%[6]%R% Open Storage Settings
echo   %Y%[7]%R% Clear DNS cache
echo   %Y%[8]%R% Show startup programs
echo   %Y%[9]%R% Run ALL safe cleanups (1, 3, 7)
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Cleanup And Optimization > Delete user temp files"
if "%c%"=="1" call :CLEAN_USERTEMP & goto CLN_B
if "%c%"=="2" call :LOG "Cleanup And Optimization > Delete Windows temp files (admin)"
if "%c%"=="2" call :CLEAN_WINTEMP & goto CLN_B
if "%c%"=="3" call :LOG "Cleanup And Optimization > Empty Recycle Bin"
if "%c%"=="3" powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" & echo Recycle Bin emptied. & goto CLN_B
if "%c%"=="4" call :LOG "Cleanup And Optimization > Clean old Windows Update files (admin)"
if "%c%"=="4" DISM /Online /Cleanup-Image /StartComponentCleanup & goto CLN_B
if "%c%"=="5" call :LOG "Cleanup And Optimization > Open Disk Cleanup"
if "%c%"=="5" start cleanmgr & goto CLEANUP
if "%c%"=="6" call :LOG "Cleanup And Optimization > Open Storage Settings"
if "%c%"=="6" start ms-settings:storagesense & goto CLEANUP
if "%c%"=="7" call :LOG "Cleanup And Optimization > Clear DNS cache"
if "%c%"=="7" ipconfig /flushdns & goto CLN_B
if "%c%"=="8" call :LOG "Cleanup And Optimization > Show startup programs"
if "%c%"=="8" powershell -NoProfile -Command "Get-CimInstance Win32_StartupCommand | Select Name,Command,Location | Format-Table -AutoSize" & goto CLN_B
if "%c%"=="9" call :LOG "Cleanup And Optimization > Run ALL safe cleanups (1, 3, 7)"
if "%c%"=="9" call :CLEAN_USERTEMP & powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" & ipconfig /flushdns & goto CLN_B
if "%c%"=="0" goto MAIN
goto CLEANUP
:CLEAN_USERTEMP
del /q /f /s "%TEMP%\*" >nul 2>&1
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" >nul 2>&1
echo User temp files deleted.
exit /b
:CLEAN_WINTEMP
call :REQADMIN || exit /b 1
del /q /f /s "%windir%\Temp\*" >nul 2>&1
for /d %%i in ("%windir%\Temp\*") do rd /s /q "%%i" >nul 2>&1
echo Windows temp files deleted.
exit /b
:CLN_B
echo.
pause
goto CLEANUP

:: ============================================================
:PROCS
cls
call :HEADER
echo %A%  --- PROCESSES ^& SERVICES ---%R%
echo   %Y%[1]%R% List running processes
echo   %Y%[2]%R% Find a process by name
echo   %Y%[3]%R% Kill a process by name
echo   %Y%[4]%R% Kill a process by PID
echo   %Y%[5]%R% Top 10 processes by memory
echo   %Y%[6]%R% List running services
echo   %Y%[7]%R% Start a service
echo   %Y%[8]%R% Stop a service
echo   %Y%[9]%R% Restart a service
echo   %Y%[10]%R% Open Task Manager
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Processes And Services > List running processes"
if "%c%"=="1"  tasklist | more & goto PRC_B
if "%c%"=="2" call :LOG "Processes And Services > Find a process by name"
if "%c%"=="2"  goto PRC_FIND
if "%c%"=="3" call :LOG "Processes And Services > Kill a process by name"
if "%c%"=="3"  goto PRC_KILLN
if "%c%"=="4" call :LOG "Processes And Services > Kill a process by PID"
if "%c%"=="4"  goto PRC_KILLP
if "%c%"=="5" call :LOG "Processes And Services > Top 10 processes by memory"
if "%c%"=="5"  powershell -NoProfile -Command "Get-Process | Sort WorkingSet -Descending | Select -First 10 Name,Id,@{n='MemMB';e={[math]::Round($_.WorkingSet/1MB)}} | Format-Table -AutoSize" & goto PRC_B
if "%c%"=="6" call :LOG "Processes And Services > List running services"
if "%c%"=="6"  net start | more & goto PRC_B
if "%c%"=="7" call :LOG "Processes And Services > Start a service"
if "%c%"=="7"  goto SVC_START
if "%c%"=="8" call :LOG "Processes And Services > Stop a service"
if "%c%"=="8"  goto SVC_STOP
if "%c%"=="9" call :LOG "Processes And Services > Restart a service"
if "%c%"=="9"  goto SVC_RESTART
if "%c%"=="10" call :LOG "Processes And Services > Open Task Manager"
if "%c%"=="10" start taskmgr & goto PROCS
if "%c%"=="0"  goto MAIN
goto PROCS
:PRC_FIND
set "p="
set /p "p=  Process name (e.g. chrome): "
if defined p tasklist | findstr /i "%p%"
goto PRC_B
:PRC_KILLN
set "p="
set /p "p=  Process image name (e.g. notepad.exe): "
if defined p taskkill /f /im "%p%"
goto PRC_B
:PRC_KILLP
set "p="
set /p "p=  PID: "
if defined p taskkill /f /pid %p%
goto PRC_B
:SVC_START
set "s="
set /p "s=  Service name: "
if defined s net start "%s%"
goto PRC_B
:SVC_STOP
set "s="
set /p "s=  Service name: "
if defined s net stop "%s%"
goto PRC_B
:SVC_RESTART
set "s="
set /p "s=  Service name: "
if defined s net stop "%s%" & net start "%s%"
goto PRC_B
:PRC_B
echo.
pause
goto PROCS

:: ============================================================
:DISK
cls
call :HEADER
echo %A%  --- DISK ^& STORAGE ---%R%
echo   %Y%[1]%R% Show drives and free space
echo   %Y%[2]%R% Physical disk health
echo   %Y%[3]%R% Optimize / TRIM drive C:
echo   %Y%[4]%R% Show largest folders in user profile
echo   %Y%[5]%R% Show folder size
echo   %Y%[6]%R% Open Disk Management
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Disk And Storage > Show drives and free space"
if "%c%"=="1" powershell -NoProfile -Command "Get-Volume | Where DriveLetter | Select DriveLetter,FileSystemLabel,@{n='SizeGB';e={[math]::Round($_.Size/1GB,1)}},@{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB,1)}} | Format-Table -AutoSize" & goto DSK_B
if "%c%"=="2" call :LOG "Disk And Storage > Physical disk health"
if "%c%"=="2" powershell -NoProfile -Command "Get-PhysicalDisk | Select FriendlyName,MediaType,HealthStatus,OperationalStatus,@{n='SizeGB';e={[math]::Round($_.Size/1GB)}} | Format-Table -AutoSize" & goto DSK_B
if "%c%"=="3" call :LOG "Disk And Storage > Optimize / TRIM drive C:"
if "%c%"=="3" defrag C: /O /U /V & goto DSK_B
if "%c%"=="4" call :LOG "Disk And Storage > Show largest folders in user profile"
if "%c%"=="4" powershell -NoProfile -Command "Get-ChildItem $env:USERPROFILE -Directory | ForEach-Object {$s=(Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure Length -Sum).Sum; [pscustomobject]@{Folder=$_.Name;SizeGB=[math]::Round($s/1GB,2)}} | Sort SizeGB -Descending | Format-Table -AutoSize" & goto DSK_B
if "%c%"=="5" call :LOG "Disk And Storage > Show folder size"
if "%c%"=="5" goto DSK_SIZE
if "%c%"=="6" call :LOG "Disk And Storage > Open Disk Management"
if "%c%"=="6" start diskmgmt.msc & goto DISK
if "%c%"=="0" goto MAIN
goto DISK
:DSK_SIZE
set "f="
set /p "f=  Folder path: "
if not defined f goto DSK_B
call :UNQ f
set "fq=!f:'=''!"
powershell -NoProfile -Command "$s=(Get-ChildItem -LiteralPath '!fq!' -Recurse -File -ErrorAction SilentlyContinue | Measure Length -Sum).Sum; '{0:N2} GB' -f ($s/1GB)"
goto DSK_B
:DSK_B
echo.
pause
goto DISK

:: ============================================================
:SECURITY
cls
call :HEADER
echo %A%  --- SECURITY ^& DEFENDER ---%R%
echo   %Y%[1]%R% Update Defender definitions
echo   %Y%[2]%R% Quick scan
echo   %Y%[3]%R% Full scan
echo   %Y%[4]%R% Defender status
echo   %Y%[5]%R% Firewall status
echo   %Y%[6]%R% List local user accounts
echo   %Y%[7]%R% Show logged-in users
echo   %Y%[8]%R% Open Windows Security
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Security And Defender > Update Defender definitions"
if "%c%"=="1" powershell -NoProfile -Command "Update-MpSignature" & goto SEC_B
if "%c%"=="2" call :LOG "Security And Defender > Quick scan"
if "%c%"=="2" powershell -NoProfile -Command "Start-MpScan -ScanType QuickScan" & goto SEC_B
if "%c%"=="3" call :LOG "Security And Defender > Full scan"
if "%c%"=="3" powershell -NoProfile -Command "Start-MpScan -ScanType FullScan" & goto SEC_B
if "%c%"=="4" call :LOG "Security And Defender > Defender status"
if "%c%"=="4" powershell -NoProfile -Command "Get-MpComputerStatus | Select AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated,QuickScanEndTime | Format-List" & goto SEC_B
if "%c%"=="5" call :LOG "Security And Defender > Firewall status"
if "%c%"=="5" netsh advfirewall show allprofiles state & goto SEC_B
if "%c%"=="6" call :LOG "Security And Defender > List local user accounts"
if "%c%"=="6" net user & goto SEC_B
if "%c%"=="7" call :LOG "Security And Defender > Show logged-in users"
if "%c%"=="7" powershell -NoProfile -Command "Get-CimInstance Win32_LogonSession | Where-Object {$_.LogonType -in 2,10,11} | ForEach-Object {$u=Get-CimAssociatedInstance -InputObject $_ -Association Win32_LoggedOnUser; [pscustomobject]@{User=($u.Domain+'\'+$u.Name);LogonType=$_.LogonType;Started=$_.StartTime}} | Format-Table -AutoSize" & goto SEC_B
if "%c%"=="8" call :LOG "Security And Defender > Open Windows Security"
if "%c%"=="8" start windowsdefender: & goto SECURITY
if "%c%"=="0" goto MAIN
goto SECURITY
:SEC_B
echo.
pause
goto SECURITY

:: ============================================================
:FILES
cls
call :HEADER
echo %A%  --- FILES ^& FOLDERS ---%R%
echo   %Y%[1]%R% List files in a folder
echo   %Y%[2]%R% Folder tree
echo   %Y%[3]%R% Search for a file by name
echo   %Y%[4]%R% Search text inside files
echo   %Y%[5]%R% Show file contents
echo   %Y%[6]%R% Compare two files
echo   %Y%[7]%R% Copy folder (robocopy)
echo   %Y%[8]%R% Show hidden files in a folder
echo   %Y%[9]%R% Open a folder in Explorer
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Files And Folders > List files in a folder"
if "%c%"=="1" goto F_LIST
if "%c%"=="2" call :LOG "Files And Folders > Folder tree"
if "%c%"=="2" goto F_TREE
if "%c%"=="3" call :LOG "Files And Folders > Search for a file by name"
if "%c%"=="3" goto F_FIND
if "%c%"=="4" call :LOG "Files And Folders > Search text inside files"
if "%c%"=="4" goto F_GREP
if "%c%"=="5" call :LOG "Files And Folders > Show file contents"
if "%c%"=="5" goto F_TYPE
if "%c%"=="6" call :LOG "Files And Folders > Compare two files"
if "%c%"=="6" goto F_FC
if "%c%"=="7" call :LOG "Files And Folders > Copy folder (robocopy)"
if "%c%"=="7" goto F_COPY
if "%c%"=="8" call :LOG "Files And Folders > Show hidden files in a folder"
if "%c%"=="8" goto F_HIDDEN
if "%c%"=="9" call :LOG "Files And Folders > Open a folder in Explorer"
if "%c%"=="9" goto F_OPEN
if "%c%"=="0" goto MAIN
goto FILES
:F_LIST
set "f="
set /p "f=  Folder path: "
call :UNQ f
if defined f dir "%f%"
goto F_B
:F_TREE
set "f="
set /p "f=  Folder path: "
call :UNQ f
if defined f tree "%f%" /f | more
goto F_B
:F_FIND
set "f="
set "n="
set /p "f=  Start folder (e.g. C:\): "
set /p "n=  File name or pattern (e.g. *.pdf): "
call :UNQ f
if defined f if defined n dir "%f%\%n%" /s /b
goto F_B
:F_GREP
set "f="
set "t="
set /p "f=  Folder path: "
set /p "t=  Text to find: "
call :UNQ f
if defined f if defined t findstr /s /i /n /c:"%t%" "%f%\*.*"
goto F_B
:F_TYPE
set "f="
set /p "f=  File path: "
call :UNQ f
if defined f type "%f%" | more
goto F_B
:F_FC
set "f1="
set "f2="
set /p "f1=  First file: "
set /p "f2=  Second file: "
call :UNQ f1
call :UNQ f2
if defined f1 if defined f2 fc "%f1%" "%f2%"
goto F_B
:F_COPY
set "src="
set "dst="
set /p "src=  Source folder: "
set /p "dst=  Destination folder: "
call :UNQ src
call :UNQ dst
if defined src if defined dst robocopy "%src%" "%dst%" /E /R:1 /W:1
goto F_B
:F_HIDDEN
set "f="
set /p "f=  Folder path: "
call :UNQ f
if defined f dir "%f%" /a:h
goto F_B
:F_OPEN
set "f="
set /p "f=  Folder path: "
call :UNQ f
if defined f start "" explorer "%f%"
goto FILES
:F_B
echo.
pause
goto FILES

:: ============================================================
:LAUNCH
cls
call :HEADER
echo %A%  --- QUICK LAUNCH ---%R%
echo   %Y%[1]%R%  Task Manager          %Y%[8]%R%  Registry Editor
echo   %Y%[2]%R%  Control Panel         %Y%[9]%R%  Programs and Features
echo   %Y%[3]%R%  Device Manager        %Y%[10]%R% Network Connections
echo   %Y%[4]%R%  Disk Management       %Y%[11]%R% System Properties
echo   %Y%[5]%R%  Services              %Y%[12]%R% Event Viewer
echo   %Y%[6]%R%  System Configuration  %Y%[13]%R% Resource Monitor
echo   %Y%[7]%R%  Windows Settings      %Y%[14]%R% Windows Terminal
echo   %Y%[0]%R%  Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Quick Launch > Task Manager"
if "%c%"=="1"  start taskmgr
if "%c%"=="2" call :LOG "Quick Launch > Control Panel"
if "%c%"=="2"  start control
if "%c%"=="3" call :LOG "Quick Launch > Device Manager"
if "%c%"=="3"  start devmgmt.msc
if "%c%"=="4" call :LOG "Quick Launch > Disk Management"
if "%c%"=="4"  start diskmgmt.msc
if "%c%"=="5" call :LOG "Quick Launch > Services"
if "%c%"=="5"  start services.msc
if "%c%"=="6" call :LOG "Quick Launch > System Configuration"
if "%c%"=="6"  start msconfig
if "%c%"=="7" call :LOG "Quick Launch > Windows Settings"
if "%c%"=="7"  start ms-settings:
if "%c%"=="8" call :LOG "Quick Launch > Registry Editor"
if "%c%"=="8"  start regedit
if "%c%"=="9" call :LOG "Quick Launch > Programs and Features"
if "%c%"=="9"  start appwiz.cpl
if "%c%"=="10" call :LOG "Quick Launch > Network Connections"
if "%c%"=="10" start ncpa.cpl
if "%c%"=="11" call :LOG "Quick Launch > System Properties"
if "%c%"=="11" start sysdm.cpl
if "%c%"=="12" call :LOG "Quick Launch > Event Viewer"
if "%c%"=="12" start eventvwr.msc
if "%c%"=="13" call :LOG "Quick Launch > Resource Monitor"
if "%c%"=="13" start resmon
if "%c%"=="14" call :LOG "Quick Launch > Windows Terminal"
if "%c%"=="14" start wt
if "%c%"=="0"  goto MAIN
goto LAUNCH

:: ============================================================
:POWER
cls
call :HEADER
echo %A%  --- POWER ^& SHUTDOWN ---%R%
echo   %Y%[1]%R% Shut down now
echo   %Y%[2]%R% Restart now
echo   %Y%[3]%R% Shut down in X minutes
echo   %Y%[4]%R% Cancel scheduled shutdown
echo   %Y%[5]%R% Log off
echo   %Y%[6]%R% Sleep
echo   %Y%[7]%R% Restart into Advanced Startup / BIOS menu
echo   %Y%[8]%R% Show power plans
echo   %Y%[9]%R% Set High Performance plan
echo   %Y%[0]%R% Back
echo.
set "c="
set /p "c=  Select: "
if "%c%"=="1" call :LOG "Power And Shutdown > Shut down now"
if "%c%"=="1" shutdown /s /t 0
if "%c%"=="2" call :LOG "Power And Shutdown > Restart now"
if "%c%"=="2" shutdown /r /t 0
if "%c%"=="3" call :LOG "Power And Shutdown > Shut down in X minutes"
if "%c%"=="3" goto PWR_TIMER
if "%c%"=="4" call :LOG "Power And Shutdown > Cancel scheduled shutdown"
if "%c%"=="4" shutdown /a & goto PWR_B
if "%c%"=="5" call :LOG "Power And Shutdown > Log off"
if "%c%"=="5" shutdown /l
if "%c%"=="6" call :LOG "Power And Shutdown > Sleep"
if "%c%"=="6" rundll32.exe powrprof.dll,SetSuspendState 0,1,0
if "%c%"=="7" call :LOG "Power And Shutdown > Restart into Advanced Startup / BIOS menu"
if "%c%"=="7" shutdown /r /o /t 0
if "%c%"=="8" call :LOG "Power And Shutdown > Show power plans"
if "%c%"=="8" powercfg /list & goto PWR_B
if "%c%"=="9" call :LOG "Power And Shutdown > Set High Performance plan"
if "%c%"=="9" powercfg /setactive SCHEME_MIN && (echo High Performance plan set.) || (echo This PC has no High Performance plan. Use option 8 to see the plans you can use.)
if "%c%"=="9" goto PWR_B
if "%c%"=="0" goto MAIN
goto POWER
:PWR_TIMER
set "m="
set /p "m=  Minutes until shutdown: "
if not defined m goto POWER
set "mbad="
for /f "delims=0123456789" %%x in ("%m%") do set "mbad=1"
if defined mbad goto PWR_TBAD
for /f "tokens=* delims=0" %%x in ("%m%") do set "m=%%x"
if not "%m:~4%"=="" goto PWR_TBAD
set /a secs=%m%*60
if %secs% LSS 60 goto PWR_TBAD
shutdown /s /t %secs%
echo   Shutdown scheduled in %m% minute(s). Use option 4 to cancel it.
goto PWR_B
:PWR_TBAD
echo   %E%Enter a whole number of minutes from 1 to 9999.%R%
goto PWR_B
:PWR_B
echo.
pause
goto POWER
