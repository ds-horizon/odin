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
    local repo_url="https://api.github.com/repos/ds-horizon/odin-cli"

    # Install to home directory
    local install_dir="${HOME}"

    # Get GitHub PAT from environment variable or prompt user
    local github_token
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        github_token="${GITHUB_TOKEN}"
        log_info "Using GitHub PAT from GITHUB_TOKEN environment variable"
    elif [[ -t 0 ]]; then
        # prompt user for PAT
        log_info "GitHub Personal Access Token (PAT) is required to download the CLI binary."
        log_info "You can create one at: https://github.com/settings/tokens"
        log_info "Required scope: 'public_repo' or 'repo'"
        read -rsp "Enter your GitHub PAT: " github_token
        echo ""
    else
        log_error "Non-interactive terminal detected and GITHUB_TOKEN not set."
        log_info "Please set GITHUB_TOKEN environment variable or run in an interactive terminal."
        return 1
    fi

    if [[ -z "${github_token}" ]]; then
        log_error "GitHub PAT is required to download the CLI binary"
        return 1
    fi

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
    log_info "Fetching latest release metadata..."

    local temp_dir=""
    temp_dir=$(mktemp -d)
    trap 'if [[ -n "${temp_dir:-}" ]] && [[ -d "${temp_dir}" ]]; then rm -rf "${temp_dir}"; fi' EXIT INT TERM

    local archive_path="${temp_dir}/odin.tar.gz"
    local asset_name="odin_${os_type}_${arch_type}.tar.gz"

    local latest_tag
    if ! latest_tag=$(curl -s -L -H "Authorization: token ${github_token}" \
        "${repo_url}/releases/latest" \
        | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); then
        log_error "Failed to fetch latest release tag"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    if [[ -z "${latest_tag}" ]]; then
        log_error "Unable to determine latest release tag"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    log_info "Latest release: ${latest_tag}"

    # Check if jq is available for parsing JSON
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is required to parse GitHub API response"
        log_info "Please install jq: brew install jq (macOS) or apt-get install jq (Linux)"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    # Extract asset ID from JSON
    local asset_id
    asset_id=$(curl -s -L -H "Authorization: token ${github_token}" \
        "${repo_url}/releases/tags/${latest_tag}" \
        | jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .id')

    if [[ -z "${asset_id}" || "${asset_id}" == "null" ]]; then
        log_error "Release asset not found for: ${asset_name}"
        trap - EXIT INT TERM
        rm -rf "${temp_dir}"
        return 1
    fi

    log_info "Found asset ID: ${asset_id}"
    log_info "Downloading asset (${asset_name})..."

    # Download the asset
    if ! curl -L \
        -H "Authorization: token ${github_token}" \
        -H "Accept: application/octet-stream" \
        "${repo_url}/releases/assets/${asset_id}" \
        -o "${archive_path}"; then
        log_error "Failed to download asset from GitHub"
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
