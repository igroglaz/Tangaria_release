#!/bin/bash

## Script for setup Tangaria.
##
## Link to latest version: https://raw.githubusercontent.com/igroglaz/Tangaria/master/tangaria-setup.sh
##      Github PWMAngband: https://github.com/draconisPW/PWMAngband
##      PWMAngband binaries: https://powerwyrm.monsite-orange.fr/page-56e3134c5ebab.html
##      Github Tangaria: https://github.com/igroglaz/Tangaria
##      Link to Tangaria: https://tangaria.com/
##      Discord channel:https://discord.gg/zBNG369
##

README='
to make script executable, use chmod +x ./tangaria-setup.sh
if you have Debian-based linux*** (Ubuntu, Mint, etc) requires: sudo apt-get install build-essential autoconf libsdl1.2debian libsdl-ttf2.0-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libncurses5-dev
***if you use RPM-based linux (Fedora, RHEL, CentOS..) the command to obtain build tools is something like: sudo dnf group install "Development Tools"
and the command to obtain all the needed libraries is: sudo dnf install SDL-devel SDL_ttf-devel SDL_mixer-devel SDL_image-devel ncurses-devel
'

########### INSTALL DIR ###########

INSTALL_DIR=$HOME/Tangaria

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

CHECKLIST_OPTIONS_LINK_DIR_USER=ON

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

radioListRoguelike() {
    MENU_ROGUELIKE=$($DIALOG --title "Roguelike Game" --nocancel --radiolist \
        "use UP/DOWN, SPACE, ENTER keys\nChoose a roguelike game:" 16 54 6 \
            "Tangaria" "tangaria.com " $RADIOLIST_ROGUELIKE_TANGARIA \
            "PWMAngband" "powerwyrm.monsite-orange.fr " $RADIOLIST_ROGUELIKE_PWMANGBAND \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${MENU_ROGUELIKE} in
                Tangaria)
                    RADIOLIST_ROGUELIKE_TANGARIA=ON
                    RADIOLIST_ROGUELIKE_PWMANGBAND=OFF
                ;;
                PWMAngband)
                    RADIOLIST_ROGUELIKE_TANGARIA=OFF
                    RADIOLIST_ROGUELIKE_PWMANGBAND=ON
                ;;
            esac
        else
            clear
            exit 0
        fi
}

inputBoxInstallPath() {
    INSTALL_DIR=$($DIALOG --title "Install path" --nocancel --inputbox \
        "enter path:" 8 78 $INSTALL_DIR 3>&1 1>&2 2>&3)

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
            case ${MENU_VERSION_PWMANGBAND} in
                master)
                    RADIOLIST_VERSION_PWMANGBAND_MASTER=ON
                    RADIOLIST_VERSION_PWMANGBAND_OTHER=OFF
                    VERSION_PWMANGBAND="master"
                ;;
                other)
                    RADIOLIST_VERSION_PWMANGBAND_MASTER=OFF
                    RADIOLIST_VERSION_PWMANGBAND_OTHER=ON
                    VERSION_PWMANGBAND=$($DIALOG --title "other(branches)" --nocancel --inputbox \
                    "follow the link https://github.com/draconisPW/PWMAngband/branches \nenter: PWMAngband-" 9 78 $VERSION_PWMANGBAND 3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ ${exitstatus} != 0 ]; then
                        clear
                        exit 0
                    fi
                ;;
            esac
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
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${MENU_CLIENT} in
                sdl)
                    RADIOLIST_CLIENT_SDL=ON
                    RADIOLIST_CLIENT_CURSES=OFF
                ;;
                curses)
                    RADIOLIST_CLIENT_SDL=OFF
                    RADIOLIST_CLIENT_CURSES=ON
                ;;
            esac
        else
            clear
            exit 0
        fi
}

