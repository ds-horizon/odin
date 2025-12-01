#!/bin/bash

#==============================================================================
# Odin Helm Chart Installation Script
#
# This script checks prerequisites and installs the Odin Helm chart with
# user-provided configuration values.
#
# Usage: ./install.sh [OPTIONS]
#
# Options:
#   -h, --help          Show this help message
#   -n, --namespace     Kubernetes namespace (default: odin)
#   -r, --release       Helm release name (default: odin)
#   -v, --values        Custom values file path
#   --debug            Enable debug output
#==============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# LOG_FILE is relative to the original install.sh execution, so keep it in /tmp
LOG_FILE="/tmp/odin-install-$(date +%Y%m%d-%H%M%S).log"

# Default values
DEFAULT_NAMESPACE="odin"
DEFAULT_RELEASE_NAME="odin"
DEFAULT_CHART_NAME="oci://registry-1.docker.io/odinhq/odin"  # Chart from registry
DEFAULT_VALUES_FILE=""  # Will use chart defaults or user-provided file

# Command line options
NAMESPACE="${DEFAULT_NAMESPACE}"
RELEASE_NAME="${DEFAULT_RELEASE_NAME}"
CHART_NAME="${DEFAULT_CHART_NAME}"
VALUES_FILE="${DEFAULT_VALUES_FILE}"
DEBUG=false
export PRELOAD_IMAGES=false

#==============================================================================
# IMPORT UTILITY MODULES
#==============================================================================

# Source utility functions
if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/utils.sh"
else
    echo "ERROR: utils.sh not found in ${SCRIPT_DIR}"
    echo "Please ensure all installation script files are in the same directory"
    exit 1
fi

# Source validation functions
if [[ -f "${SCRIPT_DIR}/validate.sh" ]]; then
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/validate.sh"
else
    log_error "validate.sh not found in ${SCRIPT_DIR}"
    log_error "Please ensure all installation script files are in the same directory"
    exit 1
fi

#==============================================================================
# MAIN INSTALLATION FUNCTIONS
#==============================================================================

# Check if current context is a Kind cluster
is_kind_cluster() {
    if command -v kubectl >/dev/null 2>&1; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null || true)
        if [[ -n "${current_context}" && "${current_context}" == kind-* ]]; then
            return 0
        fi
    fi
    return 1
}

# Detect Kind cluster and set default values file if not provided
detect_kind_and_default_values() {
    # Do not override if user has provided a values file
    if [[ -n "${VALUES_FILE}" ]]; then
        return
    fi

    if is_kind_cluster; then
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null || true)
        local local_values_file="${SCRIPT_DIR}/local-install-values.yaml"
        if [[ -f "${local_values_file}" ]]; then
            VALUES_FILE="${local_values_file}"
            log_info "Detected Kind cluster (${current_context}); using values file: ${VALUES_FILE}"
        else
            log_warning "Detected Kind cluster but values file not found at ${local_values_file}; continuing with chart defaults"
        fi
    fi
}

# Generate ES256 keys and write to a new values file
generate_and_update_keys() {
    local values_file="${VALUES_FILE:-}"
    local local_values_file="${SCRIPT_DIR}/local-install-values.yaml"
    local output_file="${SCRIPT_DIR}/generated-key-values.yaml"
    local tmpdir=""

    # Default to local-install-values.yaml if VALUES_FILE not set
    if [[ -z "${values_file}" && -f "${local_values_file}" ]]; then
        values_file="${local_values_file}"
    fi

    # Skip generation if keys already exist
    if [[ -n "${values_file}" && -f "${values_file}" ]]; then
        existing_pub="$(awk -F': ' '/deployer.security.auth.publicKey/{print $2}' "${values_file}" | tr -d ' \n\r' )"
        existing_priv="$(awk -F': ' '/deployer.security.auth.privateKey/{print $2}' "${values_file}" | tr -d ' \n\r' )"

        if [[ -n "${existing_pub}" && -n "${existing_priv}" ]]; then
            log_info "ES256 keys already exist in ${values_file}. Skipping generation."
            return 0
        fi
    fi

    # Check openssl
    if ! command -v openssl >/dev/null 2>&1; then
        log_error "openssl not found. Cannot generate keys."
        return 1
    fi

    log_info "Generating ES256 keys..."

    tmpdir="$(mktemp -d)"
    trap 'if [[ -n "${tmpdir:-}" ]] && [[ -d "${tmpdir:-}" ]]; then rm -rf "${tmpdir:-}"; fi' EXIT INT TERM

    local priv_file="${tmpdir}/private.pem"
    local pub_file="${tmpdir}/public.pem"

    # Generate private key (PKCS#8)
    if ! openssl genpkey -algorithm EC \
            -pkeyopt ec_paramgen_curve:P-256 \
            -pkeyopt ec_param_enc:named_curve \
            -out "${priv_file}" 2>/dev/null; then
        log_error "private key generation failed"
        trap - EXIT INT TERM
        rm -rf "${tmpdir}"
        return 1
    fi

    # Generate public key
    if ! openssl pkey -pubout -in "${priv_file}" -out "${pub_file}" 2>/dev/null; then
        log_error "public key generation failed"
        trap - EXIT INT TERM
        rm -rf "${tmpdir}"
        return 1
    fi

    local public_key private_key
    public_key="$(tr -d '\n\r' < "${pub_file}")"
    private_key="$(tr -d '\n\r' < "${priv_file}")"

    # Write to new values file
    cat > "${output_file}" <<EOF
deployer:
  security:
    auth:
      publicKey: "${public_key}"
      privateKey: "${private_key}"
EOF

    # Clean up and remove trap
    trap - EXIT INT TERM
    rm -rf "${tmpdir}"

    log_success "Generated ES256 keys written to: ${output_file}"
}

