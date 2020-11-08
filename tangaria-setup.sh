#!/bin/sh

## Script for setup Tangaria.
##
## Link to latest version: https://raw.githubusercontent.com/igroglaz/Tangaria/master/tangaria-setup.sh
##      Github PWMAngband: https://github.com/draconisPW/PWMAngband
##      PWMAngband binaries: https://powerwyrm.monsite-orange.fr/page-56e3134c5ebab.html
##      Github Tangaria: https://github.com/igroglaz/Tangaria
##      Link to Tangaria: https://tangaria.com/
##      Discord channel:https://discord.gg/zBNG369
##

#### to make script executable, use chmod +x ./tangaria-setup.sh
#### if you have Debian-based linux*** (Ubuntu, Mint, etc) requires: sudo apt-get install build-essential autoconf libsdl1.2debian libsdl-ttf2.0-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libncurses5-dev
#### ***if you use RPM-based linux (Fedora, Centos, openSUSE..) the command to obtain build tools is something like: sudo yum group install "Development Tools"
####    and the command to obtain all the needed libraries is: sudo yum install SDL-devel SDL_ttf-devel SDL_mixer-devel SDL_image-devel ncurses-devel

########### INSTALL_DIR ###########

INSTALL_DIR=$HOME/Tangaria

###################################

REPOSITORY_URL_PWMANGBAND="https://github.com/draconisPW/PWMAngband/archive/"
REPOSITORY_URL_TANGARIA="https://github.com/igroglaz/Tangaria/archive/"

###################################

printerr() {
    echo "ERROR: $*" >&2
}

TARGET_DIR=$(dirname "$(readlink -f $0)")

cd "$(dirname "$TARGET_DIR")" || {
    printerr "Could not change directory to '$TARGET_DIR'"
    exit 1
}

if ! [ -d ./tangaria_setup_files ]; then
  mkdir -p $TARGET_DIR/tangaria_setup_files
fi

cd $TARGET_DIR/tangaria_setup_files || {
    printerr "Could not change directory to '$TARGET_DIR'"
    exit 1
}

echo "----------------------------------"
echo "-----  Tangaria linux setup  -----"
echo "----------------------------------"

echo -n "Install path:$INSTALL_DIR     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», Ok..."
        ;;
    n|N) read -p "enter path:" INSTALL_DIR
        ;;
    *) echo "«y» or «n». Exit..."
       exit 0
        ;;
esac

if [ -z $INSTALL_DIR ]
 then
 echo "path is empty string..."
 exit 0
fi

if ! [ -d $INSTALL_DIR ]; then
  mkdir -p $INSTALL_DIR
fi

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

echo -n "Install PWMAngband? path:$INSTALL_DIR     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», Ok..."

echo -n "Select PWMAngband version?  y:master(latest)  n:other(branches)     (y/n)"
read item
case "$item" in
    y|Y) echo "«y:PWMAngband-master», Ok..."
         VERSION_PWMANGBAND="master"
         rm -r ./PWMAngband-*".zip"
         wget --output-document=PWMAngband-$VERSION_PWMANGBAND.zip $REPOSITORY_URL_PWMANGBAND"/"$VERSION_PWMANGBAND".zip" || exit 1
        ;;
    n|N) echo "follow the link https://github.com/draconisPW/PWMAngband/branches"
         read -p "enter: PWMAngband-" VERSION_PWMANGBAND
         rm -r ./PWMAngband-*".zip"
         wget --output-document=PWMAngband-$VERSION_PWMANGBAND.zip $REPOSITORY_URL_PWMANGBAND"/"$VERSION_PWMANGBAND".zip" || exit 1
        ;;
    *) echo "«y» or «n»   skip update..."
       if ! [ -e "$(ls -A . | head -1)" ]; then
        echo "./tangaria_setup_files   empty directory..."
        exit 0
       fi
       
       if ! [ -d $(ls -d PWMAngband-* | head -1 || exit 1) ];
        then
        VERSION_PWMANGBAND=$(ls -d PWMAngband-* | head -1 | sed -e 's/.*PWMAngband-//; s/.zip*//')
        echo "Ok... PWMAngband-$VERSION_PWMANGBAND"
        else
        VERSION_PWMANGBAND=$(ls -d PWMAngband-*/ | head -1 | sed -e 's/.*PWMAngband-//; s/.$//')
        echo "Ok... PWMAngband-$VERSION_PWMANGBAND"
       fi
        ;;
