#!/bin/bash

#############################################
# Global directory layout
#############################################

BASE_DIR="/root/NextCloud"
LOG_DIR="/root/log"
BIN_DIR="/root/.bin"
ETC_DIR="/root/etc"

LOG_DATE=$(date +"%Y%m%d%H%M%S")
LOG_FILE="${LOG_DIR}/NextCloud33_install_${LOG_DATE}.log"

mkdir -p "$LOG_DIR"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

exec > >(tee -a "$LOG_FILE") 2>&1

#############################################
# Configuration
#############################################

PHP_VERSION="8.3"
MARIADB_VERSION="10.11"

PHP_PACKAGES_FILE="${ETC_DIR}/php-packages.txt"
MARIADB_PACKAGES_FILE="${ETC_DIR}/mariadb-packages.txt"

#############################################
# Step tracking / logging helpers
#############################################

STEP=0

log_step() {
    STEP=$((STEP + 1))
    echo
    echo "=============================================="
    echo "STEP ${STEP}: $1"
    echo "=============================================="
    echo
}

log_info() {
    echo "[INFO] $1"
}

print_header() {
    echo
    echo "--------------------------------------"
    echo "$1"
    echo "--------------------------------------"
    echo
}

#############################################
# Load external function modules
#############################################

SCRIPT_DIR="$BIN_DIR"

source "$SCRIPT_DIR/php_functions.sh"
# source "$SCRIPT_DIR/mariadb_functions.sh"

#############################################
# Main
#############################################

log_step "Nextcloud 33 Setup (PHP + MariaDB)"
echo "Log file: $LOG_FILE"

list_php_modules
# list_mariadb_modules

reset_php_module
enable_php_module
install_php
verify_php

# reset_mariadb_module
# enable_mariadb_module
# install_mariadb
# start_mariadb
#verify_mariadb

log_step "Installation complete"
echo "Log saved to: $LOG_FILE"
