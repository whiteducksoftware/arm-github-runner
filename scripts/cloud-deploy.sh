#!/bin/bash
set -e

# Colors
GREEN='\033[1;32m'
NC='\033[0m' # No Color

# Variable args
while getopts "v:u:t:" opt; do
    case $opt in
        v)
            RUNNER_VERSION=$OPTARG
        ;;
        u)
            RUNNER_URL=$OPTARG
        ;;
        t)
            RUNNER_TOKEN=$OPTARG
        ;;
    esac
done

# Fixed args
WORKDIR=/github/actions
OS=linux
ARCH=x64

# Prepare working directory
mkdir -p ${WORKDIR} && cd ${WORKDIR}

# Debug info
echo "========="
echo -e "Installing runner ${GREEN}${OS}-${ARCH}-${RUNNER_VERSION}${NC} in ${GREEN}${WORKDIR}${NC}"
echo "========="

# Download github actions runtime
curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz

# Fix ownership
echo "========="
echo "Fixing file ownerships"
echo "========="
chown $(whoami):$(id -g) -R .

# Configure runner
echo "========="
echo -e "Configuring runner for ${GREEN}${RUNNER_URL}${NC}"
echo "========="
./config.sh --unattended --url ${RUNNER_URL} --token ${RUNNER_TOKEN}

# Install the service
echo "========="
echo "Configuring runner to run as a service"
echo "========="
sudo ./svc.sh install
sudo ./svc.sh start