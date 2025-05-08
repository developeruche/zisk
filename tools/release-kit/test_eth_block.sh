#!/bin/bash

source "./utils.sh"
source "$HOME/.bashrc"

main() {
    current_step=1
    total_steps=8

    is_proving_key_installed || return 1

    step "Loading environment variables..."
    load_env || return 1
    confirm_continue || return 1

    mkdir -p "${HOME}/work"
    cd "${HOME}/work"

    ELF_FILE="zisk-eth-client-keccakf-ecrecover.elf"
    MPI_CMD="mpirun --bind-to none -np $DISTRIBUTED_PROCESSES -x OMP_NUM_THREADS=$DISTRIBUTED_THREADS"

    PROVE_FLAGS="-a -y"
    if [[ "$DISABLE_ASSEMBLY" == "1" ]]; then
        PROVE_FLAGS="$PROVE_FLAGS -l"
        warn "Emulator assembly disabled: using -l flag in cargo-zisk prove"
    fi

    step "Deleting shared memory..."
    rm -rf /dev/shm/ZISK*

    step "Cloning zisk-testvectors repository..."
    rm -rf zisk-testvectors
    ensure git clone https://github.com/0xPolygonHermez/zisk-testvectors.git || return 1
    cd zisk-testvectors

    step "Generating eth-client program setup..."
    ensure cargo-zisk rom-setup -e "eth-client/program/elf/${ELF_FILE}" 2>&1 | tee romsetup_output.log || return 1
    if ! grep -F "ROM setup successfully completed" romsetup_output.log; then
        err "program setup failed"
        return 1
    fi

    step "Verifying constraints for 20852412_38_3.bin..."
    ensure cargo-zisk verify-constraints -e "eth-client/program/elf/${ELF_FILE}" -i "eth-client/inputs/20852412_38_3.bin" 2>&1 | tee constraints_output.log || return 1
    if ! grep -F "All global constraints were successfully verified" constraints_output.log; then
        err "verify constraints failed"
        return 1
    fi

    step "Generating proof for block 20852412_38_3.bin (distributed)..."  
    ensure $MPI_CMD cargo-zisk prove -e "eth-client/program/elf/${ELF_FILE}" -i "eth-client/inputs/20852412_38_3.bin" -o proof $PROVE_FLAGS 2>&1 | tee prove_output.log || return 1
    if ! grep -F "Vadcop Final proof was verified" prove_output.log; then
        err "prove program failed"
        return 1
    fi

    step "Verifying proof for block 20852412_38_3.bin..."
    ensure cargo-zisk verify -p ./proof/proofs/vadcop_final_proof.json -u ./proof/publics.json 2>&1 | tee verify_output.log || return 1
    if ! grep -F "Stark proof was verified" verify_output.log; then
        err "verify proof failed"
        return 1
    fi

    step "Generating proof for block 21077746_52_27.bin (distributed)..."  
    ensure $MPI_CMD cargo-zisk prove -e "eth-client/program/elf/${ELF_FILE}" -i "eth-client/inputs/21077746_52_27.bin" -o proof $PROVE_FLAGS 2>&1 | tee prove_output.log || return 1
    if ! grep -F "Vadcop Final proof was verified" prove_output.log; then
        err "prove program failed"
        return 1
    fi

    cd ..

    success "Ethereum blocks has been successfully proved!"
}

main || return 1
