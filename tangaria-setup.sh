#!/bin/bash

## Script for setup Tangaria
##
README=\
'<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>
# Link to latest version: https://raw.githubusercontent.com/igroglaz/Tangaria_release/master/tangaria-setup.sh
# Github PWMAngband: https://github.com/draconisPW/PWMAngband
# PWMAngband binaries: https://powerwyrm.monsite-orange.fr/
# Github Tangaria: https://github.com/igroglaz/Tangaria
# Link to Tangaria: https://tangaria.com/
# Discord channel:https://discord.gg/zBNG369

to make script executable, use chmod +x ./tangaria-setup.sh
if you have Debian-based linux*** (Ubuntu, Mint, etc) requires: sudo apt-get install build-essential autoconf libsdl1.2debian libsdl-ttf2.0-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libncurses5-dev
***if you use RPM-based linux (Fedora, RHEL, CentOS..) the command to obtain build tools is something like: sudo dnf group install "Development Tools"
and the command to obtain all the needed libraries is: sudo dnf install SDL-devel SDL_ttf-devel SDL_mixer-devel SDL_image-devel ncurses-devel
<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>'

########### INSTALL DIR ###########

INSTALL_DIR=$HOME/Tangaria

############ USER DIR #############

USER_PWMANGBAND="$HOME/.pwmangband"
USER_PWMANGRC="$HOME/.pwmangrc"

####### ./configure --help ########

## to change directory for storing pref-files and character-dumps.
## ./configure CFLAGS=-DPRIVATE_USER_PATH=\\\"~/.pwmangband\\\"

######## make -j$CPU_CORES ########

CPU_CORES=$(cat /proc/cpuinfo | grep processor | wc -l)

###################################

REPOSITORY_NAME_TANGARIA="Tangaria"
REPOSITORY_URL_TANGARIA="https://github.com/igroglaz/Tangaria/archive/"
REPOSITORY_NAME_TANGARIA_RELEASE="Tangaria_release"
REPOSITORY_URL_TANGARIA_RELEASE="https://github.com/igroglaz/Tangaria_release/archive/"
REPOSITORY_NAME_PWMANGBAND="PWMAngband"
REPOSITORY_URL_PWMANGBAND="https://github.com/draconisPW/PWMAngband/archive/"

###################################

NAME_ROGUELIKE="Tangaria"
RADIOLIST_ROGUELIKE_TANGARIA=ON
RADIOLIST_ROGUELIKE_PWMANGBAND=OFF

VERSION_TANGARIA_STABLE="6db7e6c5e0df889eacd68759f8888add09ce54a3"
VERSION_TANGARIA_LATEST="dev"
VERSION_TANGARIA="$VERSION_TANGARIA_STABLE"
VERSION_TANGARIA_RELEASE="master"
VERSION_PWMANGBAND="master"

MENU_VERSION_SRC="default"
RADIOLIST_VERSION_SRC_STABLE=ON
RADIOLIST_VERSION_SRC_LATEST=OFF
RADIOLIST_VERSION_SRC_OTHER=OFF

MENU_CLIENT="sdl"
RADIOLIST_CLIENT_SDL=ON
RADIOLIST_CLIENT_CURSES=OFF
RADIOLIST_CLIENT_OTHER=OFF

CHECKLIST_OPTIONS_CLIENT_DESKTOP=ON
CHECKLIST_OPTIONS_SERVER_DESKTOP=ON
CHECKLIST_OPTIONS_LINK_DIR_USER=ON
CHECKLIST_OPTIONS_TANGARIA_RELEASE=ON
CHECKLIST_OPTIONS_APPIMAGE=OFF

CHECKLIST_UPDATE_DOWNLOAD_TANGARIA=ON
CHECKLIST_UPDATE_UNPACK_TANGARIA=ON
CHECKLIST_UPDATE_DOWNLOAD_TANGARIA_RELEASE=ON
CHECKLIST_UPDATE_UNPACK_TANGARIA_RELEASE=ON
CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND=ON
CHECKLIST_UPDATE_UNPACK_PWMANGBAND=ON

###################################

if (command -v whiptail >/dev/null)
then
  DIALOG=${DIALOG=whiptail}
else
  if (command -v dialog >/dev/null)
  then
    DIALOG=${DIALOG=dialog}
  else
    echo "Please install 'whiptail' or 'dialog' to run setup..."
    exit 1
  fi
fi

###################################

#DIALOG=whiptail
#DIALOG=dialog

###################################

if ! command -V wget &> /dev/null ; then
    echo "'wget' is required for running the installer, but could not be found."
    echo "Please install 'wget' using the package manager for your distribution before proceeding."
    exit 1
fi
if ! command -V unzip &> /dev/null ; then
    echo "'unzip' is required for running the installer, but could not be found."
    echo "Please install 'unzip' using the package manager for your distribution before proceeding."
    exit 1