esac

echo -n "Unpack PWMAngband-$VERSION_PWMANGBAND.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             rm -r $(ls -d PWMAngband-*/)
             unzip -o PWMAngband-$VERSION_PWMANGBAND.zip || exit 1
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac

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

cd ./$(ls -d PWMAngband-*/ | head -1)
./autogen.sh || exit 1

# ./configure --help

echo -n "./configure  y:sdl-client  n:curses-client(terminal)     (y/n)"
read item
case "$item" in
    y|Y) echo "«y:sdl-client», Ok..."
         ./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
        ;;
    n|N) echo "«n:curses-client(terminal)», Ok..."
         ./configure --prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl
        ;;
    *) echo "«y» or «n». sdl-client(default)..."
       ./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
        ;;
esac

#make -j8
make
make install

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

if ! [ -d $INSTALL_DIR/user ]; then
ln -s $HOME/.pwmangband $INSTALL_DIR/user
fi

cp -f ./setup/mangband.cfg $INSTALL_DIR/games

cd ../

if ! [ -f $INSTALL_DIR/pwmangclient-launcher.sh ]; then
cat > $INSTALL_DIR/pwmangclient-launcher.sh << EOF
#!/bin/sh
cd "\$(dirname "\$0")"/games
./pwmangclient --config mangclient_sdl.INI
# ./pwmangclient
# \$HOME/.mangrc

# mangclient_sdl.INI
#
# [MAngband]
# nick=PLAYER
# pass=pass
# ;host=localhost
# meta_address=mangband.org
# meta_port=8802
# DisableNumlock=1
EOF
chmod +x $INSTALL_DIR/pwmangclient-launcher.sh
fi

if ! [ -f $INSTALL_DIR/pwmangband-launcher.sh ]; then
cat > $INSTALL_DIR/pwmangband-launcher.sh << EOF
#!/bin/sh
cd "\$(dirname "\$0")"/games
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
Path=$INSTALL_DIR/games
Exec=$INSTALL_DIR/games/pwmangclient --config mangclient_sdl.INI
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

        ;;
    n|N) echo "«no», Ok..."
        ;;
    *) echo "«y» or «n». Exit..."
       exit 0
        ;;
esac

##### exit 0 ##########PWMAngband#####

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

VERSION_TANGARIA="master"

echo -n "Install Tangaria? path:$INSTALL_DIR     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», Ok..."
        ;;
    n|N) echo "«no», Exit..."
         exit 0
        ;;
    *) echo "«y» or «n». Exit..."
       exit 0
        ;;
esac

if ! [ -f ./Tangaria-$VERSION_TANGARIA.zip ];
    then
    rm -r ./Tangaria-*".zip"
    wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA"/"$VERSION_TANGARIA".zip" || exit 1
    else
    echo -n "Update Tangaria-$VERSION_TANGARIA.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             rm -r ./Tangaria-*".zip"
             wget --output-document=Tangaria-$VERSION_TANGARIA.zip $REPOSITORY_URL_TANGARIA"/"$VERSION_TANGARIA".zip" || exit 1
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

if ! [ -d ./Tangaria-$VERSION_TANGARIA ];
    then
    unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
    else
    echo -n "Unpack Tangaria-$VERSION_TANGARIA.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             rm -r $(ls -d Tangaria-*/)
             unzip -o Tangaria-$VERSION_TANGARIA.zip || exit 1
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

cd ./Tangaria-$VERSION_TANGARIA

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

if ! [ -d $INSTALL_DIR/user ]; then
ln -s $HOME/.pwmangband $INSTALL_DIR/user
fi

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

cp -i ./mangclient_sdl.INI $INSTALL_DIR/games
cp -f ./mangband.cfg $INSTALL_DIR/games

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
