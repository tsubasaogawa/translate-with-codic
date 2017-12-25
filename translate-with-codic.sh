#!/bin/bash
# usage: translate_with_codic.bash 英訳したい日本語

readonly ACCESS_TOKEN=$(head -1 'access_token')
TEXT=$1
[[ -z $TEXT ]] && read TEXT && [[ -z $TEXT ]] && exit 1

RESPONSE=$(curl --silent \
     -H 'Host: api.codic.jp' \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://api.codic.jp/v1/engine/translate.json?text=$TEXT")
RETURN_CODE=$?
[[ $RETURN_CODE -ne 0 ]] && exit $RETURN_CODE

# API の成功可否と翻訳結果だけ得られればよい
SUCCESSFUL=$(echo $RESPONSE | perl -ne 'print $1 if /"successful":(\w+),/')
TRANSLATED_TEXT=$(echo $RESPONSE | perl -ne 'print $1 if /"translated_text":"(\w+)"/')

[[ $SUCCESSFUL != 'true' ]] && echo "error. SUCCESSFUL=$SUCCESSFUL" && exit 1
echo $TRANSLATED_TEXT
exit 0
