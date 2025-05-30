#!/bin/sh
#
# install.sh
#
# One-click install Boshiamy for RIME
#

# Detects Platform
case `uname -s` in
  "Darwin" )
    PLATFORM="mac"
    RIME_HOME="$HOME/Library/Rime"
    ;;
  "Linux" )
    PLATFORM="linux"
    RIME_HOME="$HOME/.config/ibus/rime/"
    ;;
  *)
    PLATFORM="unknown"
    RIME_HOME=`pwd` # use current dir for install path
    ;;
esac

# Converts ibus boshiamy table to rime table.
#
# @param name [String] boshiamy_t or boshiamy_j
#
# @return 0 if installed successfully
# @return 1 if the table file does not exist
function install_boshiamy() {
  name=$1
  table_file="$name.db"
  dict_file="$name.dict.yaml"
  schema_file="$name.schema.yaml"

  if [[ -f $table_file ]]; then
    ./ibus2rime.sh $table_file

    cp $dict_file $schema_file $RIME_HOME

    echo "$name -- \033[1;32mDone\033[m"
    echo ""

    return 0
  else
    echo "File $table_file not found, skipping."
    return 1
  fi
}

install_boshiamy boshiamy_t
install_boshiamy boshiamy_j

if [[ $PLATFORM == "unknown" ]]; then
  echo "\033[31mUnsupported OS detected\033[m"
  echo "Converted *.yaml files will be placed in this folder. Please copy them to your RIME user folder manually."
  echo ""
else
  echo "After conversion, please edit \033[1;33m$RIME_HOME/default.custom.yaml\033[m and add Boshiamy input method, for example:"
  echo ""
  echo "    patch:"
  echo "      schema_list:  # For list types, you need to replace the whole list in the custom file!"
  echo "        - schema: luna_pinyin"
  echo "        - schema: cangjie5"
  echo "        - schema: luna_pinyin_fluency"
  echo "        - schema: luna_pinyin_simp"
  echo "        - schema: luna_pinyin_tw"
  echo "\033[32m        - schema: boshiamy_t  # Boshiamy Chinese mode\033[m"
  echo "\033[32m        - schema: boshiamy_j  # Boshiamy Japanese mode\033[m"
  echo    ""
fi
