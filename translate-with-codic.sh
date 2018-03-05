#!/bin/bash
# usage:
#  * ./translate_with_codic.sh 英訳したい日本語
#  * 標準入力からでも OK

# 英訳結果の区切り文字
SEPARATOR='_'

readonly ACCESS_TOKEN=$(head -1 "$(dirname $0)/access_token")
TEXT=$1
# 引数が空なら標準入力からの取得を試みる
[[ -z $TEXT ]] && read TEXT && [[ -z $TEXT ]] && exit 1

# API をコール
RESPONSE=$(curl --silent \
     -H 'Host: api.codic.jp' \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://api.codic.jp/v1/engine/translate.json?text=$TEXT")
RETURN_CODE=$?
[[ $RETURN_CODE -ne 0 ]] && exit $RETURN_CODE

# API の成功可否と翻訳結果だけ得られればよいので、抜き出す
# \u1234 のようなコードポイントは \x{1234} の形に整形する
TRANSLATED_TEXT=$(echo $RESPONSE \
  | perl -ne 'print "$1 " if /"translated_text":"([^"]+)"/' \
  | perl -pe 's/\\u([0-9a-f]+)/\\x\{$1\}/g' \
  | perl -pe "s/ /$SEPARATOR/g")

# 失敗したぽいならレスポンスを全文出力して逃げる
[[ $TRANSLATED_TEXT == '' ]] && echo "error. response= $RESPONSE" 1>&2 && exit 1
# 末尾の区切り文字を削除
TRANSLATED_TEXT="${TRANSLATED_TEXT%${SEPARATOR}}"

# 出力する
perl -CS -E "say \"$TRANSLATED_TEXT\""
exit 0
