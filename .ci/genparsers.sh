#!/bin/bash
#
# This file is part of the Phalcon Framework.
#
# (c) Phalcon Team <team@phalcon.io>
#
# For the full copyright and license information, please view the
# LICENSE.txt file that was distributed with this source code.

set -e

: "${CC:=gcc}"

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
EXT_DIR=ext/phalcon
LANGS=(mvc/model/query mvc/view/engine/volt)

function cleanup() {
  find . \( -name '*.o' -o -name '*.lo' -o -name '*.loT' \) -exec rm -f {} +
  find . \( -name lemon -o -name parser.c \) -exec rm -f {} +
  find . -name .libs -exec rm -rf {} +
}

function compile_lemon() {
  "$CC" -g lemon.c -o ./lemon
  chmod +x ./lemon
}

function generate_lexer() {
  local uprefix="$1"
  local lprefix="$2"

  if [ -z "$(command -v re2c 2>/dev/null || true)" ]
  then
    (>&2 echo "No re2c found in the \$PATH.")
    (>&2 echo "Consider install re2c or/and add re2c executable to the \$PATH.")
    exit 1
  fi

  RE2C_VER="$(re2c --vernum 2>/dev/null)"

  if [ "$RE2C_VER" -gt "9999" ]
  then
    re2c --no-debug-info --no-generation-date -o scanner.c scanner.re
  else
    re2c -W --no-debug-info --no-generation-date -o scanner.c scanner.re
  fi

  sed -ri "s/YY/$uprefix/g" scanner.c
  sed -ri "s/yy/$lprefix/g" scanner.c
}

function generate_parser() {
  pwd

  local uprefix="$1"
  local lprefix="$2"
  local tprefix="$3"

  ./lemon -s parser.php7.lemon

  echo '#include "php_phalcon.h"' > parser.c
  cat parser.php7.c >> parser.c
  cat base.c >> parser.c

  sed -ri 's|#line|//|g' parser.c
  sed -ri "s/define TOKEN/define ${tprefix}TOKEN/g" parser.c
  sed -ri "s/YY/$uprefix/g" parser.c
  sed -ri "s/yy/$lprefix/g" parser.c
}

for lang in "${LANGS[@]}"
do
  pushd "$BASE_PATH/$EXT_DIR/$lang" > /dev/null 2>&1 || exit 1
    (>&1 printf "Regenerate language for: %s\\n" "$EXT_DIR/$lang")

    cleanup
    compile_lemon

    case "$lang" in
    "mvc/model/query")
        UPREFIX="PP"
        LPREFIX="pp"
        TPREFIX="V"
        ;;
    "mvc/view/engine/volt")
        UPREFIX="VV"
        LPREFIX="vv"
        TPREFIX="PP"
        ;;
    *)
      (>&2 echo "Usupported language: $lang")
      exit 1
        ;;
    esac

    generate_lexer "$UPREFIX" "$LPREFIX"
    generate_parser "$UPREFIX" "$LPREFIX" "$TPREFIX"

  popd > /dev/null 2>&1 || exit 1

  (>&1 echo "Done")
done
