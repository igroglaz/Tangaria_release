#!/bin/bash

## Script for setup Tangaria
##
README=\
'<<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>><<>>
# Link to latest version: https://raw.githubusercontent.com/igroglaz/Tangaria/master/tangaria-setup.sh
# Github PWMAngband: https://github.com/draconisPW/PWMAngband
# PWMAngband binaries: https://powerwyrm.monsite-orange.fr/page-56e3134c5ebab.html
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

OTHER_CONFIGURE_PWMANGBAND="--prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl"

######## make -j$CPU_CORES ########

CPU_CORES=$(cat /proc/cpuinfo | grep processor | wc -l)

###################################

REPOSITORY_URL_PWMANGBAND="https://github.com/draconisPW/PWMAngband/archive/"
REPOSITORY_URL_TANGARIA="https://github.com/igroglaz/Tangaria/archive/"

###################################

MENU_ROGUELIKE="Tangaria"
RADIOLIST_ROGUELIKE_TANGARIA=ON
RADIOLIST_ROGUELIKE_PWMANGBAND=OFF

VERSION_TANGARIA="master"
VERSION_PWMANGBAND="master"

MENU_VERSION_PWMANGBAND="master"
RADIOLIST_VERSION_PWMANGBAND_MASTER=ON
RADIOLIST_VERSION_PWMANGBAND_OTHER=OFF

MENU_CLIENT="sdl"
RADIOLIST_CLIENT_SDL=ON
RADIOLIST_CLIENT_CURSES=OFF
RADIOLIST_CLIENT_OTHER=OFF

CHECKLIST_OPTIONS_SDLINIT=ON
CHECKLIST_OPTIONS_LINK_DIR_USER=ON
CHECKLIST_OPTIONS_APPIMAGE=OFF

CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND=ON
CHECKLIST_UPDATE_UNPACK_PWMANGBAND=ON
CHECKLIST_UPDATE_DOWNLOAD_TANGARIA=ON
CHECKLIST_UPDATE_UNPACK_TANGARIA=ON

###################################

if (command -v whiptail >/dev/null)
then
  DIALOG=${DIALOG=whiptail}
else
  if (command -v dialog >/dev/null)
  then
    DIALOG=${DIALOG=dialog}
  else
    echo "please install whiptail or dialog to run setup..."
    exit 1
  fi
fi

###################################

#DIALOG=whiptail
#DIALOG=dialog

