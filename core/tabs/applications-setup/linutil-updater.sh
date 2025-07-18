#!/bin/sh -e

. ../common-script.sh

updateLinutil() {
    if [ ! -e "$HOME/.cargo/bin/linutil" ]; then
        printf "%b\n" "${RED}This script only updates the binary installed through cargo.\nlinutil_tui is not installed.${RC}"
        exit 1
    fi

    if ! command_exists cargo; then
        printf "%b\n" "${YELLOW}Installing rustup...${RC}"
        case "$PACKAGER" in
            pacman)
                "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm rustup
                ;;
            dnf)
                "$ESCALATION_TOOL" "$PACKAGER" install -y curl rustup man-pages man-db man
                rustup-init -y
                ;;
            zypper)
                "$ESCALATION_TOOL" "$PACKAGER" install -n curl gcc make rustup
                ;;
            apk)
                "$ESCALATION_TOOL" "$PACKAGER" add build-base rustup
                rustup-init -y
                ;;
            *)
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                ;;
        esac
    fi

    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
    rustup default stable

    INSTALLED_VERSION=$(cargo install --list | grep "linutil_tui" | awk '{print $2}' | tr -d 'v:')
    LATEST_VERSION=$(curl -s https://crates.io/api/v1/crates/linutil_tui | grep -oP '"max_version":\s*"\K[^"]+')

    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
        printf "%b\n" "${GREEN}linutil_tui is up to date.${RC}"
        exit 0
    fi

    printf "%b\n" "${YELLOW}Updating linutil_tui...${RC}"
    cargo install --force linutil_tui
    printf "%b\n" "${GREEN}Updated successfully.${RC}"
}

checkEnv
checkEscalationTool
checkAURHelper
updateLinutil
