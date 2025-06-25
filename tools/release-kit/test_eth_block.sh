#!/bin/bash

source "./test_elf.sh"

main() {
    ELF_FILE="eth-client/elf/zec-keccakf-k256.elf"
    INPUTS_PATH="eth-client/inputs"
    test_elf "${ELF_FILE}" "${INPUTS_PATH}" "BLOCK_INPUTS" "BLOCK_INPUTS_DISTRIBUTED" "Ethereum blocks" || return 1
}

main || return 1
