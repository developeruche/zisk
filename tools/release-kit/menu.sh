#!/bin/bash

source ./utils.sh

# Loop until user chooses to exit
while true; do
  echo "==============================="
  echo "     ZisK Release Kit Menu     "
  echo "==============================="
  echo "1) Edit environment variables"
  echo "2) Build Zisk from source"
  echo "3) Build Setup from source"
  echo "4) Install Setup from binaries"
  echo "5) Test sha_hasher"
  echo "6) Test pessimistic proof"
  echo "7) Test Ethereum block"
  echo "8) Release Setup"
  echo "0) Exit"
  echo

  # Prompt for input
  read -p "Select an option [0-5]: " option
  echo

  case $option in
    1)
      info "Opening .env file with nano..."
      nano .env
      ;;
    2)
      info "Running build_zisk.sh..."
      source ./build_zisk.sh
      ;;
    3)
      info "Running build_setup.sh..."
      source ./build_setup.sh
      ;;
    4)
      info "Running download_setup.sh..."
      source ./download_setup.sh
      ;;
    5)
      info "Running test_sha_hasher.sh..."
      source ./test_sha_hasher.sh
      ;;
    6)
      info "Running test_pp.sh"
      source ./test_pp.sh
      ;;  
    7)
      inf "Running test_eth_block.sh"
      source ./test_eth_block.sh
      ;;        
    8)
      read -p "Enter version to use for release setup (e.g. 0.7.0): " release_version
      echo
      info "Running release_setup.sh with version '$release_version'..."
      ./release_setup.sh "$release_version"
      ;;
    0)
      info "Exiting ZisK Release Kit. Goodbye!"
      break
      ;;
    *)
      info "Invalid selection. Please enter a number between 0 and 5."
      ;;
  esac

  echo
done
