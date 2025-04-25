#!/bin/bash
set -e

source ./utils.sh

IMAGE_NAME="zisk-image"
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
info "🔑 Accessing the container now..."
docker exec -it ${CONTAINER_NAME} bash -i -c "sudo chmod 777 /output; ./menu.sh"

echo
info "${BOLD}To access the container, run:${RESET}\n   docker exec -it ${CONTAINER_NAME}  bash -i -c "./menu.sh""
info "${BOLD}To stop the container, run:${RESET}\n   docker stop ${CONTAINER_NAME}"
info "${BOLD}To remove the container, run:${RESET}\n   docker rm -f ${CONTAINER_NAME}"
