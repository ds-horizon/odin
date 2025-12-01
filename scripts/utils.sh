#!/bin/bash

#==============================================================================
# Odin Installation Utilities
#
# This script contains utility functions for logging, environment management,
# and common operations used across the Odin installation scripts.
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=14
CURRENT_STEP=0

#==============================================================================
# LOGGING FUNCTIONS
#==============================================================================

# General logging function
log() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${message}"
    echo "[${timestamp}] ${message}" | sed 's/\x1b\[[0-9;]*m//g' >> "${LOG_FILE}"
}

# Info logging
log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

# Success logging
log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

# Warning logging
log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

# Error logging
log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Debug logging
log_debug() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Always write to log file
    echo "[${timestamp}] [DEBUG] ${message}" >> "${LOG_FILE}"

    # Only show on console if DEBUG is enabled
    if [[ "${DEBUG}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} ${message}"
    fi
}

# Log command output
log_command_output() {
    local command="$1"
    local output="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[${timestamp}] [COMMAND] ${command}" >> "${LOG_FILE}"
    echo "[${timestamp}] [OUTPUT] ${output}" >> "${LOG_FILE}"
}

# Log installation step with progress
log_step() {
    local message="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    log_info "[Step ${CURRENT_STEP}/${TOTAL_STEPS}] ${message}"
}

# Log skipped step with progress
log_step_skipped() {
    local message="$1"
    local reason="${2:-not needed}"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    log_info "[Step ${CURRENT_STEP}/${TOTAL_STEPS}] ${message} - Skipped (${reason})"
}

#==============================================================================
# NETWORK HELPERS
#==============================================================================

# Download a file with retry logic
download_with_retry() {
    local url="$1"
    local output_path="$2"
    local max_attempts="${3:-5}"
    local delay_seconds="${4:-2}"

    local attempt=1
    while true; do
        log_info "Downloading ${url} (attempt ${attempt}/${max_attempts})..."
        if curl --fail -L -o "${output_path}" "${url}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_success "Downloaded ${url} -> ${output_path}"
            return 0
        fi
        if [[ "${attempt}" -ge "${max_attempts}" ]]; then
            log_error "Failed to download ${url} after ${max_attempts} attempts"
            return 1
        fi
        log_warning "Download failed, retrying in ${delay_seconds}s..."
        sleep "${delay_seconds}"
        attempt=$((attempt + 1))
    done
}

#==============================================================================
# ENVIRONMENT AND CONFIGURATION FUNCTIONS
#==============================================================================

# Log environment and configuration
log_environment() {
    log_debug "=== Environment Information ==="
    log_debug "Script Directory: ${SCRIPT_DIR}"
    log_debug "Log File: ${LOG_FILE}"
    log_debug "Namespace: ${NAMESPACE}"
    log_debug "Release Name: ${RELEASE_NAME}"
    log_debug "Chart Name: ${CHART_NAME}"
    log_debug "Values File: ${VALUES_FILE:-"Using chart defaults"}"
    log_debug "Debug Mode: ${DEBUG}"
    log_debug "=============================="
}

# Confirm user action
confirm_action() {
    local message="$1"
    local default="${2:-N}"  # Default to 'N' if not provided

    # Prepare the prompt based on default
    local prompt
    if [[ "${default}" == "Y" || "${default}" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    log_info ""
    log_info "${message}"
    read -rp "${prompt}: " response

    # Handle empty response (use default)
    if [[ -z "${response}" ]]; then
        response="${default}"
    fi

    # Convert to lowercase for comparison
    response_lower=$(echo "${response}" | tr '[:upper:]' '[:lower:]')

    if [[ "${response_lower}" == "y" || "${response_lower}" == "yes" ]]; then
        return 0  # User confirmed
    else
        return 1  # User declined
    fi
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local install_info="$2"

    if command -v "${cmd}" >/dev/null 2>&1; then
        log_success "${cmd} is available"
        return 0
    else
        log_error "${cmd} is not installed"
        if [[ -n "${install_info}" ]]; then
            log_info "${install_info}"
        fi
        return 1
    fi
}

#==============================================================================
# YAML PARSING FUNCTIONS
#==============================================================================

# Check if internal MySQL is enabled
is_internal_mysql_enabled() {
    local values_file="$1"

    # If no values file provided, assume internal MySQL is enabled (default)
    if [[ -z "${values_file}" || ! -f "${values_file}" ]]; then
        log_debug "No values file provided, assuming internal MySQL is enabled"
        return 0
    fi

    log_debug "Checking if internal MySQL is enabled in ${values_file}"

    # Try to use yq if available for robust YAML parsing
    if command -v yq >/dev/null 2>&1; then
        local external_enabled
        external_enabled=$(yq eval '.mysql.external.enabled // false' "${values_file}" 2>/dev/null)
        log_debug "MySQL external.enabled: ${external_enabled}"

        if [[ "${external_enabled}" == "true" ]]; then
            log_debug "External MySQL is enabled, internal MySQL not required"
            return 1  # Internal MySQL is NOT enabled
        else
            log_debug "External MySQL is not enabled, internal MySQL required"
            return 0  # Internal MySQL IS enabled
        fi
    else
        # Fallback to grep-based parsing
        log_debug "yq not available, using grep-based parsing"
        if grep -q "mysql:" "${values_file}" && grep -A 10 "mysql:" "${values_file}" | grep -q "external:" && grep -A 5 "external:" "${values_file}" | grep -q "enabled: true"; then
            log_debug "Found external MySQL enabled via grep"
            return 1  # Internal MySQL is NOT enabled
        else
            log_debug "External MySQL not found or not enabled via grep"
            return 0  # Internal MySQL IS enabled
        fi
    fi
}

# Check if orchestrator is enabled
is_orchestrator_enabled() {
    local values_file="$1"

    # If no values file provided, assume orchestrator is enabled (default)
    if [[ -z "${values_file}" || ! -f "${values_file}" ]]; then
        log_debug "No values file provided, assuming orchestrator is enabled"
        return 0
    fi

    log_debug "Checking if orchestrator is enabled in ${values_file}"

    # Try to use yq if available for robust YAML parsing
    if command -v yq >/dev/null 2>&1; then
        local orchestrator_enabled
        orchestrator_enabled=$(yq eval '.orchestrator.enabled // true' "${values_file}" 2>/dev/null)
        log_debug "Orchestrator enabled: ${orchestrator_enabled}"

        if [[ "${orchestrator_enabled}" == "false" ]]; then
            log_debug "Orchestrator is disabled"
            return 1  # Orchestrator is NOT enabled
        else
            log_debug "Orchestrator is enabled"
            return 0  # Orchestrator IS enabled
        fi
    else
        # Fallback to grep-based parsing
        log_debug "yq not available, using grep-based parsing"
        if grep -q "orchestrator:" "${values_file}" && grep -A 5 "orchestrator:" "${values_file}" | grep -q "enabled: false"; then
            log_debug "Found orchestrator disabled via grep"
            return 1  # Orchestrator is NOT enabled
        else
            log_debug "Orchestrator not found or not disabled via grep"
            return 0  # Orchestrator IS enabled
        fi
    fi
}

#==============================================================================
# CLEANUP AND ERROR HANDLING
#==============================================================================

# Cleanup function
cleanup() {
    log_debug "Cleanup function called"
    # Add any cleanup logic here if needed
}

# Set up signal handlers
setup_signal_handlers() {
    trap cleanup EXIT
    trap 'log_error "Script interrupted by user"; exit 130' INT TERM
}

#==============================================================================
# HELP AND USAGE
#==============================================================================

# Show help message
show_help() {
    cat << EOF
Odin Helm Chart Installation Script

This script checks prerequisites and installs the Odin Helm chart with
user-provided configuration values.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message and exit
    -n, --namespace NAME    Kubernetes namespace (default: odin)
    -r, --release NAME      Helm release name (default: odin)
    -v, --values FILE       Path to custom values file
    --debug                 Enable debug output and logging
    --preload-images        Preload Docker images to Kind cluster (Kind clusters only)

PREREQUISITES:
    The script will automatically check for and optionally install:
    - kubectl (Kubernetes CLI)
    - helm (Helm package manager)
    - docker (if Kind cluster installation is needed)
    - Percona MySQL Server Operator (if internal MySQL is enabled)
    - KEDA (if orchestrator component is enabled)

EXAMPLES:
    # Basic installation with defaults
    $0

    # Install with custom values and namespace
    $0 -n production -v my-values.yaml

    # Install on Kind cluster with image preloading
    $0 --preload-images

For more information, see the README.md file.
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -r|--release)
                RELEASE_NAME="$2"
                shift 2
                ;;
            -v|--values)
                VALUES_FILE="$2"
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --preload-images)
                export PRELOAD_IMAGES=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                log_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -n "${VALUES_FILE}" && ! -f "${VALUES_FILE}" ]]; then
        log_error "Values file not found: ${VALUES_FILE}"
        exit 1
    fi

    log_debug "Command line arguments parsed successfully"
}