fi
if ! command -V sed &> /dev/null ; then
    echo "'sed' is required for running the installer, but could not be found."
    echo "Please install 'sed' using the package manager for your distribution before proceeding."
    exit 1
fi

# XDG Base Directory Specification
if [[ -z "$XDG_CONFIG_HOME" ]]; then
  export XDG_CONFIG_HOME="$HOME"/.config
fi

if [[ -z "$XDG_DATA_HOME" ]]; then
  export XDG_DATA_HOME="$HOME"/.local/share
fi

TARGET_DIR=$(dirname "$(readlink -f $0)")

cd "$(dirname "$TARGET_DIR")" || {
    echo "ERROR: Could not change directory to '$TARGET_DIR'"
    exit 1
}

if ! [ -d ./tangaria_setup_files ]; then
  mkdir -p $TARGET_DIR/tangaria_setup_files
fi

cd $TARGET_DIR/tangaria_setup_files || {
    echo "ERROR: Could not change directory to '$TARGET_DIR'"
    exit 1
}

arrayContains() {
    local arr=${!1}
    local el="$2"
    local flag=$3
    if printf "%s\n" "${arr[@]}" | grep -x -q "$el"; then
        eval $flag=ON
    else
        eval $flag=OFF
    fi
}

radioListRoguelike() {
    NAME_ROGUELIKE=$($DIALOG --title "Roguelike Game" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nChoose a roguelike game:" 16 54 6 \
            "Tangaria" "tangaria.com " $RADIOLIST_ROGUELIKE_TANGARIA \
            "PWMAngband" "powerwyrm.monsite-orange.fr " $RADIOLIST_ROGUELIKE_PWMANGBAND \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains NAME_ROGUELIKE[@] "Tangaria" RADIOLIST_ROGUELIKE_TANGARIA
            arrayContains NAME_ROGUELIKE[@] "PWMAngband" RADIOLIST_ROGUELIKE_PWMANGBAND
        else
            clear
            exit 0
        fi
}

inputBoxInstallPath() {
    INSTALL_DIR=$($DIALOG --title "Install path" --nocancel --inputbox \
        "enter path:" 8 76 $INSTALL_DIR 3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} != 0 ]; then
            clear
            exit 0
        fi
}

