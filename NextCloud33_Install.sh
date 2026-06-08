#!/bin/bash

#############################################
# Software Versions
#############################################

PHP_VERSION="8.3"
MARIADB_VERSION="10.11"

#############################################
# Defaults (IMPORTANT)
#############################################

INSTALL_PHP=false
INSTALL_DB=false

#############################################
# Global directory layout
#############################################

init_directories() {
    export BASE_DIR="/root/nextcloud"
    export LOG_DIR="/root/log"
    export BIN_DIR="/root/.bin"
    export ETC_DIR="/root/etc"

    mkdir -p "$BASE_DIR" \
             "$LOG_DIR" \
             "$BIN_DIR" \
             "$ETC_DIR"
}

init_directories

#############################################
# Log file (must exist before exec redirect)
#############################################

LOG_FILE="${LOG_DIR}/nextcloud-setup.log"

exec > >(tee -a "$LOG_FILE") 2>&1

#############################################
# Usage
#############################################

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --php     Install PHP only
  --db      Install MariaDB only
  --all     Install both PHP and MariaDB
EOF
    exit 1
}

#############################################
# Parse arguments
#############################################

if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --php)
            INSTALL_PHP=true
            ;;
        --db)
            INSTALL_DB=true
            ;;
        --all)
            INSTALL_PHP=true
            INSTALL_DB=true
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

#############################################
# Configuration
#############################################

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

#############################################
# PHP installation (conditional)
#############################################

if [[ "$INSTALL_PHP" == true ]]; then
    log_step "PHP Installation"

    list_php_modules
    reset_php_module
    enable_php_module
    install_php
    verify_php
fi

#############################################
# MariaDB installation (conditional)
#############################################

if [[ "$INSTALL_DB" == true ]]; then
    log_step "MariaDB Installation"

    list_mariadb_modules
    reset_mariadb_module
    enable_mariadb_module
    install_mariadb
    start_mariadb
    verify_mariadb
fi

#############################################
# Completion
#############################################

log_step "Installation complete"
echo "Log saved to: $LOG_FILE"
