#!/bin/bash
# usage:
#  * ./translate_with_codic.sh 英訳したい日本語
#  * 標準入力からでも OK

readonly ACCESS_TOKEN=$(head -1 './access_token')
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
SUCCESSFUL=$(echo $RESPONSE | perl -ne 'print $1 if /"successful":(\w+),/')
TRANSLATED_TEXT=$(echo $RESPONSE | perl -ne 'print "$1 " while /"translated_text":"(\w+)"/g')

# 失敗したぽいならレスポンスを全文出力して逃げる
[[ $SUCCESSFUL != 'true' ]] && echo "error. response= $RESPONSE" 1>&2 && exit 1

# 出力
echo $TRANSLATED_TEXT
exit 0
