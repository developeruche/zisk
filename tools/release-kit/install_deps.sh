#!/bin/bash

source ./utils.sh

main() {
    current_step=1
    total_steps=4

    step "Installing package dependencies..."

    sudo apt-get update > /dev/null
    sudo apt-get install -y apt-utils dialog libterm-readline-perl-perl > /dev/null

    ensure sudo apt-get install -y \
        curl git xz-utils jq build-essential qemu-system libomp-dev libgmp-dev \
        nlohmann-json3-dev protobuf-compiler uuid-dev libgrpc++-dev libsecp256k1-dev \
        libsodium-dev libpqxx-dev nasm libopenmpi-dev openmpi-bin openmpi-common \
        sudo ca-certificates gnupg lsb-release wget libclang-dev clang > /dev/null

    step "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null
    ensure sudo apt-get install -y nodejs > /dev/null

    step "Installing Rust..."
    ensure curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="${HOME}/.cargo/bin:$PATH"
    source "${HOME}/.cargo/env"

    step "Installing nano editor..."
    ensure sudo apt-get install -y nano > /dev/null  

    echo
}

main || return 1