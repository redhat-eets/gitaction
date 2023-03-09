#!/bin/bash

LABEL_OPT=""
if [[ -n "${RUNNER_LABEL}" ]]; then
    LABEL_OPT="--labels ${RUNNER_LABEL}"
fi

RUNNER_LABEL=${RUNNER_LABEL}
GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY

GH_TOKEN=$(tr -d "[:space:]" < ${GH_TOKEN_PATH})
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="containerNode-${RUNNER_SUFFIX}"

reg_token () {
    local TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
    echo -n ${TOKEN}
}

REG_TOKEN=$(reg_token)

cd /home/docker/actions-runner

./config.sh --unattended --url https://github.com/${GH_OWNER}/${GH_REPOSITORY} --token ${REG_TOKEN} --name ${RUNNER_NAME} ${LABEL_OPT}

cleanup() {
    echo "Removing runner..."
    REG_TOKEN=$(reg_token)
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
