#!/bin/bash

source ./utils.sh

current_step=1
total_steps=3

# Check if version argument is provided
if [[ -z "$1" ]]; then
  err "version not defined. Please provide a version number."
  exit 1
fi

SETUP_VERSION=$1

step "Compress proving key..."
cd zisk/build
ensure tar -czvf "zisk-provingkey-${SETUP_VERSION}.tar.gz" provingKey/

step "Compress verify key..."
ensure tar -czvf "zisk-verifykey-${SETUP_VERSION}.tar.gz" \
  provingKey/zisk/vadcop_final/vadcop_final.starkinfo.json \
  provingKey/zisk/vadcop_final/vadcop_final.verkey.json \
  provingKey/zisk/vadcop_final/vadcop_final.verifier.bin

step "Generate checksums..."
ensure md5sum "zisk-provingkey-${SETUP_VERSION}.tar.gz" > "zisk-provingkey-${SETUP_VERSION}.tar.gz.md5"
ensure md5sum "zisk-verifykey-${SETUP_VERSION}.tar.gz" > "zisk-verifykey-${SETUP_VERSION}.tar.gz.md5"

cd ../..
