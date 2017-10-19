#!/usr/bin/env bash

set -e

github_post() {
  local resource="$1"
  local body="$2"
  curl -s \
    -XPOST \
    -H "content-type:application/json" \
    -H "Authorization: token ${MY_GITHUB_TOKEN}" \
    -d "${body}" \
    "https://api.github.com/repos/btisdall/playground/${resource}"
}

TAG_NAME="some-tag-$(gdate +%s)"

TAG_DATA="$(echo "{}" | jq -c \
  --arg type "commit" \
  --arg message "Hello from me" \
  --arg tag "${TAG_NAME}" \
  --arg object "$(git rev-parse HEAD)" \
  --arg name "bentis" \
  --arg email "ben@tisdall.eu" \
  --arg date "$(gdate -u +%FT%TZ)" \
  '.type=$type|.tag=$tag|.message=$message|.object=$object|.tagger.name=$name|.tagger.email=$email|.tagger.date=$date' \
)"

echo "TAG:"
echo "${TAG_DATA}"|jq

TAG_SHA="$(github_post git/tags "${TAG_DATA}" | jq -r '.sha')"

REF_DATA="$( echo "{}" |jq -c \
  --arg sha "${TAG_SHA}" \
  --arg ref "refs/tags/${TAG_NAME}" \
  '.sha=$sha|.ref=$ref' \
)"

echo "REF:"
echo "${REF_DATA}"|jq

github_post "git/refs" "${REF_DATA}"
