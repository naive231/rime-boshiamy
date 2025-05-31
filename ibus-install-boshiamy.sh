#!/bin/sh

REVDATE="2009.11.02"
VERSION="1.1"

impath=/usr/share/ibus-table
destpath=$impath/tables
iconpath=$impath/icons

curpath=`dirname "$0"`

UseUTF8() {
    S_VERDESC="(相容於 嘸蝦米輸入法 7.0.4 標準版 on MS-Windows)"

    S_PRESS_Y_OR_N="請輸入 y 或 n ..."

    S_COPY="複製"
    S_DONE="完成"
    S_FAILED="失敗"

    S_MISSSOURCE="檔案來源遺失！"

    S_PRESS_ENTER_QUIT="(請按 Enter 鍵結束...)"

    S_EULA="本安裝套件之所有內容（包含表格檔、圖示檔及相關文件）均為 行易有限公司 (http://boshiamy.com) 版權所有。本公司授權合法持有嘸蝦米輸入法 7.0 非試用版之使用者自行利用，惟使用者不得任意更改此表格中每個字的編碼規則以及本套件之任何內容，亦不得以轉換格式或片段節錄等任何方法重新散佈！此表格授權使用範圍與使用者持有之授權合約書所載範圍相同，其他未載明之事項，一律依原授權合約書內容辦理之。"

    S_REVDATE="釋出日期： $REVDATE"
    S_VERSION="表格檔版本： $VERSION $S_VERDESC"

    S_INFO="本安裝程序將為您安裝 嘸蝦米輸入法 IBus 表格檔及其相關圖示檔\n(安裝過程中可能會要求您輸入目前使用者的登入密碼)"
    S_DESTPATH="表格安裝路徑"
    S_ICONPATH="圖示安裝路徑"

    S_CONFIRMINSTALL="您是否確定要安裝？"
    S_ABORT="安裝已中斷！"

    S_NOMODULE="找不到 $impath 路徑，您可能尚未安裝 IBus 模組！"
    S_NOTDEFAULT="您目前的預設輸入法引擎並非是 IBus，是否仍然要安裝？"

    S_NEEDROOT="本程序必須存取 /usr 目錄，而您目前的使用者權限不足！\n請試著登入 root 帳戶再重新操作一次"

    S_CANNOTREMOVE="無法移除舊的 嘸蝦米輸入法 IBus 表格檔，已取消安裝！"

    S_FINISH="安裝結束！\n請在 IBus 圖示上先點選「重新啟動」後，再進入「IBus → 偏好設定 → 輸入法 → 選擇輸入法」當中，從「漢語」底下新增您所需要的嘸蝦米輸入模式，即可開始使用。"
}

UseEng() {
    S_VERDESC="(compatible with \"Boshiamy 7.0.4 Standard\" on MS-Windows)"

    S_PRESS_Y_OR_N="Press 'y' or 'n' ..."

    S_COPY="Copy"
    S_DONE="done"
    S_FAILED="failed"

    S_MISSSOURCE="missed!!"

    S_PRESS_ENTER_QUIT="(Press Enter to exit ...)"

    S_EULA="This package is copyright by Boshiamy C&C Ltd. (http://boshiamy.com)\nYou must read and agree our EULA in README file first."

    S_REVDATE="Release Date： $REVDATE"
    S_VERSION="Tables Version： $VERSION $S_VERDESC"

    S_INFO="This script will install tables and icons of Boshiamy IM in your IBus engine.\n(It may require the password of current user)"
    S_DESTPATH="Tables path: "
    S_ICONPATH="Icons poth: "

    S_CONFIRMINSTALL="Continue? "
    S_ABORT="Abort!"

    S_NOMODULE="'$impath' Path not found!\nThat might be no IBus engine installed in your system..."
    S_NOTDEFAULT="The IBus engine is not your default input method, Cotinue anyway?"

    S_NEEDROOT="Current user account is not enough to access '/usr' !\nTry to log in as root first..."

    S_CANNOTREMOVE="Can't remove former tables of Boshiamy! Installation cancelled!"

    S_FINISH="Finish!\nPlease restart the IBus engine and follow the instructions in README file to set up your IME."
}

