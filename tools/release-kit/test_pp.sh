#!/bin/bash

source "./test_elf.sh"

main() {
    ELF_FILE="pessimistic-proof/program/pessimistic-proof-program-keccakf-v0.7.0.elf"
    INPUTS_PATH="pessimistic-proof/inputs/bench"
    test_elf "${ELF_FILE}" "${INPUTS_PATH}" "PP_INPUTS" "PP_INPUTS_DISTRIBUTED" "Pessimistic proof" || return 1
}

main || return 1
