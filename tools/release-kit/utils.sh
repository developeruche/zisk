#!/bin/bash

# Colors
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Helper to run and log
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

confirm_continue() {
    read -p "Do you want to continue? [Y/n] " answer
    answer=${answer:-y}

    if [[ "$answer" != [Yy]* ]]; then
        echo "Aborted."
        return 1
    fi
}

press_any_key() {
    read -p "Press any key to continue..." -n1 -s
    echo
}

is_proving_key_installed() {
    if [[ -d "$HOME/.zisk/provingKey" ]]; then
        return 0
    else
        err "Proving key not installed. Please install it first."
        return 1    
    fi
}