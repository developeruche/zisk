#!/bin/bash

source ./utils.sh

main() {
  current_step=1
  total_steps=10

  step "Loading environment variables..."
  load_env
  confirm_continue

  step "Cloning pil2-proofman repository..."
  # Remove existing directory if it exists
  rm -rf pil2-proofman
  # Clone pil2-proofman repository
  ensure git clone https://github.com/0xPolygonHermez/pil2-proofman.git
  cd pil2-proofman
  # If PIL2_PROOFMAN_BRANCH is defined, check out the specified branch
  if [[ -n "$PIL2_PROOFMAN_BRANCH" ]]; then
    echo "Checking out branch '$PIL2_PROOFMAN_BRANCH' for pil2-proofman..."
    ensure git checkout "$PIL2_PROOFMAN_BRANCH"
  fi
  cd ..

  step  "Cloning ZisK repository..."
  # Remove existing directory if it exists
  rm -rf zisk
  # Clone ZisK repository
  ensure git clone https://github.com/0xPolygonHermez/zisk.git
  cd zisk
  # If the ZISK_BRANCH environment variable is defined and not empty, check out that branch
  if [[ -n "$ZISK_BRANCH" ]]; then
    info "Checking out branch '$ZISK_BRANCH'..."
    ensure git checkout "$ZISK_BRANCH"
  fi

  step "Update ZisK cargo dependencies to use local pil2-proofman repo..."
  # Dependencies to be replaced
  declare -A replacements=(
    ["proofman"]='{ path = "../pil2-proofman/proofman" }'
    ["proofman-common"]='{ path = "../pil2-proofman/common" }'
    ["proofman-macros"]='{ path = "../pil2-proofman/macros" }'
    ["proofman-util"]='{ path = "../pil2-proofman/util" }'
    ["pil-std-lib"]='{ path = "../pil2-proofman/pil2-components/lib/std/rs" }'
    ["witness"]='{ path = "../pil2-proofman/witness" }'
  )
  # Iterate over the replacemnts and update the Cargo.toml file
  for crate in "${!replacements[@]}"; do
    sed -i -E "s|^$crate = \{ git = \"https://github.com/0xPolygonHermez/pil2-proofman.git\", tag = \".*\" *\}|$crate = ${replacements[$crate]}|" Cargo.toml
  done

  step  "Building ZisK tools..."
  ensure cargo clean
  ensure cargo update
  if ! (cargo build --release); then
      warn "Build failed. Trying to fix missing stddef.h..."

      stddef_path=$(find /usr -name "stddef.h" 2>/dev/null | head -n 1)
      if [ -z "$stddef_path" ]; then
          err "stddef.h not found. You may need to install gcc headers."
          exit 1
      fi

      include_dir=$(dirname "$stddef_path")
      export C_INCLUDE_PATH=$include_dir
      export CPLUS_INCLUDE_PATH=$C_INCLUDE_PATH

      info  "Retrying build..."
      ensure cargo build --release
  fi

  step "Copying binaries to ${HOME}/.zisk/bin..."
  mkdir -p "$HOME/.zisk/bin"
  ensure cp target/release/cargo-zisk target/release/ziskemu target/release/riscv2zisk \
      target/release/libzisk_witness.so precompiles/keccakf/src/keccakf_script.json "$HOME/.zisk/bin"

  step "Copying emulator-asm files..."
  mkdir -p "$HOME/.zisk/zisk/emulator-asm"
  ensure cp -r ./emulator-asm/src "$HOME/.zisk/zisk/emulator-asm"
  ensure cp ./emulator-asm/Makefile "$HOME/.zisk/zisk/emulator-asm"
  ensure cp -r ./lib-c $HOME/.zisk/zisk
  a
  step "Adding ~/.zisk/bin to PATH..."
  echo 'export PATH="$PATH:$HOME/.zisk/bin"' >> "$HOME/.bashrc"
  export PATH="$PATH:$HOME/.zisk/bin"
  source "$HOME/.bashrc"

  step "Installing ZisK Rust toolchain..."
  ensure cargo-zisk sdk install-toolchain

  step "Verifying toolchain installation..."
  rustup toolchain list | grep zisk || {
      err "ZisK toolchain not found."
      exit 1
  }

  cd ..
}

main || return 1