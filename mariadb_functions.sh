#!/bin/bash

#############################################
# MariaDB functions only
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
