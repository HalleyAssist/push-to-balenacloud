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

retry /balena-cli/balena push ${APPLICATION_NAME} | tee /tmp/deploy

release=$(grep Release: /tmp/deploy | awk '{print $3}')
echo "Found $release"
echo ::set-output name=release::$(echo "${release}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
