# Buildah container: https://quay.io/repository/containers/buildah
# Git actions runner start script: https://github.com/redhat-eets/gitaction

FROM quay.io/buildah/stable:latest

# Env vars
ARG RUNNER_VERSION="2.309.0"
ARG GH_OWNER=${GH_OWNER}
ARG GH_REPOSITORY=${GH_REPOSITORY}
ARG GH_TOKEN=${GH_TOKEN}

# Install prerequisites
RUN dnf install wget dotnet-sdk-6.0 jq gcc make python3 docker podman -y

# Switch to build user
USER build
WORKDIR /home/build

# Download and unpack the Github Runner
#RUN mkdir actions-runner && cd actions-runner
RUN wget -nv https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
RUN tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Add start script
ADD scripts/start.sh start.sh

# Set entry point to our start script
ENTRYPOINT ["./start.sh"]
