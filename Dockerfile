# base image
FROM ubuntu:20.04

#input GitHub runner version argument
ARG RUNNER_VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV GH_TOKEN_PATH=/run/secrets/github_token

LABEL GitHub="https://github.com/redhat-eets/gitaction.git"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages, add a non-sudo user, install the packages, dependencies
RUN apt-get update -y && useradd -m docker \
    && apt-get install -y --no-install-recommends \
    curl git jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