radioListVersion() {
    MENU_VERSION_SRC=$($DIALOG --title "Version $NAME_ROGUELIKE" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nChoose $NAME_ROGUELIKE version:" 16 54 6 \
            "default" "(stable) " $RADIOLIST_VERSION_SRC_STABLE \
            "latest" "(dev) " $RADIOLIST_VERSION_SRC_LATEST \
            "other" "(branches) " $RADIOLIST_VERSION_SRC_OTHER \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_VERSION_SRC[@] "default" RADIOLIST_VERSION_SRC_STABLE
            arrayContains MENU_VERSION_SRC[@] "latest" RADIOLIST_VERSION_SRC_LATEST
            arrayContains MENU_VERSION_SRC[@] "other" RADIOLIST_VERSION_SRC_OTHER
            if [ $NAME_ROGUELIKE = "Tangaria" ]; then
                if [ $MENU_VERSION_SRC = "default" ]; then
                    VERSION_TANGARIA="$VERSION_TANGARIA_STABLE"
                fi
                if [ $MENU_VERSION_SRC = "latest" ]; then
                    VERSION_TANGARIA="$VERSION_TANGARIA_LATEST"
                fi
                if [ $MENU_VERSION_SRC = "other" ]; then
                    VERSION_TANGARIA=$($DIALOG --title "other(branches)" --nocancel --inputbox \
                        "follow the link https://github.com/igroglaz/Tangaria/commits \nenter: Tangaria-" 9 76 \
                        $VERSION_TANGARIA 3>&1 1>&2 2>&3)
                        exitstatus=$?
                        if [ ${exitstatus} != 0 ]; then
                            clear
                            exit 0
                        fi
                fi
            fi

            if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
                if [ $MENU_VERSION_SRC = "default" ]; then
                    VERSION_PWMANGBAND="master"
                fi
                if [ $MENU_VERSION_SRC = "latest" ]; then
                    VERSION_PWMANGBAND="master"
                fi
                if [ $MENU_VERSION_SRC = "other" ]; then
                    VERSION_PWMANGBAND=$($DIALOG --title "other(branches)" --nocancel --inputbox \
                        "follow the link https://github.com/draconisPW/PWMAngband/commits \nenter: PWMAngband-" 9 76 \
                        $VERSION_PWMANGBAND 3>&1 1>&2 2>&3)
                        exitstatus=$?
                        if [ ${exitstatus} != 0 ]; then
                            clear
                            exit 0
                        fi
                fi
            fi
        else
            clear
            exit 0
        fi
}

radioListClient() {
    MENU_CLIENT=$($DIALOG --title "Client" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect client version:" 16 54 6 \
            "sdl" "(SDL 1.2) " $RADIOLIST_CLIENT_SDL \
            "curses" "(terminal) " $RADIOLIST_CLIENT_CURSES \
            "other" "(./configure) " $RADIOLIST_CLIENT_OTHER \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_CLIENT[@] "sdl" RADIOLIST_CLIENT_SDL
            arrayContains MENU_CLIENT[@] "curses" RADIOLIST_CLIENT_CURSES
            arrayContains MENU_CLIENT[@] "other" RADIOLIST_CLIENT_OTHER
        else
            clear
            exit 0
        fi
}

checkListOptions() {
    MENU_OPTIONS=$($DIALOG --title "Options" --nocancel --separate-output --checklist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect options:" 16 54 6 \
            "client.desktop" "AppMenu " $CHECKLIST_OPTIONS_CLIENT_DESKTOP \
            "server.desktop" "AppMenu " $CHECKLIST_OPTIONS_SERVER_DESKTOP \
            "link directory user" "ln path " $CHECKLIST_OPTIONS_LINK_DIR_USER \
            "$REPOSITORY_NAME_TANGARIA_RELEASE" "install " $CHECKLIST_OPTIONS_TANGARIA_RELEASE \
            "AppImage" "build " $CHECKLIST_OPTIONS_APPIMAGE \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_OPTIONS[@] "client.desktop" CHECKLIST_OPTIONS_CLIENT_DESKTOP
            arrayContains MENU_OPTIONS[@] "server.desktop" CHECKLIST_OPTIONS_SERVER_DESKTOP
            arrayContains MENU_OPTIONS[@] "link directory user" CHECKLIST_OPTIONS_LINK_DIR_USER
            arrayContains MENU_OPTIONS[@] "$REPOSITORY_NAME_TANGARIA_RELEASE" CHECKLIST_OPTIONS_TANGARIA_RELEASE
            arrayContains MENU_OPTIONS[@] "AppImage" CHECKLIST_OPTIONS_APPIMAGE
        else
            clear
            exit 0
        fi
}

checkListUpdate() {
if [ $NAME_ROGUELIKE = "Tangaria" ]; then
    MENU_UPDATE=$($DIALOG --title "Update" --nocancel --separate-output --checklist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect update options:" 16 54 6 \
            "Download $REPOSITORY_NAME_TANGARIA" "" $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA \
            "Unpack $REPOSITORY_NAME_TANGARIA" "" $CHECKLIST_UPDATE_UNPACK_TANGARIA \
            "Download $REPOSITORY_NAME_TANGARIA_RELEASE" "" $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA_RELEASE \
            "Unpack $REPOSITORY_NAME_TANGARIA_RELEASE" "" $CHECKLIST_UPDATE_UNPACK_TANGARIA_RELEASE \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_UPDATE[@] "Download $REPOSITORY_NAME_TANGARIA" CHECKLIST_UPDATE_DOWNLOAD_TANGARIA
            arrayContains MENU_UPDATE[@] "Unpack $REPOSITORY_NAME_TANGARIA" CHECKLIST_UPDATE_UNPACK_TANGARIA
            arrayContains MENU_UPDATE[@] "Download $REPOSITORY_NAME_TANGARIA_RELEASE" CHECKLIST_UPDATE_DOWNLOAD_TANGARIA_RELEASE
            arrayContains MENU_UPDATE[@] "Unpack $REPOSITORY_NAME_TANGARIA_RELEASE" CHECKLIST_UPDATE_UNPACK_TANGARIA_RELEASE
        else
            clear
            exit 0
        fi
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
    MENU_UPDATE=$($DIALOG --title "Update" --nocancel --separate-output --checklist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect update options:" 16 54 6 \
            "Download $REPOSITORY_NAME_PWMANGBAND" "" $CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND \
            "Unpack $REPOSITORY_NAME_PWMANGBAND" "" $CHECKLIST_UPDATE_UNPACK_PWMANGBAND \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_UPDATE[@] "Download $REPOSITORY_NAME_PWMANGBAND" CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND
            arrayContains MENU_UPDATE[@] "Unpack $REPOSITORY_NAME_PWMANGBAND" CHECKLIST_UPDATE_UNPACK_PWMANGBAND
        else
            clear
            exit 0
        fi
fi
}

messageBoxHelp() {
    $DIALOG --title "Help" --scrolltext --msgbox "$README" 25 80
}

logo_PWMAngband() {
echo "                                   "
echo "        ,     \    /      ,        "
echo "       / \    )\__/(     / \       "
echo "      /   \  (_\  /_)   /   \      "
echo " ____/_____\__\@  @/___/_____\____ "
echo "|             |\../|              |"
echo "|              \VV/               |"
echo "|   powerwyrm.monsite-orange.fr   |"
echo "|_________________________________|"
echo " |    /\ /      ((       \ /\    | "
echo " |  /   V        ))       V   \  | "
echo " |/     '       //        '     \| "
echo " '              V                ' "
echo "                                   "
}

logo_Tangaria() {
echo "----------------------------------------------------"
echo "--------------------- Tangaria ---------------------"
echo "----------------------------------------------------"
echo "       _    .  ,   .           .                    "
echo "   *  / \_ *  / \_      _  *        *   /\'__       "
echo "     /    \  /    \,   ((        .    _/  /  \  *'. "
echo ".   /\/\  /\/ :' __ \_  '          _^/  ^/    '--.  "
echo "   /    \/  \  _/  \-'\      *    /.' ^_   \_   .'\ "
echo " /\  .-   '. \/     \ /==~=-=~=-=-;.  _/ \ -. '_/   "
echo "/  '-.__ ^   / .-'.--\ =-=~_=-=~=^/  _ '--./ .-'  '-"
echo "        '.  / /       '.~-^=-=~=^=.-'      '-._ '._ "
echo "tangaria.com                                        "
echo "----------------------------------------------------"
}

download_PWMAngband() {
echo "-----------------------------------"
echo "----------- PWMAngband ------------"
echo "-----------------------------------"
logo_PWMAngband

if [ $CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND = ON ]; then
    rm -rf ./$REPOSITORY_NAME_PWMANGBAND-*".zip"
    wget --output-document=$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND".zip" \
    $REPOSITORY_URL_PWMANGBAND$VERSION_PWMANGBAND".zip" || exit 1
else
    if ! [ -e "$(ls -A . | head -1)" ]; then
        echo "./tangaria_setup_files   empty directory..."
        exit 0
    fi
    if ! [ -d $(ls -d $REPOSITORY_NAME_PWMANGBAND-* | head -1 || exit 1) ]; then
        VERSION_PWMANGBAND=$(ls -d $REPOSITORY_NAME_PWMANGBAND-* | head -1 | sed -e "s/.*${REPOSITORY_NAME_PWMANGBAND}-//; s/.zip*//")
        echo "ok... $REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND"
    else
        VERSION_PWMANGBAND=$(ls -d $REPOSITORY_NAME_PWMANGBAND-*/ | head -1 | sed -e "s/.*${REPOSITORY_NAME_PWMANGBAND}-//; s/.$//")
        echo "ok... $REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND"
    fi
fi

if [ $CHECKLIST_UPDATE_UNPACK_PWMANGBAND = ON ]; then
    rm -rf $(ls -d $REPOSITORY_NAME_PWMANGBAND-*/)
    unzip -o $REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND".zip" || exit 1
fi
}

download_Tangaria() {
echo "-----------------------------------"
echo "------ powered by PWMAngband ------"
echo "-----------------------------------"
logo_PWMAngband

if [ $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA = ON ]; then
    rm -rf ./$REPOSITORY_NAME_TANGARIA-*".zip"
    wget --output-document=$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA".zip" \
    $REPOSITORY_URL_TANGARIA$VERSION_TANGARIA".zip" || exit 1
else
    if ! [ -e "$(ls -A . | head -1)" ]; then
        echo "./tangaria_setup_files   empty directory..."
        exit 0
    fi
    if ! [ -d $(ls -d $REPOSITORY_NAME_TANGARIA-* | head -1 || exit 1) ]; then
        VERSION_TANGARIA=$(ls -d $REPOSITORY_NAME_TANGARIA-* | head -1 | sed -e "s/.*${REPOSITORY_NAME_TANGARIA}-//; s/.zip*//")
        echo "ok... $REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA"
    else
        VERSION_TANGARIA=$(ls -d $REPOSITORY_NAME_TANGARIA-*/ | head -1 | sed -e "s/.*${REPOSITORY_NAME_TANGARIA}-//; s/.$//")
        echo "ok... $REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA"
    fi
fi

if [ $CHECKLIST_UPDATE_UNPACK_TANGARIA = ON ]; then
    rm -rf $(ls -d $REPOSITORY_NAME_TANGARIA-*/)
    unzip -o $REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA".zip" || exit 1
fi

##########
if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = ON ]; then

logo_Tangaria

if [ $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA_RELEASE = ON ]; then
    rm -rf ./$REPOSITORY_NAME_TANGARIA_RELEASE-*".zip"
    wget --output-document=$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE".zip" \
    $REPOSITORY_URL_TANGARIA_RELEASE$VERSION_TANGARIA_RELEASE".zip" || exit 1
fi

if ! [ -d ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE ]; then
    unzip -o $REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE".zip" || exit 1
else
    if [ $CHECKLIST_UPDATE_UNPACK_TANGARIA_RELEASE = ON ]; then
        rm -rf $(ls -d $REPOSITORY_NAME_TANGARIA_RELEASE-*/)
        unzip -o $REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE".zip" || exit 1
    fi
fi

fi
}

write_pwmangrc() {
local PATH_INI_PWMANGRC=$1
local WRITE_FILE_PWMANGRC=$2
NICK=$(sed -n '/nick=/p' $PATH_INI_PWMANGRC)
PASS=$(sed -n '/pass=/p' $PATH_INI_PWMANGRC)
HOST=$(sed -n '/host=/p' $PATH_INI_PWMANGRC)
META_ADDRESS=$(sed -n '/meta_address=/p' $PATH_INI_PWMANGRC)
META_PORT=$(sed -n '/meta_port=/p' $PATH_INI_PWMANGRC)
DISABLENUMLOCK=$(sed -n '/DisableNumlock=/p' $PATH_INI_PWMANGRC)
LIGHTERBLUE=$(sed -n '/LighterBlue=/p' $PATH_INI_PWMANGRC)
cat > $WRITE_FILE_PWMANGRC << EOF
[MAngband]
$NICK
$PASS
$HOST
$META_ADDRESS
$META_PORT
$DISABLENUMLOCK
$LIGHTERBLUE
EOF
}

build_AppImage() {
# This function will build & bundle a valid AppImage[https://appimage.org]
# HOWEVER! AppImages should be built on oldest possible linux distro,
# e.g. CentOS 6, so if you build this on latest Ubuntu, it won't be
# of any use to anyone!
# Thus, while this script shall work on your machine, and that is
# useful for debugging it, please DON'T re-destribute the resulting
# appimage!
#
# install appstream

echo "        __      __    "
echo "     __/  \-''- _ |   "
echo "__- - {            \  "
echo "     /             \  "
echo "    /        o    o } "
echo "    |              ;  "
echo "                   '  "
echo "       \_       (..)  "
echo "         ''-_ _ _ /   "
echo "           /          "
echo "          /           "

INSTALL_DIR="/tmp/$NAME_ROGUELIKE"
APP_DIR="AppDir"

######## linuxdeploy-x86_64 ########
LINUX_DEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
LINUX_DEPLOY="linuxdeploy-x86_64.AppImage"

######### linuxdeploy-i386 ##########
#LINUX_DEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-i386.AppImage"
#LINUX_DEPLOY="linuxdeploy-i386.AppImage"

if ! [ -f ./$LINUX_DEPLOY ]; then
    wget $LINUX_DEPLOY_URL || exit 1
    chmod +x ./linuxdeploy*.AppImage
else
    echo -n "Update $LINUX_DEPLOY ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«(honey)», m-m-m..."
             rm -rf ./$LINUX_DEPLOY
             wget $LINUX_DEPLOY_URL || exit 1
             chmod +x ./linuxdeploy*.AppImage
            ;;
        n|N) echo "«no», ok..."
            ;;
        *) echo "«no», ok..."
            ;;
    esac
fi

rm -rf ./${APP_DIR}
mkdir ./${APP_DIR}

if [ $NAME_ROGUELIKE = "Tangaria" ]; then
    download_Tangaria
    make -C ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA clean
    cd ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA || exit 1
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
    download_PWMAngband
    make -C ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND clean
    cd ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND || exit 1
fi

./autogen.sh || exit 1

# Build (prefix must be INSTALL_DIR="/usr")
if [ $MENU_CLIENT = "sdl" ]; then
    ./configure --prefix="$INSTALL_DIR" --disable-curses --disable-x11 --enable-sdl
fi
if [ $MENU_CLIENT = "curses" ]; then
    ./configure --prefix="$INSTALL_DIR" --enable-curses --disable-x11 --disable-sdl
fi
if [ $MENU_CLIENT = "other" ]; then
    ./configure --prefix="$INSTALL_DIR" --enable-curses --disable-x11 --disable-sdl
fi
make -j$CPU_CORES

# Base install
make install DESTDIR="$TARGET_DIR/tangaria_setup_files/${APP_DIR}"

cd ../ || exit 1

# Icons
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/16x16/apps
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/32x32/apps
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/64x64/apps
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/256x256/apps
mkdir -p ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps

if [ $NAME_ROGUELIKE = "Tangaria" ]; then
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att-16.png ./${APP_DIR}/usr/share/icons/hicolor/16x16/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/32x32/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/64x64/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att-128.png ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att-256.png ./${APP_DIR}/usr/share/icons/hicolor/256x256/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/lib/icons/att.svg ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps/pwmangclient.svg
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att-16.png ./${APP_DIR}/usr/share/icons/hicolor/16x16/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/32x32/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/64x64/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att-128.png ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att-256.png ./${APP_DIR}/usr/share/icons/hicolor/256x256/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/lib/icons/att.svg ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps/pwmangclient.svg
fi

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = OFF ]; then
cp -fv ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/setup/mangband.cfg ./${APP_DIR}$INSTALL_DIR/games
write_pwmangrc ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA/setup/mangclient.ini "$TARGET_DIR/tangaria_setup_files/${APP_DIR}$INSTALL_DIR/games/.pwmangrc"
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
cp -fv ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND/setup/mangband.cfg ./${APP_DIR}$INSTALL_DIR/games
fi

mkdir -p ./${APP_DIR}/usr/bin/
mv ./${APP_DIR}$INSTALL_DIR/games/pwmangclient ./${APP_DIR}/usr/bin/pwmangclient

###################################

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = ON ]; then

echo "copying files..."

rm -r ./${APP_DIR}$INSTALL_DIR/etc/pwmangband/customize
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/customize ./${APP_DIR}$INSTALL_DIR/etc/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/etc/pwmangband/gamedata
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/gamedata ./${APP_DIR}$INSTALL_DIR/etc/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/fonts
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/fonts ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/help
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/help ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/icons
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/icons ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/screens
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/screens ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/sounds
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/sounds ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}$INSTALL_DIR/share/pwmangband/tiles
cp -Rv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/tiles ./${APP_DIR}$INSTALL_DIR/share/pwmangband

cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/readme.txt ./${APP_DIR}$INSTALL_DIR/share/pwmangband
cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/Changes.txt ./${APP_DIR}$INSTALL_DIR
cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/Manual.html ./${APP_DIR}$INSTALL_DIR
cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/Manual.pdf ./${APP_DIR}$INSTALL_DIR

cp -iv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/mangband.cfg ./${APP_DIR}$INSTALL_DIR/games

cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/user/sdlinit.txt ${APP_DIR}$INSTALL_DIR/games

write_pwmangrc ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/mangclient.ini "$TARGET_DIR/tangaria_setup_files/${APP_DIR}$INSTALL_DIR/games/.pwmangrc"

# Icons
cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/icons/att-128.png ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps/pwmangclient.png
cp -fv ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE/lib/icons/att.svg ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps/pwmangclient.svg

fi

###################################

mv ./${APP_DIR}/tmp/$NAME_ROGUELIKE ./${APP_DIR}/usr
rm -rf ./${APP_DIR}/tmp

cat > ./${APP_DIR}/pwmangclient.desktop << EOF
[Desktop Entry]
Name=$NAME_ROGUELIKE
Type=Application
Comment=$NAME_ROGUELIKE (client)
Exec=pwmangclient
Icon=pwmangclient
Terminal=false
Categories=Game;RolePlaying;
EOF

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
cat > ./${APP_DIR}/AppRun << EOF
#!/bin/sh