# Setup local development data for Kind clusters
setup_local_dev_data() {
    log_step "Setting up local development data"

    # Only run for Kind clusters
    if ! is_kind_cluster; then
        log_step_skipped "Setting up local development data" "not a Kind cluster"
        return 0
    fi

    local setup_script="${SCRIPT_DIR}/local_account_data/setup_local_dev.sh"
    local kind_sa_file="${SCRIPT_DIR}/local_account_data/data/provider_service_accounts/kind_service_account.json"

    # Check if grpcurl is available
    if [[ ! -x "./grpcurl" ]]; then
        log_warning "./grpcurl not found, skipping local dev data setup"
        log_warning "To setup local dev data later, ensure grpcurl is available and run: ${setup_script}"
        log_step_skipped "Setting up local development data" "grpcurl not available"
        return 0
    fi

    log_info "Setting up local development data for Kind cluster..."
    log_info "This will create provider accounts and service accounts in the account manager."

    # Ask for confirmation
    if ! confirm_action "Do you want to setup local development data now?"; then
        log_info "Skipping local dev data setup"
        log_info "You can run it later with: ${setup_script}"
        log_step_skipped "Setting up local development data" "user declined"
        return 0
    fi

    # Generate kubeconfig for in-cluster access
    log_info "Generating kubeconfig for in-cluster access..."
    local kubeconfig_base64
    kubeconfig_base64=$(
    kubectl config view --minify --raw \
        | sed 's#server: .*#server: https://kubernetes.default.svc.cluster.local#' \
        | base64 | tr -d '\n'
    )
    if [[ -z "${kubeconfig_base64}" ]]; then
        log_error "Failed to generate kubeconfig"
        return 1
    fi

    # Update kubeconfig field in the JSON file
    log_info "Updating kubeconfig in kind_service_account.json..."

    escaped_kc=$(printf '%s' "${kubeconfig_base64}" | sed 's/[&/\]/\\&/g')

    if ! sed -i '' "s/\"kubeconfig\": \".*\"/\"kubeconfig\": \"${escaped_kc}\"/" "${kind_sa_file}"; then
        log_error "Failed to update kubeconfig in ${kind_sa_file}"
        return 1
    fi

    log_info "Starting port-forward to account-manager service..."

    # Start port-forward in background
    kubectl port-forward "svc/${RELEASE_NAME}-account-manager" 8080:80 -n "${NAMESPACE}" > /dev/null 2>&1 &
    local port_forward_pid=$!

    # Ensure port-forward is killed on exit
    trap 'kill '"${port_forward_pid}"' 2>/dev/null || true' EXIT INT TERM

    # Wait for port-forward to be ready
    log_info "Waiting for port-forward to be ready..."
    local max_wait=30
    local waited=0
    while ! nc -z localhost 8080 >/dev/null 2>&1; do
        if [[ ${waited} -ge ${max_wait} ]]; then
            log_error "Port-forward failed to start within ${max_wait} seconds"
            kill "${port_forward_pid}" 2>/dev/null || true
            return 1
        fi
        sleep 1
        waited=$((waited + 1))
    done

    log_success "Port-forward established successfully"

    # Run the setup script
    log_info "Running local dev setup script..."
    if bash "${setup_script}"; then
        log_success "Local development data setup completed successfully"
    else
        log_warning "Local dev setup script failed. You can run it manually later: ${setup_script}"
    fi

    # Kill the port-forward
    log_info "Stopping port-forward..."
    kill "${port_forward_pid}" 2>/dev/null || true
    wait "${port_forward_pid}" 2>/dev/null || true

    return 0
}

# Collect user input and display configuration
collect_user_input() {
    log_info "Collecting user configuration..."

    # Display current configuration
    log_info "Current configuration:"
    log_info "  Namespace: ${NAMESPACE}"
    log_info "  Release Name: ${RELEASE_NAME}"
    log_info "  Chart: ${CHART_NAME}"
    log_info "  Values File: ${VALUES_FILE:-"Using chart defaults"}"

    # Show MySQL configuration status
    if is_internal_mysql_enabled "${VALUES_FILE}"; then
        log_info "  MySQL: Internal (Percona operator required)"
    else
        log_info "  MySQL: External (Percona operator not required)"
    fi

    # Show Orchestrator configuration status
    if is_orchestrator_enabled "${VALUES_FILE}"; then
        log_info "  Orchestrator: Enabled (KEDA required)"
    else
        log_info "  Orchestrator: Disabled (KEDA not required)"
    fi

    log_success "Configuration collected"
}

