set -e

function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=3
  local delay=1
  local start_time=$(date +%s)
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        local current_time=$(date +%s)
        local elapsed_time=current_time-start_time
        if [[ $elapsed_time > 60 ]]; then
            echo "Command failed. Too late to retry.:"
            exit 1
        fi
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && /balena-cli/balena login --token ${API_TOKEN}

if [[ -f /tmp/deploy ]]; then
  rm /tmp/deploy
fi

set -o pipefail
retry /balena-cli/balena push ${APPLICATION_NAME} | tee /tmp/deploy
set +o pipefail

release_commit=$(grep Release: /tmp/deploy | tail -n1 | awk '{print $3}')
release_id=$(grep Release: /tmp/deploy | tail -n1 | awk '{print $5}')
echo "Found $release_commit ($release_id)"
echo ::set-output name=release_commit::$(echo "${release_commit}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
echo ::set-output name=release_id::$(echo "${release_id}" | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's/[^0-9]//g')