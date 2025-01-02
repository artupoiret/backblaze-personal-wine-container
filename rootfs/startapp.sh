#!/bin/bash
set -x

backblaze_installer_url="https://www.backblaze.com/win32/install_backblaze.exe"
log_file="${STARTUP_LOGFILE:-${WINEPREFIX}dosdevices/c:/backblaze-wine-startapp.log}"

export WINEARCH="win64"
export WINEDLLOVERRIDES="mscoree=" # Disable Mono installation
export WINETRICKS_ACCEPT_EULA=1

log_message() {
    echo "$(date): $1" >> "$log_file"
}

if [ ! -f "${WINEPREFIX}system.reg" ]; then
    echo "WINE: Wine not initialized, initializing"
    wineboot -i
    winetricks -q -f dotnet48
    log_message "WINE: Initialization done"
fi

for x in {d..z}
do
    if test -d "/drive_${x}" && ! test -d "${WINEPREFIX}dosdevices/${x}:"; then
        log_message "DRIVE: drive_${x} found but not mounted, mounting..."
        ln -s "/drive_${x}/" "${WINEPREFIX}dosdevices/${x}:"
    fi
done

cd $WINEPREFIX

if [ -n "$DISPLAY_WIDTH" ] && [ -n "$DISPLAY_HEIGHT" ]; then
    log_message "WINE: Enabling Virtual Desktop mode with $DISPLAY_WIDTH:$DISPLAY_WIDTH aspect ratio"
    winetricks vd="$DISPLAY_WIDTH"x"$DISPLAY_HEIGHT"
else
	log_message "WINE: Enabling Virtual Desktop mode with recommended aspect ratio"
	winetricks vd="1280x800"
fi

fetch_and_install() {
    log_message "Downloading latest version"
    curl -L "$backblaze_installer_url" --output "install_backblaze.exe"
        
    log_message "INSTALLER: Starting install_backblaze.exe"
    wine64 "install_backblaze.exe" "-nogui" &
	
	sleep 10
    
	cp -R "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/" "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze-safe/"
	
	sleep 2
    
	pkill -f "install_backblaze.exe"
    pkill -f "bzdoinstall.exe"
	
	sleep 2
    
	rm -rf "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/"
	
	sleep 2
	
    mv "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze-safe/" "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/"
	
	sleep 2
	
    wine64 "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/bzdoinstall.exe" -doinstall "C:\Program Files (x86)\Backblaze"
    
    log_message "Backblaze installed, login and enjoy"
}

start_app() {
    log_message "STARTAPP: Starting Backblaze"

    wine64 "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/bzbui.exe" -noquiet &
    sleep infinity
}

# ------------------------------------------------------

# Check if client is installed
if [ -f "${WINEPREFIX}drive_c/Program Files (x86)/Backblaze/bzbui.exe" ]; then
    start_app
else
    fetch_and_install &&
    start_app
fi