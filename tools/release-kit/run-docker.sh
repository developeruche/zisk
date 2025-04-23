#!/bin/bash
set -e

source ./utils.sh

IMAGE_NAME="zisk-container"
CONTAINER_NAME="zisk-docker"
OUTPUT_DIR="./output"

mkdir -p "${OUTPUT_DIR}"

info "🔨 Building docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" .

# Delete any existing container with the same name
docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

info "🚀 Running docker container..."

docker run -dit --name "${CONTAINER_NAME}" -v "$(realpath "${OUTPUT_DIR}"):/output" "${IMAGE_NAME}" bash

info "📜 Container '${CONTAINER_NAME}' is now running."

info "📦 Installing ZisK dependencies..."
docker exec -it "${CONTAINER_NAME}" bash -i -c "./install_deps.sh"

echo
info "🛑 ${BOLD}To stop the container, run:${RESET} docker stop ${CONTAINER_NAME}"
info "❌ ${BOLD}To remove the container, run:${RESET} docker rm -f ${CONTAINER_NAME}"
echo 
info "🔑 Accessing the container now..."
docker exec -it ${CONTAINER_NAME} bash -i -c "./menu.sh; exec bash"