if echo $LANG | grep -i utf >/dev/null; then
    UseUTF8
else
    UseEng
fi

#################################################

YesNo() {
    msg="$1"
    default="$2"

    while : ; do
        if [ $default = 1 ]; then
            printf "$msg (y/[N]): "
        else
            printf "$msg ([Y]/n): "
        fi

        read answer

        if [ "$answer" ]; then
            case "$answer" in
                "y" | "Y" | "yes" | "Yes")
                    return 0
                           ;;
                "n" | "N" | "no" | "No")
                    return 1
                           ;;
                    *)
                    printf "$S_PRESS_Y_OR_N\n\n"
                    continue
                           ;;
            esac
        else
            return $default
        fi
    done
}

copyfile() {
    if [ -f "$curpath/$2" ]; then 
        printf "$S_COPY $2 ... " 
        sudo cp "$curpath/$2" $1

        if [ -f $1/$2 ]; then
            echo "$S_DONE"
        else
            echo "$S_FAILED"
        fi
    else
        printf "$2 $S_MISSSOURCE\n"
    fi
}

checkexist() {
    for fname in $2 $3 $4 $5; do
        if [ -f $1/$fname ]; then 
            exist=`expr $exist + 1`
        fi
    done
}

checktabs() {
    checkexist $destpath 'boshiamy_t.db' 'boshiamy_c.db' 'boshiamy_ct.db' 'boshiamy_j.db'
}

checkicons() {
    checkexist $iconpath 'boshiamy-t.png' 'boshiamy-c.png' 'boshiamy-ct.png' 'boshiamy-j.png'
}

terminal() {
    printf "$S_PRESS_ENTER_QUIT"
    read quit
    exit
}

#################################################

printf "$S_EULA\n\n"

printf "$S_REVDATE\n"
printf "$S_VERSION\n\n"

printf "===================================================\n\n"

printf "$S_INFO\n\n"
printf "$S_DESTPATH: $destpath\n$S_ICONPATH: $iconpath\n\n"

if ! YesNo "$S_CONFIRMINSTALL" 1; then 
    printf "\n$S_ABORT\n"
    terminal
fi

echo ''

if [ ! -d $impath ]; then
    printf "$S_NOMODULE\n"
    terminal
fi

if ! `echo $XMODIFIERS | grep -i "ibus" > /dev/null`; then
    if YesNo "$S_NOTDEFAULT" 1; then
        echo ''
    else
        printf "\n$S_ABORT\n"
        terminal
    fi
fi

if ! `sudo -l | grep -i "(ALL)" > /dev/null`; then
    printf "\n$S_NEEDROOT\n"
    terminal
fi

echo ''

if [ ! -d $destpath ]; then
    sudo mkdir -p -v $destpath
fi

if [ ! -d $iconpath ]; then
    sudo mkdir  -p -v $iconpath
fi

exist=0
checktabs
if [ $exist -gt 0 ]; then
    sudo rm $destpath/boshiamy_*.db
fi

exist=0
checkicons
if [ $exist -gt 0 ]; then
    sudo rm $iconpath/boshiamy-*.png
fi

exist=0
checktabs
checkicons

if [ $exist -gt 0 ]; then
    printf "$S_CANNOTREMOVE\n"
    sudo -K
    terminal
fi

copyfile $destpath 'boshiamy_t.db'
copyfile $destpath 'boshiamy_c.db'
copyfile $destpath 'boshiamy_ct.db'
copyfile $destpath 'boshiamy_j.db'

copyfile $iconpath 'boshiamy-t.png'
copyfile $iconpath 'boshiamy-c.png'
copyfile $iconpath 'boshiamy-ct.png'
copyfile $iconpath 'boshiamy-j.png'

printf "\n$S_FINISH\n"
sudo -K
terminal
