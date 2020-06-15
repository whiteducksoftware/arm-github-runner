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
WORKDIR=/var/run/github/actions
OS=linux
ARCH=x64

# Prepare working directory
mkdir -p ${WORKDIR} && cd ${WORKDIR}

# Debug info
echo "========="
echo -e "Installing runner ${GREEN}${OS}-${ARCH}-${RUNNER_VERSION}${NC} in ${GREEN}${WORKDIR}${NC}"
echo "========="

# Download github actions runtime
curl -v -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-${OS}-${ARCH}-${RUNNER_VERSION}.tar.gz

# Fix permissions for config.sh
echo "========="
echo "Adding +x flags to config.sh"
echo "========="
chmod +x config.sh

# Configure runner
echo "========="
echo -e "Configuring runner for ${GREEN}${RUNNER_URL}${NC}"
echo "========="
./config.sh --unattended --url ${RUNNER_URL} --token ${RUNNER_TOKEN}

# Fix permissions for svc.sh
echo "========="
echo "Adding +x flags to config.sh"
echo "========="
chmod +x svc.sh

# Install the service
echo "========="
echo "Configuring runner to run as a service"
echo "========="
./svc.sh install
./svc.sh start