#!/bin/bash

source ./utils.sh

$OUTPUT_DIR="./output"

current_step=1
total_steps=5

step "Loading environment variables..."
load_env
confirm_continue

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

step "Move files to output folder..."
ensure sudo mv "./zisk/build/zisk-provingkey-${SETUP_VERSION}.tar.gz" "${OUTPUT_DIR}"
ensure sudo mv "./zisk/build/zisk-verifykey-${SETUP_VERSION}.tar.gz" "${OUTPUT_DIR}"
ensure sudo mv "./zisk/build/zisk-provingkey-${SETUP_VERSION}.tar.gz.md5" "${OUTPUT_DIR}"
ensure sudo mv "./zisk/build/zisk-verifykey-${SETUP_VERSION}.tar.gz.md5" "${OUTPUT_DIR}"

