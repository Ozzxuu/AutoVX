@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Verification des privileges administrateur
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0" 

chcp 65001
setlocal enabledelayedexpansion

echo Bienvenue dans AutoW

set "installerPath=%~dp0Installer\"
set "registryPath=%~dp0Registres\"
set "wifiPath=%~dp0Wifi\"
set "scriptPath=%~dp0Scripts\"
set "appsPath=%~dp0Apps\"

set "videoExtensions=.mp4 .avi .mkv .mov .wmv .flv .webm .m4v .mpeg .mpg .3gp .ts .divx .ogv .vob .rm .rmvb .asf .m2ts .mpv"
set "audioExtensions=.mp3 .wav .wma .aac .ogg .flac .m4a .ac3 .aiff .amr .mid .midi .opus .ra .mpc .mka .pcm .au .aif .ape"
set "htmlExtensions=.html .htm .xhtml http https"
set "pdfExtensions=.pdf"
set "zipExtensions=.zip .rar"
set "exePath=.\SetUserFTA.exe"

echo Ajout du Wifi 
netsh wlan add profile filename="%wifiPath%Wifi.xml" user=all

echo Installation de TrayStatus

start "" /wait "%installerPath%TrayStatus.exe" /SILENT /LANG=fr LAUNCHAFTER=0
for /f "tokens=2" %%I in ('tasklist /nh /fi "imagename eq TrayStatus.exe"') do (
    set "trayId=%%I"
)
taskkill /pid %trayId% /f
echo TrayStatus a été installé

echo Installation de Choco
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

echo Mise en place de l'accord automatique de choco 
choco feature enable -n allowGlobalConfirmation

color 03

echo Installation de Chrome
choco install googlechrome

echo Installation de VLC
choco install vlc

echo Installation de LibreOffice
choco install libreoffice-fresh

echo Installation de 7zip
choco install 7zip

echo Installation de Classic Shell
choco install classic-shell

echo Installation de Unchecky
choco install unchecky

echo Installation de Adobe Reader
choco install adobereader

echo Désinstallation de OneDrive

start "" "C:\Windows\System32\OneDriveSetup.exe" /uninstall

echo OneDrive Desinstallé.

color 0E

echo Désactivation des Telemetry
powershell.exe -ExecutionPolicy Bypass -File %scriptPath%Telemetry.ps1

echo Désinstallation des Applications pres installé
echo ATTENTION, beaucoup d'erreurs vont apparaitre. C'est normal.
"%SystemRoot%\System32\timeout.exe" /t 3
powershell.exe -ExecutionPolicy Bypass -File %scriptPath%Remove-Apps.ps1

echo Verification de l'emplacement de Chrome.

if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "path=C:\Program Files (x86)\Google\Chrome\Application\chrome"
) else (
    set "path=C:\Program Files\Google\Chrome\Application\chrome"
)

echo Chrome trouvé : %path%
start "" "%path%"

"%SystemRoot%\System32\timeout.exe" /t 5

"%SystemRoot%\System32\taskkill.exe" /im chrome.exe /f


echo Importation des clés registres
"%SystemRoot%\regedit.exe" /s "%registryPath%All.reg"

echo Installation de Ublock Origin
"%SystemRoot%\System32\reg.exe" add HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist /v 1 /t REG_SZ /d cjpalhdlnbpafiamejdnhcphjbkeiagm /f

echo Copie des fichiers chrome
"%SystemRoot%\System32\timeout.exe" /t 2
"%SystemRoot%\System32\xcopy.exe" /s /y "%~dp0Chrome\*" "C:\Users\Utilisateur\AppData\Local\Google\Chrome\User Data\Default\"

color 9

echo Mise en place des applications par défauts...
for %%a in (%videoExtensions% %audioExtensions%) do (
	set "command=!exePath! %%a VLC"
	!command!
)

for %%b in (%htmlExtensions%) do (
	set "command=!exePath! %%b ChromeHTML"
	!command!
)

for %%c in (%pdfExtensions%) do (
	set "command=!exePath! %%c Acrobat.Document.DC"
	!command!
)

for %%d in (%zipExtensions%) do (
	set "command=!exePath! %%d 7-Zip"
	!command!
)

color A
color B
color C
Color 9

pause 6