SELF_DIR="\$(dirname "\$(readlink -f "\$0")")"
cd \${SELF_DIR} || exit 1
ln -sf \${SELF_DIR}/usr/$NAME_ROGUELIKE $INSTALL_DIR
cd \$HOME || {
    echo "ERROR: Could not change directory..."
    exit 1
}
exec \${SELF_DIR}/usr/bin/pwmangclient \\
\$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9
EOF
chmod +x ./${APP_DIR}/AppRun
fi

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = OFF ]; then
cat > ./${APP_DIR}/AppRun << EOF
#!/bin/sh

SELF_DIR="\$(dirname "\$(readlink -f "\$0")")"
cd \${SELF_DIR} || exit 1
ln -sf \${SELF_DIR}/usr/$NAME_ROGUELIKE $INSTALL_DIR

if ! [ -f \$HOME/.pwmangrc ]; then
cp -f ./usr/$NAME_ROGUELIKE/games/.pwmangrc \$HOME
fi

cd ./usr/bin || exit 1

set -ex

exec "./pwmangclient" \\
\$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9
EOF
chmod +x ./${APP_DIR}/AppRun
fi

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = ON ]; then
cat > ./${APP_DIR}/AppRun << EOF
#!/bin/sh

SELF_DIR="\$(dirname "\$(readlink -f "\$0")")"
cd \${SELF_DIR} || exit 1
ln -sf \${SELF_DIR}/usr/$NAME_ROGUELIKE $INSTALL_DIR