# Install Odin Helm chart
install_odin() {
    # Prepare Helm command (using upgrade --install for idempotency)
    local helm_cmd="helm upgrade --install ${RELEASE_NAME} ${CHART_NAME}"
    log_info "Executing Helm upgrade --install..."

    # Add namespace
    helm_cmd="${helm_cmd} --namespace ${NAMESPACE} --create-namespace --wait --timeout 900s"

    # Add values file if provided
    if [[ -n "${VALUES_FILE}" ]]; then
        helm_cmd="${helm_cmd} --values ${VALUES_FILE}"
    fi

    # Add generated key values file if it exists
    local generated_key_file="${SCRIPT_DIR}/generated-key-values.yaml"
    if [[ -f "${generated_key_file}" ]]; then
        helm_cmd="${helm_cmd} --values ${generated_key_file}"
    fi

    # Add debug flag if enabled
    if [[ "${DEBUG}" == "true" ]]; then
        helm_cmd="${helm_cmd} --debug"
    fi

    log_debug "Executing: ${helm_cmd}"

    # Execute Helm command
    if ${helm_cmd} 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Odin Helm chart installed/upgraded successfully"
        return 0
    else
        log_error "Helm installation/upgrade failed"
        log_error "Check log file: ${LOG_FILE}"
        return 1
    fi
}

# Display post-installation information
post_install_info() {
    log_info ""
    log_info "🎉 Odin installation completed successfully!"
    log_info ""
    log_info "📌 Post-installation checklist:"
    log_info "----------------------------------"
    log_info "1. Check the status of your pods:"
    log_info "   kubectl get pods -n ${NAMESPACE}"
    log_info ""
    log_info "2. Check the services:"
    log_info "   kubectl get services -n ${NAMESPACE}"
    log_info ""
    log_info "3. View the logs:"
    log_info "   kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/instance=odin -f --max-log-requests 9"
    log_info ""
    log_info "4. For troubleshooting, check the installation log:"
    log_info "   ${LOG_FILE}"
    log_info ""
    log_info "🖥️  Accessing the Odin backend locally:"
    log_info "----------------------------------"
    log_info "To forward Odin's deployer service to your local machine:"
    log_info "   kubectl port-forward svc/${RELEASE_NAME}-deployer -n ${NAMESPACE} 8080:80"
    log_info ""

    log_info "⚙️  Configure Odin CLI:"
    log_info "----------------------------------"
    log_info "Run the following command to configure Odin locally:"
    log_info "   odin configure --org-id 0 --backend-address 127.0.0.1:8080 -I -P"
    log_info ""

    log_info "🚀 Creating your first environment:"
    log_info "----------------------------------"
    log_info "A local account has already been onboarded as part of the installation."
    log_info "You can now create an environment using:"
    log_info "   odin create env <env-name> --accounts local"
    log_info ""
    log_success "Installation completed!"
}

#==============================================================================
# MAIN EXECUTION
#==============================================================================

main() {
    # Parse command line arguments
    parse_args "$@"

    # Set up signal handlers
    setup_signal_handlers

    # Start installation
    log_info "Starting Odin Helm chart installation..."
    log_info "Log file: ${LOG_FILE}"

    # Log environment information
    log_environment

    # Run prerequisite checks
    if ! run_prerequisite_checks; then
        log_error "Prerequisite checks failed"
        exit 1
    fi

    # If connected to a Kind cluster, default to the local values file (unless user provided one)
    detect_kind_and_default_values

    # Generate ES256 keys if using local-install-values.yaml
    if ! generate_and_update_keys; then
        log_error "Key generation failed"
        exit 1
    fi

    # Collect and display user configuration
    log_step "Configuring installation settings"
    collect_user_input

    # Install Odin
    log_step "Installing Odin Helm chart"
    if ! install_odin; then
        log_error "Installation failed. Check log file: ${LOG_FILE}"
        exit 1
    fi

    # Setup local development data (only for Kind clusters)
    setup_local_dev_data

    # Install Odin CLI
    log_step "Installing Odin CLI"
    if confirm_action "Do you want to install the Odin CLI binary?"; then
        if ! install_odin_cli; then
            log_warning "Odin CLI installation failed, but continuing..."
        fi
    else
        log_step_skipped "Installing Odin CLI" "user declined"
        log_info "You can download it later from: https://github.com/dream-horizon-org/odin-cli/releases"
    fi

    # Display post-installation information
    post_install_info
}

# Execute main function with all arguments
main "$@"