###################################

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
    MENU_ROGUELIKE=$($DIALOG --title "Roguelike Game" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nChoose a roguelike game:" 16 54 6 \
            "Tangaria" "tangaria.com " $RADIOLIST_ROGUELIKE_TANGARIA \
            "PWMAngband" "powerwyrm.monsite-orange.fr " $RADIOLIST_ROGUELIKE_PWMANGBAND \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_ROGUELIKE[@] "Tangaria" RADIOLIST_ROGUELIKE_TANGARIA
            arrayContains MENU_ROGUELIKE[@] "PWMAngband" RADIOLIST_ROGUELIKE_PWMANGBAND
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
    MENU_VERSION_PWMANGBAND=$($DIALOG --title "Version PWMAngband" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nChoose PWMAngband version:" 16 54 6 \
            "master" "(latest) " $RADIOLIST_VERSION_PWMANGBAND_MASTER \
            "other" "(branches) " $RADIOLIST_VERSION_PWMANGBAND_OTHER \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_VERSION_PWMANGBAND[@] "master" RADIOLIST_VERSION_PWMANGBAND_MASTER
            arrayContains MENU_VERSION_PWMANGBAND[@] "other" RADIOLIST_VERSION_PWMANGBAND_OTHER
            if [ $MENU_VERSION_PWMANGBAND = "master" ]; then
                VERSION_PWMANGBAND="master"
            fi
            if [ $MENU_VERSION_PWMANGBAND = "other" ]; then
                VERSION_PWMANGBAND=$($DIALOG --title "other(branches)" --nocancel --inputbox \
                    "follow the link https://github.com/draconisPW/PWMAngband/branches \nenter: PWMAngband-" 9 76 \
                    $VERSION_PWMANGBAND 3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ ${exitstatus} != 0 ]; then
                        clear
                        exit 0
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
            "sdlinit.txt" "Tangaria " $CHECKLIST_OPTIONS_SDLINIT \
            "link directory user" "Tangaria " $CHECKLIST_OPTIONS_LINK_DIR_USER \
            "AppImage" "build " $CHECKLIST_OPTIONS_APPIMAGE \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_OPTIONS[@] "sdlinit.txt" CHECKLIST_OPTIONS_SDLINIT
            arrayContains MENU_OPTIONS[@] "link directory user" CHECKLIST_OPTIONS_LINK_DIR_USER
            arrayContains MENU_OPTIONS[@] "AppImage" CHECKLIST_OPTIONS_APPIMAGE
        else
            clear
            exit 0
        fi
}

checkListUpdate() {
    MENU_UPDATE=$($DIALOG --title "Update" --nocancel --separate-output --checklist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect update options:" 16 54 6 \
            "Download PWMAngband" "" $CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND \
            "Unpack PWMAngband" "" $CHECKLIST_UPDATE_UNPACK_PWMANGBAND \
            "Download Tangaria" "" $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA \
            "Unpack Tangaria" "" $CHECKLIST_UPDATE_UNPACK_TANGARIA \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            arrayContains MENU_UPDATE[@] "Download PWMAngband" CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND
            arrayContains MENU_UPDATE[@] "Unpack PWMAngband" CHECKLIST_UPDATE_UNPACK_PWMANGBAND
            arrayContains MENU_UPDATE[@] "Download Tangaria" CHECKLIST_UPDATE_DOWNLOAD_TANGARIA
            arrayContains MENU_UPDATE[@] "Unpack Tangaria" CHECKLIST_UPDATE_UNPACK_TANGARIA
        else
            clear
            exit 0
        fi
}

messageBoxHelp() {
    $DIALOG --title "Help" --scrolltext --msgbox "$README" 25 80
}

download_PWMAngband() {
echo "-----------------------------------"
echo "----------- PWMAngband ------------"
echo "-----------------------------------"
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

if [ $CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND = ON ]; then
    rm -rf ./PWMAngband-*".zip"
    wget --output-document=PWMAngband-$VERSION_PWMANGBAND.zip $REPOSITORY_URL_PWMANGBAND$VERSION_PWMANGBAND".zip" || exit 1
else
    if ! [ -e "$(ls -A . | head -1)" ]; then
        echo "./tangaria_setup_files   empty directory..."
        exit 0
    fi
    if ! [ -d $(ls -d PWMAngband-* | head -1 || exit 1) ]; then
        VERSION_PWMANGBAND=$(ls -d PWMAngband-* | head -1 | sed -e 's/.*PWMAngband-//; s/.zip*//')
        echo "ok... PWMAngband-$VERSION_PWMANGBAND"
    else
        VERSION_PWMANGBAND=$(ls -d PWMAngband-*/ | head -1 | sed -e 's/.*PWMAngband-//; s/.$//')
        echo "ok... PWMAngband-$VERSION_PWMANGBAND"
    fi
fi

if [ $CHECKLIST_UPDATE_UNPACK_PWMANGBAND = ON ]; then
    rm -rf $(ls -d PWMAngband-*/)
    unzip -o PWMAngband-$VERSION_PWMANGBAND.zip || exit 1
fi
}

download_Tangaria() {
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

if ! [ -f ./Tangaria-$VERSION_TANGARIA.zip ]; then
    rm -rf ./Tangaria-*".zip"
    wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA$VERSION_TANGARIA".zip" || exit 1
else
    if [ $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA = ON ]; then
        rm -rf ./Tangaria-*".zip"
        wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA$VERSION_TANGARIA".zip" || exit 1
    fi
fi

if ! [ -d ./Tangaria-$VERSION_TANGARIA ]; then
    unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
else
    if [ $CHECKLIST_UPDATE_UNPACK_TANGARIA = ON ]; then
        rm -rf $(ls -d Tangaria-*/)
        unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
    fi
fi
}

make_clean_PWMAngband() {
if [ -d ./PWMAngband-$VERSION_PWMANGBAND ]; then
    make -C ./PWMAngband-$VERSION_PWMANGBAND clean
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/pwmangband.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/pwmangband.o
    fi
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/pwmangclient.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/pwmangclient.o
    fi
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/client/main-sdl.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/client/main-sdl.o
    fi
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/client/main.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/client/main.o
    fi
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/client/snd-sdl.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/client/snd-sdl.o
    fi
    if [ -f ./PWMAngband-$VERSION_PWMANGBAND/src/client/main-gcu.o ] ; then
        rm -r ./PWMAngband-$VERSION_PWMANGBAND/src/client/main-gcu.o
    fi
fi
}

write_pwmangrc() {
local WRITE_PWMANGRC=$1
NICK=$(sed -n '/nick=/p' ./mangclient.ini)
PASS=$(sed -n '/pass=/p' ./mangclient.ini)
HOST=$(sed -n '/host=/p' ./mangclient.ini)
META_ADDRESS=$(sed -n '/meta_address=/p' ./mangclient.ini)
META_PORT=$(sed -n '/meta_port=/p' ./mangclient.ini)
DISABLENUMLOCK=$(sed -n '/DisableNumlock=/p' ./mangclient.ini)
LIGHTERBLUE=$(sed -n '/LighterBlue=/p' ./mangclient.ini)
cat > $WRITE_PWMANGRC << EOF
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

INSTALL_DIR="/tmp/$MENU_ROGUELIKE"
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

download_PWMAngband

##########
#make -C ./PWMAngband-$VERSION_PWMANGBAND clean
make_clean_PWMAngband

cd ./PWMAngband-$VERSION_PWMANGBAND || exit 1
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
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att-16.png ./${APP_DIR}/usr/share/icons/hicolor/16x16/apps/pwmangclient.png
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/32x32/apps/pwmangclient.png
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att-32.png ./${APP_DIR}/usr/share/icons/hicolor/64x64/apps/pwmangclient.png
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att-128.png ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps/pwmangclient.png
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att-256.png ./${APP_DIR}/usr/share/icons/hicolor/256x256/apps/pwmangclient.png
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/lib/icons/att.svg ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps/pwmangclient.svg

if [ $MENU_ROGUELIKE = "PWMAngband" ]; then
cp -fv ./PWMAngband-$VERSION_PWMANGBAND/setup/mangband.cfg ../${APP_DIR}/games
fi

mkdir -p ./${APP_DIR}/usr/bin/
mv ./${APP_DIR}/$INSTALL_DIR/games/pwmangclient ./${APP_DIR}/usr/bin/pwmangclient

###################################

if [ $MENU_ROGUELIKE = "Tangaria" ]; then

download_Tangaria

echo "copying files..."

rm -r ./${APP_DIR}/$INSTALL_DIR/etc/pwmangband/customize
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/customize ./${APP_DIR}$INSTALL_DIR/etc/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/etc/pwmangband/gamedata
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/gamedata ./${APP_DIR}$INSTALL_DIR/etc/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/fonts
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/fonts ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/help
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/help ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/icons
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/icons ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/screens
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/screens ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/sounds
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/sounds ./${APP_DIR}$INSTALL_DIR/share/pwmangband
rm -r ./${APP_DIR}/$INSTALL_DIR/share/pwmangband/tiles
cp -Rv ./Tangaria-$VERSION_TANGARIA/lib/tiles ./${APP_DIR}$INSTALL_DIR/share/pwmangband

cp -fv ./Tangaria-$VERSION_TANGARIA/lib/readme.txt ./${APP_DIR}$INSTALL_DIR/share/pwmangband
cp -fv ./Tangaria-$VERSION_TANGARIA/Changes.txt ./${APP_DIR}$INSTALL_DIR
cp -fv ./Tangaria-$VERSION_TANGARIA/Manual.html ./${APP_DIR}$INSTALL_DIR
cp -fv ./Tangaria-$VERSION_TANGARIA/Manual.pdf ./${APP_DIR}$INSTALL_DIR

if [ $MENU_ROGUELIKE = "Tangaria" ]; then
cp -iv ./Tangaria-$VERSION_TANGARIA/mangband.cfg ./${APP_DIR}$INSTALL_DIR/games
fi

cp -fv ./Tangaria-$VERSION_TANGARIA/lib/user/sdlinit.txt ${APP_DIR}$INSTALL_DIR/games

cd ./Tangaria-$VERSION_TANGARIA || exit 1
write_pwmangrc "$TARGET_DIR/tangaria_setup_files/${APP_DIR}$INSTALL_DIR/games/.pwmangrc"
cd ../ || exit 1

# Icons
cp -fv ./Tangaria-$VERSION_TANGARIA/lib/icons/att-128.png ./${APP_DIR}/usr/share/icons/hicolor/128x128/apps/pwmangclient.png
cp -fv ./Tangaria-$VERSION_TANGARIA/lib/icons/att.svg ./${APP_DIR}/usr/share/icons/hicolor/scalable/apps/pwmangclient.svg

fi

###################################

##########
mv ./${APP_DIR}/tmp/$MENU_ROGUELIKE ./${APP_DIR}/usr
rm -rf ./${APP_DIR}/tmp

#ln -s $INSTALL_DIR/bin/pwmangclient ./${APP_DIR}/AppRun

cat > ./${APP_DIR}/pwmangclient.desktop << EOF
[Desktop Entry]
Name=$MENU_ROGUELIKE
Type=Application
Comment=$MENU_ROGUELIKE (client)
Exec=pwmangclient
Icon=pwmangclient
Terminal=false
Categories=Game;RolePlaying;
EOF

if [ $MENU_ROGUELIKE = "PWMAngband" ]; then
cat > ./${APP_DIR}/AppRun << EOF
#!/bin/sh

SELF_DIR="\$(dirname "\$(readlink -f "\$0")")"
cd \${SELF_DIR} || exit 1
ln -sf \${SELF_DIR}/usr/$MENU_ROGUELIKE $INSTALL_DIR
cd \$HOME || {
    echo "ERROR: Could not change directory..."
    exit 1
}
\${SELF_DIR}/usr/bin/pwmangclient
EOF
chmod +x ./${APP_DIR}/AppRun
fi

if [ $MENU_ROGUELIKE = "Tangaria" ]; then
cat > ./${APP_DIR}/AppRun << EOF
#!/bin/sh

SELF_DIR="\$(dirname "\$(readlink -f "\$0")")"
cd \${SELF_DIR} || exit 1
ln -sf \${SELF_DIR}/usr/$MENU_ROGUELIKE $INSTALL_DIR

if ! [ -f \$HOME/.pwmangrc ]; then
cp -f ./usr/$MENU_ROGUELIKE/games/.pwmangrc \$HOME
fi

if ! [ -f \$HOME/.pwmangband/PWMAngband/sdlinit.txt ]; then
mkdir -p \$HOME/.pwmangband/PWMAngband
cp -f ./usr/$MENU_ROGUELIKE/games/sdlinit.txt \$HOME/.pwmangband/PWMAngband/
fi

cd ./usr/bin || exit 1

set -ex

"./pwmangclient"
EOF
chmod +x ./${APP_DIR}/AppRun
fi

# Bake AppImage
rm -f $MENU_ROGUELIKE*.AppImage*
./${LINUX_DEPLOY} \
--appdir ./${APP_DIR} \
--desktop-file ./${APP_DIR}/pwmangclient.desktop \
--output appimage

exit 0
}

do_install() {
clear
if [ $CHECKLIST_OPTIONS_APPIMAGE = ON ]; then
build_AppImage
fi

download_PWMAngband

##########
#make -C ./PWMAngband-$VERSION_PWMANGBAND clean
make_clean_PWMAngband

cd ./PWMAngband-$VERSION_PWMANGBAND || exit 1
./autogen.sh || exit 1

if [ $MENU_CLIENT = "sdl" ]; then
    ./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
fi
if [ $MENU_CLIENT = "curses" ]; then
    ./configure --prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl
fi
if [ $MENU_CLIENT = "other" ]; then
    ./configure --help
    echo " "
    read -ep "./configure " -i "$OTHER_CONFIGURE_PWMANGBAND" OTHER_CONFIGURE_PWMANGBAND
    ./configure $OTHER_CONFIGURE_PWMANGBAND
fi

make -j$CPU_CORES
make install

if [ $MENU_ROGUELIKE = "PWMAngband" ]; then
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
\$PWMANGCLIENT_DIR/pwmangclient

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
./pwmangband
EOF
chmod +x $INSTALL_DIR/pwmangband-launcher.sh
fi

cat > $XDG_DATA_HOME/applications/pwmangclient.desktop << EOF
[Desktop Entry]
Name=$MENU_ROGUELIKE (client)
Type=Application
Comment=$MENU_ROGUELIKE (client)
Exec=$INSTALL_DIR/games/pwmangclient
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=false
Categories=Game;RolePlaying;
EOF

cat > $XDG_DATA_HOME/applications/pwmangband.desktop << EOF
[Desktop Entry]
Name=$MENU_ROGUELIKE (server)
Type=Application
Comment=$MENU_ROGUELIKE (server)
Path=$INSTALL_DIR/games
Exec=$INSTALL_DIR/games/pwmangband
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=true
Categories=Game;RolePlaying;
EOF

###################################

if [ $MENU_ROGUELIKE = "Tangaria" ]; then

download_Tangaria

cd ./Tangaria-$VERSION_TANGARIA || exit 1

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

if [ $MENU_ROGUELIKE = "Tangaria" ]; then
cp -iv ./mangband.cfg $INSTALL_DIR/games
fi

if ! [ -d $USER_PWMANGBAND ]; then
    mkdir -p $USER_PWMANGBAND  
fi
if ! [ -d $USER_PWMANGBAND/PWMAngband ]; then
    mkdir -p $USER_PWMANGBAND/PWMAngband
fi
if ! [ -d $USER_PWMANGBAND/PWMAngband/save ]; then
    mkdir -p $USER_PWMANGBAND/PWMAngband/save
fi
if ! [ -d $USER_PWMANGBAND/PWMAngband/scores ]; then
    mkdir -p $USER_PWMANGBAND/PWMAngband/scores
fi

cp -nv ./lib/user/save/account $USER_PWMANGBAND/PWMAngband/save

if [ $CHECKLIST_OPTIONS_SDLINIT = ON ]; then
cp -iv ./lib/user/sdlinit.txt $USER_PWMANGBAND/PWMAngband
fi

if [ $CHECKLIST_OPTIONS_LINK_DIR_USER = ON ]; then
    if ! [ -e $INSTALL_DIR/user ]; then
    ln -s $USER_PWMANGBAND $INSTALL_DIR/user
    fi
fi

if ! [ -f $USER_PWMANGRC ]; then
write_pwmangrc $USER_PWMANGRC
else
echo -n "replace $USER_PWMANGRC ?     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», ok..."
         write_pwmangrc $USER_PWMANGRC
        ;;
    n|N) echo "«no», ok..."
        ;;
    *) echo "«no», ok..."
        ;;
esac
fi

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

        MAIN_MENU=$($DIALOG --title "Setup - Menu" --ok-button "Select" --cancel-button "Quit" --menu \
        "_.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._.-=-._\n " 19 71 9 \
            "$MENU_ROGUELIKE" "" \
            "Install Path" "$MENU_INSTALL_DIR" \
            "Version" "PWMAngband-$VERSION_PWMANGBAND" \
            "Client" "$MENU_CLIENT" \
            "Options" "" \
            "Update" "" \
            "Help" "" \
            "Install" ">>>------>" \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${MAIN_MENU} in
                "$MENU_ROGUELIKE")
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