if ! [ -f \$HOME/.pwmangrc ]; then
cp -f ./usr/$NAME_ROGUELIKE/games/.pwmangrc \$HOME
fi

if ! [ -f \$HOME/.pwmangband/Tangaria/sdlinit.txt ]; then
mkdir -p \$HOME/.pwmangband/Tangaria
cp -f ./usr/$NAME_ROGUELIKE/games/sdlinit.txt \$HOME/.pwmangband/Tangaria/
fi

cd ./usr/bin || exit 1

set -ex

exec "./pwmangclient" \\
\$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9
EOF
chmod +x ./${APP_DIR}/AppRun
fi

# Bake AppImage
rm -f $NAME_ROGUELIKE*.AppImage*
./${LINUX_DEPLOY} \
--appdir ./${APP_DIR} \
--desktop-file ./${APP_DIR}/pwmangclient.desktop \
--output appimage

exit 0
}

###################################

do_install() {
clear
if [ $CHECKLIST_OPTIONS_APPIMAGE = ON ]; then
build_AppImage
fi

if [ $NAME_ROGUELIKE = "Tangaria" ]; then
    download_Tangaria
    make -C ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA clean
    cd ./$REPOSITORY_NAME_TANGARIA-$VERSION_TANGARIA || exit 1
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
    download_PWMAngband
    make -C ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND clean
    cd ./$REPOSITORY_NAME_PWMANGBAND-$VERSION_PWMANGBAND || exit 1
fi

./autogen.sh || exit 1

if [ $MENU_CLIENT = "sdl" ]; then
    ./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
fi
if [ $MENU_CLIENT = "curses" ]; then
    ./configure --prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl
fi
if [ $MENU_CLIENT = "other" ]; then
##  ./configure --help
    ./configure --prefix $INSTALL_DIR
fi

make -j$CPU_CORES
make install

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = OFF ]; then
    cp -iv ./setup/mangband.cfg $INSTALL_DIR/games
    if ! [ -f $USER_PWMANGRC ]; then
        write_pwmangrc ./setup/mangclient.ini $USER_PWMANGRC
    else
        echo -n "replace $USER_PWMANGRC ?     (y/n)"
        read item
        case "$item" in
            y|Y) echo "«yes», ok..."
                 write_pwmangrc ./setup/mangclient.ini $USER_PWMANGRC
                ;;
            n|N) echo "«no», ok..."
                ;;
            *) echo "«no», ok..."
                ;;
        esac
    fi
