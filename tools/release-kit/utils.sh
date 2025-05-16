#!/bin/bash

# Colors
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Helper to ensure a command runs successfully
# If it fails, it prints an error message and waits for user input
ensure() {
    if ! "$@"; then
        echo "${RED}❌ Error: command failed -> $*${RESET}" >&2
        read -p "Press any key to continue..." -n1 -s
        echo
        return 1
    fi
}

step() {
    echo "${BOLD}${GREEN}[${current_step}/${total_steps}] $1${RESET}"

    current_step=$(( ${current_step} + 1 ))
}

info() {
    echo $1
}

warn() {
    echo "${BOLD}${GREEN}🚨  $1${RESET}"
}

err() {
    echo "${RED}❌ Error: $1${RESET}" >&2
    read -p "Press any key to continue..." -n1 -s
    echo
    return 1
}

success() {
    echo "${BOLD}${GREEN}✅ $1${RESET}"
}

# load_env: Load environment variables from .env file
load_env() {
    if [[ ! -f ".env" ]]; then
        err "❌ No .env file found. Please create one with the required environment variables."
        return 1
    fi

    # Load environment variables from .env file ignoring comments and empty lines
    ENV_VARS=$(grep -vE '^\s*#' .env | grep -vE '^\s*$')

    if [[ -z "${ENV_VARS}" ]]; then
        err "❌ .env file is empty or contains only comments. Please define the required environment variables."
        return 1
    fi

    info "📦 Loading environment variables from .env"
    export ${ENV_VARS}

    echo
    info "🔍 Loaded environment variables:"
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        echo "  - ${key} = ${!key}"
    done < <(echo "${ENV_VARS}")
    echo
}

# confirm_continue: Ask the user for confirmation to continue
confirm_continue() {
    read -p "Do you want to continue? [Y/n] " answer
    answer=${answer:-y}

    if [[ "$answer" != [Yy]* ]]; then
        echo "Aborted."
        return 1
    fi
}

# press_any_key: Wait for user to press any key
press_any_key() {
    read -p "Press any key to continue..." -n1 -s
    echo
}

# is_proving_key_installed: Check if the proving key is installed
is_proving_key_installed() {
    if [[ -d "$HOME/.zisk/provingKey" ]]; then
        return 0
    else
        err "Proving key not installed. Please install it first."
        return 1    
    fi
}

# get_var_list: Returns the list of items (separated by commas) in the variable
#
# Parameters:
#   $1 (var_name) — Name of the environment variable containing comma-separated values
get_var_list() {
    local var_name="$1"
    local raw="${!var_name}"
    local item

    # si no está definida o vacía, devolvemos nada
    [[ -z "${raw//[[:space:]]/}" ]] && return 0

    # separa por coma, recorta espacios y emite cada línea
    IFS=',' read -ra parts <<< "$raw"
    for item in "${parts[@]}"; do
        # eliminar espacios alrededor
        item="${item#"${item%%[![:space:]]*}"}"
        item="${item%"${item##*[![:space:]]}"}"
        printf '%s\n' "$item"
    done
}

# verify_files_exist: Ensure that all specified files exist under a given base path
#
# Arguments:
#   $1 (base_path) — Directory path where input files are located
#   $2…$n (files) — Filenames (relative to base_path) to check for existence
#
# Example:
#   verify_files_exist "/home/user/inputs" file1.bin file2.bin file3.bin
verify_files_exist() {
    local base_path="$1"
    shift
    local files=("$@")

    for f in "${files[@]}"; do
        if [[ ! -f "${base_path}/${f}" ]]; then
            err "File not found: ${base_path}/${f}"
            return 1
        fi
    done
    return 0
}
