#!/bin/bash
set -euo pipefail

#############################################
# Software Versions
#############################################

PHP_VERSION="8.3"
MARIADB_VERSION="10.11"

#############################################
# Define Paths
#############################################

export BASE_DIR="/root/nextcloud"

export LOG_DIR="$BASE_DIR/log"
export BIN_DIR="$BASE_DIR/bin"
export ETC_DIR="$BASE_DIR/etc"

# The variable assignment below is silly. 
# Need to search and replace.
export SCRIPT_DIR="$BIN_DIR"


#############################################
# Defaults (IMPORTANT)
#############################################

INSTALL_PHP=false
INSTALL_DB=false
CREATE_DIRS=false

#############################################
# Log file (must exist before exec redirect)
#############################################

# Script name without .sh
SCRIPT_NAME="$(basename "$0" .sh)"

# Timestamp: yyyymmddhhmmss
DATE_STR="$(date +%Y%m%d%H%M%S)"

# Log filename
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}_${DATE_STR}.log"

exec > >(tee -a "$LOG_FILE") 2>&1

#############################################
# Usage
#############################################

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --php           Install PHP only
  --db            Install MariaDB only
  --all           Install both PHP and MariaDB
  --dir           Create required directory structure
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
        --dir)
            CREATE_DIRS=true
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

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
# Main
#############################################

log_step "Nextcloud 33 Installation"
echo "Log file: $LOG_FILE"

#############################################
# Directory Creation (conditional)
#############################################

if [[ "$CREATE_DIRS" == true ]]; then
    mkdir -p $BASE_DIR
    mkdir -p $LOG_DIR
    mkdir -p $BIN_DIR
    mkdir -p $ETC_DIR
fi

#############################################
# PHP installation (conditional)
#############################################

if [[ "$INSTALL_PHP" == true ]]; then
    log_step "PHP Installation"

    PHP_PACKAGES_FILE="${ETC_DIR}/php-packages.txt"
    export PHP_PACKAGES_FILE
    export PHP_VERSION

    source "$SCRIPT_DIR/php_functions.sh"
    install_php_full
fi

#############################################
# MariaDB installation (conditional)
#############################################

if [[ "$INSTALL_DB" == true ]]; then
    log_step "MariaDB Installation"
    MARIADB_PACKAGES_FILE="${ETC_DIR}/mariadb-packages.txt"
    source "$SCRIPT_DIR/mariadb_functions.sh"
    install_mariadb_full
fi

#############################################
# Completion
#############################################

log_step "Installation complete"
echo "Log saved to: $LOG_FILE"
