#!/bin/bash

source "./utils.sh"
source "$HOME/.bashrc"

PROJECT_NAME="sha_hasher"
EXPECTED_OUTPUT="98211882|bd13089b|6ccf1fca|81f7f0e4|abf6352a|0c39c9b1|1f142cac|233f1280"

main() {
    current_step=1
    total_steps=9

    step "Deleting shared memory..."
    rm -rf /dev/shm/SHM*

    step "Creating new ZisK program: $PROJECT_NAME"
    # Remove existing directory if it exists
    rm -rf "$PROJECT_NAME"
    # Create ZisK program
    ensure cargo-zisk sdk new "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    step "Building program..."
    ensure cargo-zisk build --release

    ELF_PATH="target/riscv64ima-polygon-ziskos-elf/release/$PROJECT_NAME"
    INPUT_BIN="build/input.bin"

    step "Running program with ziskemu.."
    ensure ziskemu -e "$ELF_PATH" -i "$INPUT_BIN" | tee ziskemu_output.log
    if ! grep -qE ${EXPECTED_OUTPUT} ziskemu_output.log; then
        err "run ziskemu failed"
        return 1
    fi

    step "Runing program with cargo-zisk run..."
    ensure cargo-zisk run --release -i build/input.bin | tee run_output.log
    if ! grep -qE ${EXPECTED_OUTPUT} run_output.log; then
        err "run program failed"
        return 1
    fi

    step "Generating program setup..."
    ensure cargo-zisk rom-setup -e target/riscv64ima-polygon-ziskos-elf/release/sha_hasher 2>&1 | tee romsetup_output.log
    if ! grep -F "ROM setup successfully completed" romsetup_output.log; then
        err "program setup failed"
        return 1
    fi

    step "Verifying constraints..."
    ensure cargo-zisk verify-constraints -e target/riscv64ima-polygon-ziskos-elf/release/sha_hasher -i build/input.bin 2>&1 | tee constraints_output.log
    if ! grep -F "All global constraints were successfully verified" constraints_output.log; then
        err "verify constraints failed"
        return 1
    fi

    step "Generating proof..."  
    ensure cargo-zisk prove -e target/riscv64ima-polygon-ziskos-elf/release/sha_hasher -i build/input.bin -o proof -a -y 2>&1 | tee prove_output.log
    if ! grep -F "Vadcop Final proof was verified" prove_output.log; then
        err "prove program failed"
        return 1
    fi

    step "Verifying proof..."
    ensure cargo-zisk verify -p ./proof/proofs/vadcop_final_proof.json -u ./proof/publics.json 2>&1 | tee verify_output.log
    if ! grep -F "Stark proof was verified" verify_output.log; then
        err "verify proof failed"
        return 1
    fi          

    success "Program $PROJECT_NAME has been successfully proved!"
}

main || return 1