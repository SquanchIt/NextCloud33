#!/bin/bash
set -euo pipefail

#############################################
# PHP functions only
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
    if [[ -z "${PHP_VERSION:-}" ]]; then
        echo "ERROR: PHP_VERSION not set"
        exit 1
    fi

    log_step "Enable PHP ${PHP_VERSION}"
    sudo dnf module enable "php:${PHP_VERSION}" -y
}

install_php_packages() {
    if [[ -z "${PHP_PACKAGES_FILE:-}" ]]; then
        echo "ERROR: PHP_PACKAGES_FILE not set"
        exit 1
    fi

    log_step "Install PHP packages"
    log_info "Reading from ${PHP_PACKAGES_FILE}"

    if [[ ! -f "$PHP_PACKAGES_FILE" ]]; then
        echo "ERROR: PHP package file not found: $PHP_PACKAGES_FILE"
        exit 1
    fi

    mapfile -t PHP_PACKAGES < <(grep -vE '^\s*#|^\s*$' "$PHP_PACKAGES_FILE")

    if [[ "${#PHP_PACKAGES[@]}" -eq 0 ]]; then
        echo "ERROR: No PHP packages found in: $PHP_PACKAGES_FILE"
        exit 1
    fi

    sudo dnf install -y "${PHP_PACKAGES[@]}"
}

verify_php() {
    log_step "Verify PHP installation"
    php -v
}

#############################################
# PHP installation (conditional)
#############################################

install_php_full() {
    list_php_modules
    reset_php_module
    enable_php_module
    install_php_packages
    verify_php
}