fi

if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
cp -iv ./setup/mangband.cfg $INSTALL_DIR/games
fi

cd ../ || exit 1

if ! [ -f $INSTALL_DIR/pwmangclient-launcher.sh ]; then
cat > $INSTALL_DIR/pwmangclient-launcher.sh << EOF
#!/bin/sh

PWMANGCLIENT_DIR="\$(dirname "\$0")"/games
cd \$HOME || {
    echo "ERROR: Could not change directory..."
    exit 1
}
exec \$PWMANGCLIENT_DIR/pwmangclient

# To get path to config file ./pwmangclient --config file
#
# Example .pwmangrc
#
#[MAngband]
#nick=PLAYER
#pass=pass
#;host=localhost
#meta_address=mangband.org
#meta_port=8802
#DisableNumlock=1
#LighterBlue=1
EOF
chmod +x $INSTALL_DIR/pwmangclient-launcher.sh
fi

if ! [ -f $INSTALL_DIR/pwmangband-launcher.sh ]; then
cat > $INSTALL_DIR/pwmangband-launcher.sh << EOF
#!/bin/sh
cd "\$(dirname "\$0")"/games || {
    echo "ERROR: Could not change directory..."
    exit 1
}
exec ./pwmangband
EOF
chmod +x $INSTALL_DIR/pwmangband-launcher.sh
fi

if [ $CHECKLIST_OPTIONS_CLIENT_DESKTOP = ON ] || [ $CHECKLIST_OPTIONS_SERVER_DESKTOP = ON ]; then
    if ! [ -d $XDG_DATA_HOME/applications ]; then
        mkdir -p $XDG_DATA_HOME/applications
    fi
fi

if [ $CHECKLIST_OPTIONS_CLIENT_DESKTOP = ON ]; then
cat > $XDG_DATA_HOME/applications/$NAME_ROGUELIKE-client.desktop << EOF
[Desktop Entry]
Name=$NAME_ROGUELIKE (client)
Type=Application
Comment=$NAME_ROGUELIKE (client)
Exec=$INSTALL_DIR/games/pwmangclient
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=false
Categories=Game;RolePlaying;
EOF
fi

if [ $CHECKLIST_OPTIONS_SERVER_DESKTOP = ON ]; then
cat > $XDG_DATA_HOME/applications/$NAME_ROGUELIKE-server.desktop << EOF
[Desktop Entry]
Name=$NAME_ROGUELIKE (server)
Type=Application
Comment=$NAME_ROGUELIKE (server)
Path=$INSTALL_DIR/games
Exec=$INSTALL_DIR/games/pwmangband
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=true
Categories=Game;RolePlaying;
EOF
fi

if [ $CHECKLIST_OPTIONS_LINK_DIR_USER = ON ]; then
    if ! [ -e $INSTALL_DIR/user ]; then
    ln -s $USER_PWMANGBAND $INSTALL_DIR/user
    fi
