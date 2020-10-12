#!/bin/sh -l

function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=3
  local delay=1
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && /balena-cli/balena login --token ${API_TOKEN} && retry /balena-cli/balena push ${APPLICATION_NAME}
