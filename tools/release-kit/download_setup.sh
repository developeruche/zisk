#!/bin/bash

source ./utils.sh
source "$HOME/.bashrc"

current_step=1
total_steps=4

step "Loading environment variables..."
load_env
confirm_continue

step  "Downloading proving key version ${SETUP_VERSION}..."
ensure curl -L -#o "zisk-provingkey-${SETUP_VERSION}.tar.gz" "https://storage.googleapis.com/zisk/zisk-provingkey-${SETUP_VERSION}.tar.gz"

step "Installing proving key version ${SETUP_VERSION}..."
rm -rf "$HOME/.zisk/provingKey/"
ensure tar --overwrite -xf "zisk-provingkey-${SETUP_VERSION}.tar.gz" -C "$HOME/.zisk"

step "Generating constant tree files..."
ensure cargo-zisk check-setup -a

step "Deleting downloaded proving key..."
rm -rf "zisk-provingkey-${SETUP_VERSION}.tar.gz"