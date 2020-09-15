#!/bin/sh

#sudo apt-get install build-essential autoconf libsdl1.2debian libsdl-ttf2.0-dev libsdl-image1.2-dev libsdl-mixer1.2-dev

cd "$(dirname "$0")"

########## INSTALL_DIR ##########
INSTALL_DIR=$HOME/Tangaria
#################################

echo "----------------------------------"
echo "-----  Tangaria linux setup  -----"
echo "----------------------------------"

echo -n "Install path:$INSTALL_DIR     (y/n)"
read item
case "$item" in
    y|Y) echo "«yes», Ok..."
        ;;
    n|N) read -p "Enter path:" INSTALL_DIR
        ;;
    *) echo "«y» or «n». Exit..."
       exit 0
        ;;
esac
echo "...path:$INSTALL_DIR"
sleep 2

if [ -z "$INSTALL_DIR" ]
 then
 exit 0
fi

mkdir -p $INSTALL_DIR

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
sleep 2

if ! [ -f ./PWMAngband-master.zip ];
    then
    wget --output-document=PWMAngband-master.zip https://github.com/draconisPW/PWMAngband/archive/master.zip
    else
    echo -n "Update PWMAngband-master.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             wget --output-document=PWMAngband-master.zip https://github.com/draconisPW/PWMAngband/archive/master.zip
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

if ! [ -d ./PWMAngband-master ];
    then
    unzip -o PWMAngband-master.zip
    else
    echo -n "Unpack PWMAngband-master.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             rm -r ./PWMAngband-master
             unzip -o PWMAngband-master.zip
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

cd ./PWMAngband-master
./autogen.sh
# ./configure --prefix $INSTALL_DIR --enable-curses --disable-x11 --disable-sdl
./configure --prefix $INSTALL_DIR --disable-curses --disable-x11 --enable-sdl
make clean
# make -j8
make
make install

mkdir -p $INSTALL_DIR/var
mkdir -p $INSTALL_DIR/var/games
mkdir -p $INSTALL_DIR/var/games/pwmangband
mkdir -p $INSTALL_DIR/var/games/pwmangband/user
mkdir -p $INSTALL_DIR/var/games/pwmangband/user/save
mkdir -p $INSTALL_DIR/var/games/pwmangband/user/scores
cp -f ./setup/mangclient_sdl.INI $INSTALL_DIR/games
cp -f ./setup/mangband.cfg $INSTALL_DIR/games
cd ../

cat > ./pwmangclient-launcher.sh << EOF
#!/bin/sh
cd "\$(dirname "\$0")"/games
./pwmangclient --config mangclient_sdl.INI
# ./pwmangclient
# $HOME/.mangrc
EOF

cat > ./pwmangband-server.sh << EOF
#!/bin/sh
cd "\$(dirname "\$0")"/games
./pwmangband
EOF

chmod +x ./pwmangclient-launcher.sh
chmod +x ./pwmangband-server.sh
cp -f ./pwmangclient-launcher.sh $INSTALL_DIR
cp -f ./pwmangband-server.sh $INSTALL_DIR

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
sleep 2

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

if ! [ -f ./Tangaria-master.zip ];
    then
    wget --output-document=Tangaria-master.zip https://github.com/igroglaz/Tangaria/archive/master.zip
    else
    echo -n "Update Tangaria-master.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             wget --output-document=Tangaria-master.zip https://github.com/igroglaz/Tangaria/archive/master.zip
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

if ! [ -d ./Tangaria-master ];
    then
    unzip -o Tangaria-master.zip
    else
    echo -n "Unpack Tangaria-master.zip ?     (y/n)"
    read item
    case "$item" in
        y|Y) echo "«yes», Ok..."
             rm -r ./Tangaria-master
             unzip -o Tangaria-master.zip
            ;;
        n|N) echo "«no», Ok..."
            ;;
        *) echo "«no», Ok..."
            ;;
    esac
fi

cd ./Tangaria-master

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
rm -r $INSTALL_DIR/var/games/pwmangband/user
cp -R ./lib/user $INSTALL_DIR/var/games/pwmangband
cp -f ./lib/user/sdlinit.txt $INSTALL_DIR/var/games/pwmangband/user

cp -f ./lib/readme.txt $INSTALL_DIR/share/pwmangband
cp -f ./Changes.txt $INSTALL_DIR
cp -f ./Manual.html $INSTALL_DIR
cp -f ./Manual.pdf $INSTALL_DIR

cp -f ./mangclient_sdl.INI $INSTALL_DIR/games
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