checkListOptions() {
    MENU_OPTIONS=$($DIALOG --title "Options" --nocancel --separate-output --checklist \
        "use UP/DOWN, SPACE, ENTER keys\nSelect update options:" 16 54 6 \
            "link directory user" "" $CHECKLIST_OPTIONS_LINK_DIR_USER \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            if printf "%s\n" "${MENU_OPTIONS[@]}" | grep -x -q "link directory user"; then
                CHECKLIST_OPTIONS_LINK_DIR_USER=ON
            else
                CHECKLIST_OPTIONS_LINK_DIR_USER=OFF
            fi
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
            if printf "%s\n" "${MENU_UPDATE[@]}" | grep -x -q "Download PWMAngband"; then
                CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND=ON
            else
                CHECKLIST_UPDATE_DOWNLOAD_PWMANGBAND=OFF
            fi
            if printf "%s\n" "${MENU_UPDATE[@]}" | grep -x -q "Unpack PWMAngband"; then
                CHECKLIST_UPDATE_UNPACK_PWMANGBAND=ON
            else
                CHECKLIST_UPDATE_UNPACK_PWMANGBAND=OFF
            fi
            if printf "%s\n" "${MENU_UPDATE[@]}" | grep -x -q "Download Tangaria"; then
                CHECKLIST_UPDATE_DOWNLOAD_TANGARIA=ON
            else
                CHECKLIST_UPDATE_DOWNLOAD_TANGARIA=OFF
            fi
            if printf "%s\n" "${MENU_UPDATE[@]}" | grep -x -q "Unpack Tangaria"; then
                CHECKLIST_UPDATE_UNPACK_TANGARIA=ON
            else
                CHECKLIST_UPDATE_UNPACK_TANGARIA=OFF
            fi
        else
            clear
            exit 0
        fi
}

messageBoxHelp() {
    $DIALOG --title "Help" --msgbox "$README" 24 71
}

do_install() {
clear
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
    rm -r ./PWMAngband-*".zip"
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
    rm -r $(ls -d PWMAngband-*/)
    unzip -o PWMAngband-$VERSION_PWMANGBAND.zip || exit 1
fi

###################################
#make -C $(ls -d PWMAngband-*/ | head -1) clean

if [ -d $(ls -d PWMAngband-*/ | head -1) ]; then
make -C $(ls -d PWMAngband-*/ | head -1) clean

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/pwmangband.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/pwmangband.o
fi

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/pwmangclient.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/pwmangclient.o
fi

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/client/main-sdl.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/client/main-sdl.o
fi

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/client/main.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/client/main.o
fi

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/client/snd-sdl.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/client/snd-sdl.o
fi

if [ -f $(ls -d PWMAngband-*/ | head -1)/src/client/main-gcu.o ] ; then
rm -r $(ls -d PWMAngband-*/ | head -1)/src/client/main-gcu.o
fi

fi
###################################

cd ./$(ls -d PWMAngband-*/ | head -1) || exit 1
./autogen.sh || exit 1

# ./configure --help

if [ $MENU_CLIENT = "sdl" ]; then
    ./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
fi

if [ $MENU_CLIENT = "curses" ]; then
    ./configure --prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl
fi

make -j$CPU_CORES
make install

cp -f ./setup/mangband.cfg $INSTALL_DIR/games

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

if ! [ -f $INSTALL_DIR/pwmangclient.desktop ]; then
cat > $INSTALL_DIR/pwmangclient.desktop << EOF
[Desktop Entry]
Name=PWMAngband (client)
Type=Application
Comment=PWMAngband (client)
Exec=$INSTALL_DIR/games/pwmangclient
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=false
Categories=Game;RolePlaying;
EOF
chmod +x $INSTALL_DIR/pwmangclient.desktop
fi

if ! [ -f $INSTALL_DIR/pwmangband.desktop ]; then
cat > $INSTALL_DIR/pwmangband.desktop << EOF
[Desktop Entry]
Name=PWMAngband (server)
Type=Application
Comment=PWMAngband (server)
Path=$INSTALL_DIR/games
Exec=$INSTALL_DIR/games/pwmangband
Icon=$INSTALL_DIR/share/pwmangband/icons/att-128.png
Terminal=true
Categories=Game;RolePlaying;
EOF
chmod +x $INSTALL_DIR/pwmangband.desktop
fi

###################################

if [ $MENU_ROGUELIKE = "Tangaria" ]; then

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
    rm -r ./Tangaria-*".zip"
    wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA$VERSION_TANGARIA".zip" || exit 1
else
    if [ $CHECKLIST_UPDATE_DOWNLOAD_TANGARIA = ON ]; then
        rm -r ./Tangaria-*".zip"
        wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA$VERSION_TANGARIA".zip" || exit 1
    fi
fi

if ! [ -d ./Tangaria-$VERSION_TANGARIA ]; then
    unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
else
    if [ $CHECKLIST_UPDATE_UNPACK_TANGARIA = ON ]; then
        rm -r $(ls -d Tangaria-*/)
        unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
    fi

fi

cd ./Tangaria-$VERSION_TANGARIA || exit 1

if ! [ -d $INSTALL_DIR/etc ]; then
  mkdir -p $INSTALL_DIR/etc/pwmangband/customize
  mkdir -p $INSTALL_DIR/etc/pwmangband/gamedata
fi
if ! [ -d $INSTALL_DIR/games ]; then
  mkdir -p $INSTALL_DIR/games  
fi
if ! [ -d $INSTALL_DIR/share ]; then
  mkdir -p $INSTALL_DIR/share/pwmangband/fonts
  mkdir -p $INSTALL_DIR/share/pwmangband/help
  mkdir -p $INSTALL_DIR/share/pwmangband/icons
  mkdir -p $INSTALL_DIR/share/pwmangband/screens
  mkdir -p $INSTALL_DIR/share/pwmangband/sounds
  mkdir -p $INSTALL_DIR/share/pwmangband/tiles
fi

if ! [ -d $HOME/.pwmangband ]; then
  mkdir -p $HOME/.pwmangband  
fi
if ! [ -d $HOME/.pwmangband/PWMAngband ]; then
  mkdir -p $HOME/.pwmangband/PWMAngband
fi
if ! [ -d $HOME/.pwmangband/PWMAngband/save ]; then
  mkdir -p $HOME/.pwmangband/PWMAngband/save
fi
if ! [ -d $HOME/.pwmangband/PWMAngband/scores ]; then
  mkdir -p $HOME/.pwmangband/PWMAngband/scores
fi

echo "copying files..."

rm -r $INSTALL_DIR/etc/pwmangband/customize
cp -R ./lib/customize $INSTALL_DIR/etc/pwmangband
rm -r $INSTALL_DIR/etc/pwmangband/gamedata
cp -R ./lib/gamedata $INSTALL_DIR/etc/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/fonts
cp -R ./lib/fonts $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/help
cp -R ./lib/help $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/icons
cp -R ./lib/icons $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/screens
cp -R ./lib/screens $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/sounds
cp -R ./lib/sounds $INSTALL_DIR/share/pwmangband
rm -r $INSTALL_DIR/share/pwmangband/tiles
cp -R ./lib/tiles $INSTALL_DIR/share/pwmangband

cp -n ./lib/user/save/account $HOME/.pwmangband/PWMAngband/save
cp -i ./lib/user/sdlinit.txt $HOME/.pwmangband/PWMAngband

cp -f ./lib/readme.txt $INSTALL_DIR/share/pwmangband
cp -f ./Changes.txt $INSTALL_DIR
cp -f ./Manual.html $INSTALL_DIR
cp -f ./Manual.pdf $INSTALL_DIR

cp -f ./mangband.cfg $INSTALL_DIR/games

if [ $CHECKLIST_OPTIONS_LINK_DIR_USER = ON ]; then
  if ! [ -e $INSTALL_DIR/user ]; then
  ln -s $HOME/.pwmangband $INSTALL_DIR/user
  fi
fi

write_pwmangrc() {
NICK=$(sed -n '/nick=/p' ./mangclient.ini)
PASS=$(sed -n '/pass=/p' ./mangclient.ini)
HOST=$(sed -n '/host=/p' ./mangclient.ini)
META_ADDRESS=$(sed -n '/meta_address=/p' ./mangclient.ini)
META_PORT=$(sed -n '/meta_port=/p' ./mangclient.ini)
DISABLENUMLOCK=$(sed -n '/DisableNumlock=/p' ./mangclient.ini)
LIGHTERBLUE=$(sed -n '/LighterBlue=/p' ./mangclient.ini)
cat > $HOME/.pwmangrc << EOF
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

if ! [ -f $HOME/.pwmangrc ]; then
 write_pwmangrc
else
echo -n "replace $HOME/.pwmangrc ?     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», ok..."
         write_pwmangrc
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
            "Install" "" \
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
