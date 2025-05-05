#!/bin/bash

source ./utils.sh

WORK_DIR=$(pwd)

# Loop until user chooses to exit
while true; do
  echo "==============================="
  echo "     ZisK Release Kit Menu     "
  echo "==============================="
  echo " 1) Edit environment variables"
  echo " 2) Build Zisk from source"
  echo " 3) Build setup from source"
  echo " 4) Build setup artifacts"
  echo " 5) Test sha_hasher"
  echo " 6) Test pessimistic proof"
  echo " 7) Test Ethereum block"
  echo " 8) Install setup from public artifacts"
  echo " 9) Install setup from local artifacts"
  echo "10) Shell"
  echo "11) Exit"
  echo

  # Prompt for input
  read -p "Select an option [1-11]: " option
  echo

  case $option in
    1)
      info "Opening .env file with nano..."
      nano .env
      ;;
    2)
      info "Running build_zisk.sh..."
      source ./build_zisk.sh || :
      ;;
    3)
      info "Running build_setup.sh..."
      source ./build_setup.sh || :
      ;;
    4)
      info "Running release_setup.sh..."
      ./release_setup.sh || :
      ;;
    5)
      info "Running test_sha_hasher.sh..."
      source ./test_sha_hasher.sh || :
      ;;
    6)
      info "Running test_pp.sh"
      source ./test_pp.sh || :
      ;;  
    7)
      info "Running test_eth_block.sh"
      source ./test_eth_block.sh || :
      ;;        
    8)
      info "Running install_setup_public.sh..."
      source ./install_setup_public.sh || :
      ;;
    9)
      info "Running install_setup_local.sh..."
      source ./install_setup_local.sh || :
      ;;  
    10)
      info "Open shell"
      bash
      ;;   
    11)
      info "Exiting ZisK Release Kit. Goodbye!"
      exit
      ;;
    *)
      info "Invalid selection. Please enter a number between 1 and 11."
      ;;
  esac

  echo

  cd "$WORK_DIR" || {
    err "Failed to change directory to $WORK_DIR"
    exit 1
  }
done