fi

###################################

if [ $NAME_ROGUELIKE = "Tangaria" ] && [ $CHECKLIST_OPTIONS_TANGARIA_RELEASE = ON ]; then

cd ./$REPOSITORY_NAME_TANGARIA_RELEASE-$VERSION_TANGARIA_RELEASE || exit 1

if ! [ -d $INSTALL_DIR ]; then
    echo "ERROR: directory not found '$INSTALL_DIR'"
    exit 1
fi

echo "copying files..."

rm -r $INSTALL_DIR/etc/pwmangband/customize
cp -Rv ./lib/customize $INSTALL_DIR/etc/pwmangband
rm -r $INSTALL_DIR/etc/pwmangband/gamedata
cp -Rv ./lib/gamedata $INSTALL_DIR/etc/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/fonts
cp -Rv ./lib/fonts $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/help
cp -Rv ./lib/help $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/icons
cp -Rv ./lib/icons $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/screens
cp -Rv ./lib/screens $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/sounds
cp -Rv ./lib/sounds $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/tiles
cp -Rv ./lib/tiles $INSTALL_DIR/share/pwmangband

cp -fv ./lib/readme.txt $INSTALL_DIR/share/pwmangband
cp -fv ./Changes.txt $INSTALL_DIR
cp -fv ./Manual.html $INSTALL_DIR
cp -fv ./Manual.pdf $INSTALL_DIR

cp -iv ./mangband.cfg $INSTALL_DIR/games

if ! [ -d $USER_PWMANGBAND ]; then
    mkdir -p $USER_PWMANGBAND
fi
if ! [ -d $USER_PWMANGBAND/Tangaria ]; then
    mkdir -p $USER_PWMANGBAND/Tangaria
fi
if ! [ -d $USER_PWMANGBAND/Tangaria/save ]; then
    mkdir -p $USER_PWMANGBAND/Tangaria/save
fi
if ! [ -d $USER_PWMANGBAND/Tangaria/scores ]; then
    mkdir -p $USER_PWMANGBAND/Tangaria/scores
fi

cp -nv ./lib/user/save/account $USER_PWMANGBAND/Tangaria/save

cp -iv ./lib/user/sdlinit.txt $USER_PWMANGBAND/Tangaria

if ! [ -f $USER_PWMANGRC ]; then
    write_pwmangrc ./mangclient.ini $USER_PWMANGRC
else
    echo -n "replace $USER_PWMANGRC ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», ok..."
             write_pwmangrc ./mangclient.ini $USER_PWMANGRC
            ;;
        n|N) echo "«no», ok..."
            ;;
        *) echo "«no», ok..."
            ;;
    esac
fi

fi

if [ $NAME_ROGUELIKE = "Tangaria" ]; then
echo "                "
echo "              _,"
echo "  _._   ,'._,'  "
echo "-'   '-'        "
echo "                "
echo "  ./            "
echo "  <_n_          "
echo "   'B'\)        "
echo "   /^>          "
echo "  '  '          "
echo "    tangaria.com"
echo "                "
fi
exit 0
}

###################################

main() {
while true; do
clear
MENU_INSTALL_DIR=$(echo "$INSTALL_DIR" | sed -e 's/\(.\{40\}\).*/\1/; s/./&.../40')
if [ $NAME_ROGUELIKE = "Tangaria" ]; then
    VERSION_SRC=$(echo "$VERSION_TANGARIA" | sed -e 's/\(.\{7\}\).*/\1/; s/./&.../7')
fi
if [ $NAME_ROGUELIKE = "PWMAngband" ]; then
    VERSION_SRC=$(echo "$VERSION_PWMANGBAND" | sed -e 's/\(.\{7\}\).*/\1/; s/./&.../7')
fi

        MAIN_MENU=$($DIALOG --title "Setup - Menu" --ok-button "Select" --cancel-button "Quit" --menu \
        "_.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._\n " 18 71 9 \
            "$NAME_ROGUELIKE" "" \
            "Install Path" "$MENU_INSTALL_DIR" \
            "Version" "$NAME_ROGUELIKE-$VERSION_SRC" \
            "Client" "$MENU_CLIENT" \
            "Options" "" \
            "Update" "" \
            "Help" "" \
            "Install" ">>>------>" \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${MAIN_MENU} in
                "$NAME_ROGUELIKE")
                    radioListRoguelike
                ;;
                "Install Path")
                    inputBoxInstallPath
                ;;
                "Version")
                    radioListVersion
                ;;
                "Client")
                    radioListClient
                ;;
                "Options")
                    checkListOptions
                ;;
                "Update")
                    checkListUpdate
                ;;
                "Help")
                    messageBoxHelp
                ;;
                "Install")
                    do_install
                ;;
            esac
        else
            clear
            exit 0
        fi
    done
}

###################################

main

