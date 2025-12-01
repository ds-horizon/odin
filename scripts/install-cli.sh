#!/bin/bash

#==============================================================================
# Odin CLI Installation Script
#
# This script installs the Odin CLI binary from GitHub releases.
#==============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions if available (for logging)
if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/utils.sh"
else
    # Fallback logging functions if utils.sh is not available
    log_info() { echo "[INFO] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
    log_success() { echo "[SUCCESS] $*"; }
    log_warning() { echo "[WARNING] $*"; }
    log_step() { echo "[STEP] $*"; }
fi

# Install Odin CLI binary from GitHub releases
install_odin_cli() {
    local binary_name="odin"
    local api_repo_url="https://api.github.com/repos/ds-horizon/odin-cli"
    local download_base_url="https://github.com/ds-horizon/odin-cli/releases/download"

    # Install to home directory
    local install_dir="${HOME}"

    # Detect OS + ARCH
    local os_type arch_type
    os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch_type=$(uname -m | tr '[:upper:]' '[:lower:]')

    case "${arch_type}" in
        x86_64) arch_type="amd64" ;;
        aarch64|arm64) arch_type="arm64" ;;
        *)
            log_error "Unsupported architecture: ${arch_type}"
            return 1
            ;;
    esac

    case "${os_type}" in
        darwin|linux) ;;
        *)
            log_error "Unsupported operating system: ${os_type}"
            return 1
            ;;
    esac

    log_info "Detected system: ${os_type} ${arch_type}"

    local temp_dir=""
    temp_dir=$(mktemp -d)
    trap 'if [[ -n "${temp_dir:-}" ]] && [[ -d "${temp_dir}" ]]; then rm -rf "${temp_dir}"; fi' EXIT INT TERM

    local archive_path="${temp_dir}/odin.tar.gz"
    local asset_name="odin_${os_type}_${arch_type}.tar.gz"

    # Check if a specific version is requested via environment variable
    local release_tag
    if [[ -n "${ODIN_CLI_VERSION:-}" ]]; then
        if [[ "${ODIN_CLI_VERSION}" =~ ^v ]]; then
            release_tag="${ODIN_CLI_VERSION}"
        else
            release_tag="v${ODIN_CLI_VERSION}"
        fi
        log_info "Using specified version: ${release_tag}"
    else
        log_info "Fetching latest release metadata..."
        if ! release_tag=$(curl -s -L \
            "${api_repo_url}/releases/latest" \
            | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); then
            log_error "Failed to fetch latest release tag"
            trap - EXIT INT TERM
            rm -rf "${temp_dir}"
            return 1
        fi

        if [[ -z "${release_tag}" ]]; then
            log_error "Unable to determine latest release tag"
            trap - EXIT INT TERM
            rm -rf "${temp_dir}"
            return 1
        fi
        log_info "Latest release: ${release_tag}"
    fi

    local download_url="${download_base_url}/${release_tag}/${asset_name}"
    log_info "Downloading ${asset_name} from ${release_tag}..."

    # Download the asset
    local http_code
    http_code=$(curl -sL -o "${archive_path}" -w "%{http_code}" "${download_url}")

    if [[ "${http_code}" -ne 200 ]]; then
        if [[ "${http_code}" -eq 404 ]]; then
            log_error "Release asset not found: ${asset_name} for version ${release_tag}"
            log_info "Please verify the version and asset name exist in the repository"
        else
            log_error "Failed to download asset (HTTP ${http_code})"
        fi
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    log_info "Extracting..."

    # Extract the archive
    if ! tar -xzf "${archive_path}" -C "${temp_dir}"; then
        log_error "Archive extraction failed"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    # Find the binary in extracted files
    local extracted_binary
    extracted_binary=$(find "${temp_dir}" -name "${binary_name}" -type f | head -n 1)

    if [[ -z "${extracted_binary}" ]] || [[ ! -f "${extracted_binary}" ]]; then
        log_error "Binary not found inside archive"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    # Move binary to install directory
    if ! mv "${extracted_binary}" "${install_dir}/${binary_name}"; then
        log_error "Failed to move binary to ${install_dir}/${binary_name}"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    # Make binary executable
    chmod +x "${install_dir}/${binary_name}"

    # Remove quarantine attribute on macOS
    if [[ "${os_type}" == "darwin" ]]; then
        xattr -d com.apple.quarantine "${install_dir}/${binary_name}" 2>/dev/null || true
    fi

    # Clean up temp directory and remove trap
    trap - EXIT INT TERM
    rm -rf "${temp_dir}"

    log_success "Odin CLI installed successfully!"
    log_info ""
    log_info "📦 Binary location: ${install_dir}/${binary_name}"
    log_info ""
    log_info "📋 To use the CLI, move it to a directory in your PATH:"
    log_info "   sudo mv ${install_dir}/${binary_name} /usr/local/bin/${binary_name}"
    log_info "   Or"
    log_info "   use binary manually as '/<Binary location> <command>'"
    log_info ""

    return 0
}

# Main execution (only if script is run directly, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_step "Installing Odin CLI"
    if install_odin_cli; then
        exit 0
    else
        exit 1
    fi
fi
