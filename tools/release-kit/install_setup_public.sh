#!/bin/bash

source ./utils.sh
source "$HOME/.bashrc"

main () {
    current_step=1
    total_steps=5

    step "Loading environment variables..."
    load_env
    confirm_continue

    step  "Downloading public proving key version ${SETUP_VERSION}..."
    ensure curl -L -#o "zisk-provingkey-${SETUP_VERSION}.tar.gz" "https://storage.googleapis.com/zisk/zisk-provingkey-${SETUP_VERSION}.tar.gz"

    step "Installing public proving key version ${SETUP_VERSION}..."
    rm -rf "$HOME/.zisk/provingKey/"
    ensure tar --overwrite -xf "zisk-provingkey-${SETUP_VERSION}.tar.gz" -C "$HOME/.zisk"

    step "Generating constant tree files..."
    ensure cargo-zisk check-setup -a

    step "Deleting downloaded public proving key..."
    rm -rf "zisk-provingkey-${SETUP_VERSION}.tar.gz"
}

main || return 1