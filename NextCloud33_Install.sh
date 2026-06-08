#!/bin/bash

#############################################
# Logging / Runtime variables
#############################################

LOG_DIR="/var/log/nextcloud_install"
LOG_DATE=$(date +"%Y%m%d%H%M%S")
LOG_FILE="${LOG_DIR}/NextCloud33_install_${LOG_DATE}.log"

mkdir -p "$LOG_DIR"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

exec > >(tee -a "$LOG_FILE") 2>&1

#############################################
# Configuration (EDIT THESE ONLY)
#############################################

PHP_VERSION="8.3"
MARIADB_VERSION="10.11"

PHP_PACKAGES_FILE="/etc/nextcloud/php-packages.txt"
MARIADB_PACKAGES_FILE="/etc/nextcloud/mariadb-packages.txt"

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

#############################################
# Utility
#############################################

print_header() {
    echo
    echo "--------------------------------------"
    echo "$1"
    echo "--------------------------------------"
    echo
}

#############################################
# PHP functions
#############################################

list_php_modules() {
    log_step "List available PHP module streams"
    sudo dnf module list php
}

reset_php_module() {
    log_step "Reset PHP module"
    sudo dnf module reset php -y
}

enable_php_module() {
    log_step "Enable PHP ${PHP_VERSION}"
    sudo dnf module enable php:${PHP_VERSION} -y
}

install_php() {
    log_step "Install PHP packages"

    log_info "Reading from ${PHP_PACKAGES_FILE}"

    if [[ ! -f "$PHP_PACKAGES_FILE" ]]; then
        echo "ERROR: PHP package file not found: $PHP_PACKAGES_FILE"
        exit 1
    fi

    PHP_PACKAGES=$(grep -vE '^\s*#|^\s*$' "$PHP_PACKAGES_FILE")
    sudo dnf install -y $PHP_PACKAGES
}

verify_php() {
    log_step "Verify PHP installation"
    php -v
}

#############################################
# MariaDB functions
#############################################

list_mariadb_modules() {
    log_step "List available MariaDB module streams"
    sudo dnf module list mariadb
}

reset_mariadb_module() {
    log_step "Reset MariaDB module"
    sudo dnf module reset mariadb -y
}

enable_mariadb_module() {
    log_step "Enable MariaDB ${MARIADB_VERSION}"
    sudo dnf module enable mariadb:${MARIADB_VERSION} -y
}

read_mariadb_packages() {
    if [[ ! -f "$MARIADB_PACKAGES_FILE" ]]; then
        echo "ERROR: MariaDB package file not found: $MARIADB_PACKAGES_FILE"
        exit 1
    fi

    grep -vE '^\s*#|^\s*$' "$MARIADB_PACKAGES_FILE"
}

install_mariadb() {
    log_step "Install MariaDB packages"

    log_info "Reading from ${MARIADB_PACKAGES_FILE}"

    MARIADB_PACKAGES=$(read_mariadb_packages)

    sudo dnf install -y $MARIADB_PACKAGES
}

start_mariadb() {
    log_step "Start MariaDB service"
    sudo systemctl enable --now mariadb
}

verify_mariadb() {
    log_step "Verify MariaDB installation"
    mysql --version
    systemctl status mariadb --no-pager
}

#############################################
# Main
#############################################

log_step "Nextcloud 33 Setup (PHP + MariaDB)"
echo "Log file: $LOG_FILE"

list_php_modules
list_mariadb_modules

reset_php_module
enable_php_module
install_php
verify_php

reset_mariadb_module
enable_mariadb_module
install_mariadb
start_mariadb
verify_mariadb

log_step "Installation complete"
echo "Log saved to: $LOG_FILE"
