#!/bin/bash

source ./utils.sh

current_step=1
total_steps=3

step "Loading environment variables..."
load_env
info "Press any key to continue..."
read -n 1 -s

step  "Downloading proving key version ${SETUP_VERSION}..."
ensure curl -L -#o "zisk-provingkey-${SETUP_VERSION}.tar.gz" "https://storage.googleapis.com/zisk/zisk-provingkey-${SETUP_VERSION}.tar.gz"

step "Installing proving key version ${SETUP_VERSION}..."
rm -rf "$HOME/.zisk/provingKey/"
ensure tar --overwrite -xf "zisk-provingkey-${SETUP_VERSION}.tar.gz" -C "$HOME/.zisk"

step "Generating constant tree files..."
ensure cargo-zisk check-setup -a