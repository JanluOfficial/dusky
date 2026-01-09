#!/usr/bin/env bash
# This script installs scrcpy, as well as the relevant launch script and .desktop files for it.
# ---------------------------------------------------------------------------------
# ANDROID SCREEN MIRRORING SETUP
# created by Janlu (https://github.com/JanluOfficial)
# ---------------------------------------------------------------------------------

# --- 1. PACKAGE INSTALLATION ---

# 1. Check for Root Privileges and elevate them if necessary
if [[ $EUID -ne 0 ]]; then
  printf "Elevating privileges...\n"
  exec sudo "$0" "$@"
fi

# 2. Aesthetics

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# 3. scrcpy installation function
install_scrcpy() {
  printf "\n${BOLD}${CYAN}:: Installing scrcpy${RESET}\n"
  if pacman -S --needed --noconfirm "scrcpy"; then
    printf "${GREEN} [OK] Installation successful.${RESET}\n"
    return 0
  fi
  printf "${RED} [ERR] Error installing scrcpy.${RESET}\n"
  return 1
}

# 4. Actually installing scrcpy
scrcpy_success = install_scrcpy
if [ $scrcpy_success -eq 1 ]; then
  exit 1
fi

# --- 2. Ask user if Second Screen shortcuts should be installed ---


