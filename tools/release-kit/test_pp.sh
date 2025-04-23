#!/bin/bash
set -e

source "./utils.sh"
source "$HOME/.bashrc"

load_env
info "Press any key to continue..."
read -n 1 -s

ELF_FILE="pessimistic-proof-program-keccakf-v0.7.0.elf"
MPI_CMD="mpirun --bind-to none -np $DISTRIBUTED_PROCESSES -x OMP_NUM_THREADS=$DISTRIBUTED_THREADS"

current_step=1
total_steps=6

step "Deleting shared memory..."
rm -rf /dev/shm/SHM*

step  "Cloning zisk-testvectors repository..."
rm -rf zisk-testvectors
ensure git clone https://github.com/0xPolygonHermez/zisk-testvectors.git
cd zisk-testvectors

step "Generating pessimistic program setup..."
ensure cargo-zisk rom-setup -e "pessimistic-proof/program/${ELF_FILE}" 2>&1 | tee romsetup_output.log
if ! grep -F "ROM setup successfully completed" romsetup_output.log; then
    err "program setup failed"
    exit 1
fi
  
step "Generating pessimistic proof (no distributed)..."  
ensure cargo-zisk prove -e "pessimistic-proof/program/${ELF_FILE}" -i "pessimistic-proof/inputs/bench/pp_input_1_1.bin" -o proof -a -y 2>&1 | tee prove_output.log
if ! grep -F "Vadcop Final proof was verified" prove_output.log; then
    err "prove program failed"
    exit 1
fi

step "Verifying pressimistic proof..."
ensure cargo-zisk verify -p ./proof/proofs/vadcop_final_proof.json -u ./proof/publics.json 2>&1 | tee verify_output.log
if ! grep -F "Stark proof was verified" verify_output.log; then
    err "verify proof failed"
    exit 1
fi

step "Generating pessimistic proof (distributed)..."  
ensure $MPI_CMD cargo-zisk prove -e "pessimistic-proof/program/${ELF_FILE}" -i "pessimistic-proof/inputs/bench/pp_input_20_20.bin" -o proof -a -y 2>&1 | tee prove_output.log
if ! grep -F "Vadcop Final proof was verified" prove_output.log; then
    err "prove program failed"
    exit 1
fi

success "Pessimistic proof has been successfully proved!"