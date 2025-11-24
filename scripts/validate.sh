#!/bin/bash

#==============================================================================
# Odin Installation Validation and Prerequisites
#
# This script contains all validation logic and prerequisite installation
# functions for the Odin Helm chart installation.
#==============================================================================

# Setup Docker registry for Kind context if needed
setup_registry_for_context() {
    local context="$1"

    if [[ -n "${context}" && "${context}" == kind-* ]]; then
        log_step "Setting up Docker registry for Kind"
        log_info "Detected Kind cluster, ensuring Docker registry setup..."
        setup_kind_docker_registry || log_warning "Registry setup had issues but continuing"
    else
        log_step_skipped "Setting up Docker registry for Kind" "not a Kind cluster"
    fi
}

# Connect to an existing Kind cluster
connect_to_existing_kind_cluster() {
    local cluster_name="$1"

    log_success "Kind cluster '${cluster_name}' already exists"
    log_info "Using existing Kind cluster"

    # Ensure registry is set up for local Kind cluster
    log_step "Setting up Docker registry for Kind"
    setup_kind_docker_registry || log_warning "Registry setup had issues but continuing"

    log_step "Connecting to Kubernetes cluster"
    # Set kubectl context to local Kind cluster
    kubectl config use-context "kind-${cluster_name}" >/dev/null 2>&1

    # Verify cluster connectivity
    if kubectl cluster-info >/dev/null 2>&1; then
        log_success "Connected to Kind cluster '${cluster_name}'"
        return 0
    else
        log_error "Failed to connect to existing Kind cluster"
        return 1
    fi
}

# Create a new Kind cluster
create_new_kind_cluster() {
    # Create new local Kind cluster (this function handles step 4 and 5)
    if install_kind_cluster; then
        log_success "Kind cluster created and configured successfully"
        return 0
    else
        log_error "Failed to create Kind cluster"
        return 1
    fi
}

# Select and connect to a Kubernetes context
select_and_connect_to_context() {
    log_info "Listing available Kubernetes contexts..."
    local kubecontexts
    kubecontexts=$(kubectl config get-contexts -o name 2>/dev/null)

    if [[ -z "${kubecontexts}" ]]; then
        log_error "No Kubernetes contexts found"
        log_info "Please configure kubectl with a valid context"
        return 1
    fi

    log_info ""
    log_info "Available Kubernetes contexts:"
    echo "${kubecontexts}" | nl -w2 -s'. '
    log_info ""

    read -rp "Enter context name: " selected_context

    # Validate selected Kubernetes cluster
    if ! kubectl config get-contexts "${selected_context}" >/dev/null 2>&1; then
        log_error "Invalid context: ${selected_context}"
        return 1
    fi

    # Switch to selected Kubernetes cluster
    if kubectl config use-context "${selected_context}" >/dev/null 2>&1; then
        log_success "Switched to context: ${selected_context}"

        # Verify connectivity with new Kubernetes cluster
        if kubectl cluster-info >/dev/null 2>&1; then
            log_success "Successfully connected to cluster"

            # Setup registry if Kind cluster
            setup_registry_for_context "${selected_context}"

            log_step "Connecting to Kubernetes cluster"
            return 0
        else
            log_error "Failed to connect to cluster with context: ${selected_context}"
            return 1
        fi
    else
        log_error "Failed to switch to context: ${selected_context}"
        return 1
    fi
}

# Setup Kind cluster flow
setup_kind_cluster_flow() {
    log_info "Setting up local Kind cluster..."

    # Check Docker first (required for Kind)
    log_step "Setting up Docker for Kind cluster"
    if ! check_docker; then
        log_error "Docker is required for Kind cluster installation"
        return 1
    fi

    # Check if Kind is installed
    if command -v kind >/dev/null 2>&1; then
        log_step_skipped "Installing Kind" "already installed"

        # Check if local Kind cluster exists
        local cluster_name="odin-cluster"
        if kind get clusters 2>/dev/null | grep -q "^${cluster_name}$"; then
            connect_to_existing_kind_cluster "${cluster_name}"
            return $?
        else
            create_new_kind_cluster
            return $?
        fi
    else
        log_step "Installing Kind"
        log_info "Kind is not installed"
        log_info "Installing Kind and creating cluster..."

        # Install Kind and create cluster (this function handles step 4 and 5)
        if install_kind_cluster; then
            log_success "Kind installed and cluster created successfully"
            return 0
        else
            log_error "Failed to install Kind and create cluster"
            return 1
        fi
    fi
}

# Connect to existing Kubernetes cluster
connect_to_existing_cluster() {
    log_step_skipped "Setting up Docker for Kind cluster" "using existing cluster"
    log_step_skipped "Installing Kind" "using existing cluster"
    log_info "Using existing Kubernetes cluster..."

    # Test connectivity with existing cluster
    log_debug "Testing kubectl cluster connectivity"
    local cluster_info_output
    cluster_info_output=$(kubectl cluster-info 2>&1)
    local kubectl_exit_code=$?

    log_command_output "kubectl cluster-info" "${cluster_info_output}"

    if [[ ${kubectl_exit_code} -eq 0 ]]; then
        # Connected to existing cluster
        local current_context
        current_context=$(kubectl config current-context 2>/dev/null || true)
        local current_cluster
        current_cluster=$(echo "${cluster_info_output}" | head -n1)

        log_success "Connected to cluster: ${current_cluster}"
        log_info "Current context: ${current_context}"
        log_info ""

        if confirm_action "Use current cluster for Odin installation?"; then
            log_success "Using current cluster: ${current_context}"

            # Setup registry if Kind cluster
            setup_registry_for_context "${current_context}"

            log_step "Connecting to Kubernetes cluster"
            return 0
        else
            # User wants to choose a different context
            select_and_connect_to_context
            return $?
        fi
    else
        # Not connected to any cluster
        log_warning "kubectl is not connected to any Kubernetes cluster"
        log_info "No active kubeconfig found or cluster is unreachable"
        log_info ""

        # List available contexts and let user select
        local kubecontexts
        kubecontexts=$(kubectl config get-contexts -o name 2>/dev/null)

        if [[ -z "${kubecontexts}" ]]; then
            log_error "No Kubernetes contexts found in kubeconfig"
            log_info "Please configure kubectl with a valid context or restart the script to install Kind cluster"
            return 1
        fi

        log_info "Available Kubernetes contexts:"
        echo "${kubecontexts}" | nl -w2 -s'. '
        log_info ""

        read -rp "Enter context name to use: " selected_context

        # Validate selected context
        if ! kubectl config get-contexts "${selected_context}" >/dev/null 2>&1; then
            log_error "Invalid context: ${selected_context}"
            return 1
        fi

        # Switch to selected context
        if kubectl config use-context "${selected_context}" >/dev/null 2>&1; then
            log_success "Switched to context: ${selected_context}"

            # Test connectivity with selected Kubernetes cluster
            log_info "Testing connection to cluster..."
            if kubectl cluster-info >/dev/null 2>&1; then
                log_success "Successfully connected to cluster"

                # Setup registry if Kind cluster
                setup_registry_for_context "${selected_context}"

                log_step "Connecting to Kubernetes cluster"
                return 0
            else
                log_error "Failed to connect to cluster with context: ${selected_context}"
                log_info "Please check if the cluster is running and accessible"
                return 1
            fi
        else
            log_error "Failed to switch to context: ${selected_context}"
            return 1
        fi
    fi
}

# Check kubectl installation and cluster connectivity
check_kubectl() {
    log_step "Checking kubectl installation"

    # Verify kubectl command exists
    if ! check_command "kubectl" "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"; then
        return 1
    fi

    # Ask user preference - Local Kind cluster or Existing cluster
    log_info """
    📚 About Odin on Kind Clusters:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Kind (Kubernetes in Docker) is a lightweight Kubernetes cluster
    that runs entirely in Docker containers. It's perfect for:

     • Local development and testing of Odin
     • Experimenting with Odin features before production deployment
     • Learning Odin in an isolated, controlled environment
      • Automatic setup with local demo accounts and service accounts

    Alternatively, you can connect to an existing Kubernetes cluster
    for production or shared development environments.
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    """
    if confirm_action "Would you like to install Odin on a local Kind cluster?
This will:
- Install Kind (if not already installed)
- Create or use existing local Kubernetes cluster named 'odin-cluster'
- Configure kubectl to use the cluster
- Setup local Docker registry

Install on local Kind cluster?"; then
        setup_kind_cluster_flow
        return $?
    else
        connect_to_existing_cluster
        return $?
    fi
}

# Install Helm if not present
install_helm() {
    log_info "Installing Helm using official installation script..."

    local helm_install_script="/tmp/get_helm.sh"

    if ! curl -fsSL -o "${helm_install_script}" https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3; then
        log_error "Failed to download Helm installation script"
        return 1
    fi

    chmod +x "${helm_install_script}"

    if bash "${helm_install_script}"; then
        rm -f "${helm_install_script}"
        log_success "Helm installed successfully"
        return 0
    else
        rm -f "${helm_install_script}"
        log_error "Failed to install Helm using official script"
        return 1
    fi
}

# Check Helm installation
check_helm() {
    log_step "Checking Helm installation"

    # Check if Helm is already installed
    if command -v helm >/dev/null 2>&1; then
        log_step_skipped "Installing Helm" "already installed"
    else
        log_step "Installing Helm"
        log_info "Helm is not installed"

        if ! install_helm; then
            log_error "Failed to install Helm"
            log_info "Please install Helm manually: https://helm.sh/docs/intro/install/"
            return 1
        fi
    fi

    # Verify Helm installation
    if ! command -v helm >/dev/null 2>&1; then
        log_error "Helm installation verification failed"
        return 1
    fi

    # Get Helm version
    local helm_version_output
    helm_version_output=$(helm version --short 2>&1)
    log_command_output "helm version --short" "${helm_version_output}"
    log_success "Helm version: ${helm_version_output}"

    # List current Helm releases for debugging
    local helm_list_output
    helm_list_output=$(helm list --all-namespaces 2>&1)
    log_command_output "helm list --all-namespaces" "${helm_list_output}"

    return 0
}

# Check Docker installation (required for Kind)
check_docker() {
    log_info "Checking Docker..."

    if ! check_command "docker" "Please install Docker: https://docs.docker.com/get-docker/"; then
        return 1
    fi

    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        log_info "Please start Docker and try again"
        exit 1
    fi

    log_success "Docker is running"
    return 0
}

# Check and setup grpcurl
check_grpcurl() {
    local required_version="1.8.7"
    local current_version=""
    local need_download=false

    log_step "Checking grpcurl"

    # Check if grpcurl exists
    if command -v grpcurl >/dev/null 2>&1; then
        # Extract version from grpcurl
        current_version=$(grpcurl -version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

        if [[ "${current_version}" == "${required_version}" ]]; then
            log_success "grpcurl ${required_version} found"
            # Create symlink to system grpcurl
            ln -sf "$(command -v grpcurl)" ./grpcurl
            log_success "Created symlink ./grpcurl"
            return 0
        else
            log_info "Found grpcurl ${current_version}, but need ${required_version}"
            need_download=true
        fi
    else
        log_info "grpcurl not found"
        need_download=true
    fi

    if [[ "${need_download}" == true ]]; then
        log_info "Downloading grpcurl ${required_version}..."

        # Detect platform and architecture
        local os=""
        local arch=""

        case "$(uname -s)" in
            Darwin*) os="osx" ;;
            Linux*)  os="linux" ;;
            *)
                log_error "Unsupported operating system: $(uname -s)"
                return 1
                ;;
        esac

        case "$(uname -m)" in
            x86_64)  arch="x86_64" ;;
            arm64|aarch64) arch="arm64" ;;
            *)
                log_error "Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        local filename="grpcurl_${required_version}_${os}_${arch}.tar.gz"
        local download_url="https://github.com/fullstorydev/grpcurl/releases/download/v${required_version}/${filename}"

        log_debug "Platform: ${os}_${arch}"
        log_debug "URL: ${download_url}"

        # Download and extract
        if ! curl -fsSL "${download_url}" -o "/tmp/${filename}"; then
            log_error "Failed to download grpcurl"
            return 1
        fi

        if ! tar -xzf "/tmp/${filename}" -C . grpcurl 2>/dev/null; then
            log_error "Failed to extract grpcurl"
            rm -f "/tmp/${filename}"
            return 1
        fi

        chmod +x ./grpcurl
        rm -f "/tmp/${filename}"

        log_success "grpcurl ${required_version} downloaded to ./grpcurl"
    fi

    return 0
}

# Check Percona MySQL Server Operator
check_percona_operator() {
    log_info "Checking Percona MySQL Server Operator..."

    local required_version="0.11.0"
    local installed_version=""

    # Check if Percona operator is installed using helm list
    if command -v jq >/dev/null 2>&1; then
        # Use jq for robust JSON parsing
        installed_version=$(helm list --all-namespaces -o json 2>/dev/null | jq -r '.[] | select(.chart | contains("ps-operator")) | .chart' | sed 's/ps-operator-//' | head -n1)
    else
        # Fallback to grep/awk
        installed_version=$(helm list --all-namespaces 2>/dev/null | grep "ps-operator" | awk '{print $10}' | sed 's/ps-operator-//' | head -n1)
    fi

    if [[ -n "${installed_version}" && "${installed_version}" != "null" ]]; then
        log_info "Percona MySQL Server Operator is installed (version: ${installed_version})"

        # Check version compatibility
        if [[ "${installed_version}" == "${required_version}" ]]; then
            log_success "Percona operator version ${required_version} is already installed"

            # Verify operator pods are running
            local operator_pods
            operator_pods=$(kubectl get pods --all-namespaces -l app.kubernetes.io/name=ps-operator --no-headers 2>/dev/null | wc -l)
            if [[ ${operator_pods} -gt 0 ]]; then
                log_success "Percona operator pods are running"
            else
                log_warning "Percona operator is installed but pods may not be running"
            fi

            return 0
        else
            log_warning "Installed version (${installed_version}) differs from required version (${required_version})"

            if confirm_action "Would you like to upgrade Percona MySQL Server Operator to version ${required_version}?"; then
                install_percona_operator "upgrade" "${required_version}"
                return $?
            else
                log_warning "Continuing with existing Percona operator version"
                return 0
            fi
        fi
    else
        log_warning "Percona MySQL Server Operator is not installed"
        log_info "Installing Percona MySQL Server Operator..."

        install_percona_operator "install" "${required_version}"
    fi
}

# Install Percona MySQL Server Operator
install_percona_operator() {
    local action="$1"  # "install" or "upgrade"
    local version="$2"

    local action_display="${action}"
    local action_past="${action}ed"

    if [[ "${action}" == "install" ]]; then
        action_display="Installing"
        action_past="installed"
    elif [[ "${action}" == "upgrade" ]]; then
        action_display="Upgrading"
        action_past="upgraded"
    fi

    log_info "${action_display} Percona MySQL Server Operator version ${version}..."

    # Add Percona Helm repository
    log_debug "Adding Percona Helm repository"
    if ! helm repo add percona https://percona.github.io/percona-helm-charts/ 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to add Percona Helm repository"
        return 1
    fi

    # Update Helm repositories
    log_debug "Updating Helm repositories"
    if ! helm repo update 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to update Helm repositories"
        return 1
    fi

    # Install or upgrade the operator
    local helm_cmd="helm"
    if [[ "${action}" == "upgrade" ]]; then
        helm_cmd="helm upgrade --install"
    else
        helm_cmd="helm install"
    fi

    log_debug "Running: ${helm_cmd} percona-operator percona/ps-operator --version ${version} --create-namespace --namespace ${NAMESPACE}"
    if ! ${helm_cmd} percona-operator percona/ps-operator --version "${version}" --create-namespace --namespace "${NAMESPACE}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to ${action} Percona MySQL Server Operator"
        return 1
    fi

    log_success "Percona MySQL Server Operator ${action_past} successfully"

    # Wait for operator pods to be ready
    log_info "Waiting for Percona operator pods to be ready..."
    local max_wait=300  # 5 minutes
    local wait_interval=10
    local elapsed=0

    while [[ ${elapsed} -lt ${max_wait} ]]; do
        local ready_pods
        ready_pods=$(kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=ps-operator --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)

        if [[ ${ready_pods} -gt 0 ]]; then
            log_success "Percona operator pods are ready"
            return 0
        fi

        log_debug "Waiting for Percona operator pods... (${elapsed}s/${max_wait}s)"
        sleep ${wait_interval}
        elapsed=$((elapsed + wait_interval))
    done

    log_warning "Percona operator pods may not be fully ready, but installation completed"
    return 0
}

# Check KEDA installation
check_keda() {
    log_info "Checking KEDA (Kubernetes Event-driven Autoscaling)..."

    local keda_found=false
    local keda_namespace=""

    # Check if KEDA is installed using helm list
    if command -v jq >/dev/null 2>&1; then
        # Use jq for robust JSON parsing
        local keda_info
        keda_info=$(helm list --all-namespaces -o json 2>/dev/null | jq -r '.[] | select(.chart | contains("keda")) | "\(.namespace):\(.chart)"' | head -n1)
        if [[ -n "${keda_info}" && "${keda_info}" != "null" ]]; then
            keda_found=true
            keda_namespace=$(echo "${keda_info}" | cut -d':' -f1)
        fi
    else
        # Fallback to grep/awk
        local keda_line
        keda_line=$(helm list --all-namespaces 2>/dev/null | grep "keda" | head -n1)
        if [[ -n "${keda_line}" ]]; then
            keda_found=true
            keda_namespace=$(echo "${keda_line}" | awk '{print $2}')
        fi
    fi

    if [[ "${keda_found}" == "true" ]]; then
        log_success "KEDA is already installed"
        log_debug "KEDA namespace: ${keda_namespace}"

        # Verify KEDA CRDs exist
        local scaledjob_crd
        local triggerauth_crd
        scaledjob_crd=$(kubectl get crd scaledjobs.keda.sh --no-headers 2>/dev/null | wc -l)
        triggerauth_crd=$(kubectl get crd triggerauthentications.keda.sh --no-headers 2>/dev/null | wc -l)

        if [[ ${scaledjob_crd} -gt 0 && ${triggerauth_crd} -gt 0 ]]; then
            log_success "KEDA CRDs are available"
        else
            log_warning "KEDA CRDs may not be fully available"
        fi

        # Check KEDA operator pods
        local keda_pods
        keda_pods=$(kubectl get pods -n "${keda_namespace}" -l app.kubernetes.io/name=keda-operator --no-headers 2>/dev/null | wc -l)
        if [[ ${keda_pods} -gt 0 ]]; then
            log_success "KEDA operator pods are running"
        else
            log_warning "KEDA is installed but operator may not be running or running in a different namespace"
        fi

        return 0
    else
        log_warning "KEDA is not installed"
        log_info ""
        log_info "KEDA (Kubernetes Event-driven Autoscaling) is required for the orchestrator component."
        log_info "It enables automatic scaling based on external metrics and events."
        log_info ""
        log_info "Source: https://keda.sh/"
        log_info "Installing KEDA..."
        install_keda
    fi
}

# Ensure local Docker registry is running
ensure_local_docker_registry() {
    local reg_name="kind-registry"
    local reg_port="50000"

    log_info "Ensuring local Docker registry '${reg_name}' on port ${reg_port}..."

    local running
    running=$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)
    if [ "${running}" != "true" ]; then
        log_debug "Starting registry container '${reg_name}'"
        local docker_output
        docker_output=$(docker run -d --restart=always -p "0.0.0.0:${reg_port}:5000" --network kind --name "${reg_name}" registry:2 2>&1)
        local exit_code=$?

        if [ ${exit_code} -ne 0 ]; then
            log_error "Failed to start Docker registry container '${reg_name}' on port ${reg_port}"
            log_error "Docker error: ${docker_output}"
            return 1
        fi

        log_success "Local registry '${reg_name}' started"
    else
        log_success "Local registry '${reg_name}' already running"
    fi
}

# Install KEDA
install_keda() {
    log_info "Installing KEDA (Kubernetes Event-driven Autoscaling)..."

    # Add KEDA Helm repository
    log_debug "Adding KEDA Helm repository"
    if ! helm repo add kedacore https://kedacore.github.io/charts 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to add KEDA Helm repository"
        return 1
    fi

    # Update Helm repositories
    log_debug "Updating Helm repositories"
    if ! helm repo update 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to update Helm repositories"
        return 1
    fi

    # Install KEDA
    log_debug "Installing KEDA using Helm"
    if ! helm install keda kedacore/keda --create-namespace --namespace keda --version 2.18.1 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to install KEDA"
        return 1
    fi

    log_success "KEDA installed successfully"

    # Wait for KEDA CRDs to be available
    log_info "Waiting for KEDA CRDs to be ready..."
    local max_wait=180  # 3 minutes
    local wait_interval=10
    local elapsed=0

    while [[ ${elapsed} -lt ${max_wait} ]]; do
        local scaledjob_crd
        local triggerauth_crd
        scaledjob_crd=$(kubectl get crd scaledjobs.keda.sh --no-headers 2>/dev/null | wc -l)
        triggerauth_crd=$(kubectl get crd triggerauthentications.keda.sh --no-headers 2>/dev/null | wc -l)

        if [[ ${scaledjob_crd} -gt 0 && ${triggerauth_crd} -gt 0 ]]; then
            log_success "KEDA CRDs are ready"
            break
        fi

        log_debug "Waiting for KEDA CRDs... (${elapsed}s/${max_wait}s)"
        sleep ${wait_interval}
        elapsed=$((elapsed + wait_interval))
    done

    # Wait for KEDA operator pods to be ready
    log_info "Waiting for KEDA operator pods to be ready..."
    max_wait=300  # 5 minutes
    elapsed=0

    while [[ ${elapsed} -lt ${max_wait} ]]; do
        local ready_pods
        ready_pods=$(kubectl get pods -n keda -l app.kubernetes.io/name=keda-operator --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)

        if [[ ${ready_pods} -gt 0 ]]; then
            log_success "KEDA operator pods are ready"
            return 0
        fi

        log_debug "Waiting for KEDA operator pods... (${elapsed}s/${max_wait}s)"
        sleep ${wait_interval}
        elapsed=$((elapsed + wait_interval))
    done

    log_warning "KEDA operator pods may not be fully ready, but installation completed"
    return 0
}

#==============================================================================
# ODIN CLI INSTALLATION
#==============================================================================

# Source the CLI installation script to make install_odin_cli function available
# Both scripts are in the same directory
_validate_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_validate_script_dir}/install-cli.sh" ]]; then
    # shellcheck disable=SC1091
    source "${_validate_script_dir}/install-cli.sh"
fi
unset _validate_script_dir

#==============================================================================
# KIND CLUSTER INSTALLATION
#==============================================================================

# Configure Docker Desktop memory settings (macOS only)
# Sets memory to 80% of system RAM
configure_docker_desktop_memory() {
    # Only run on macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        return 0
    fi

    local settings_dir="${HOME}/Library/Group Containers/group.com.docker"
    local settings_file=""

    # Check for settings-store.json first, then settings.json
    if [[ -f "${settings_dir}/settings-store.json" ]]; then
        settings_file="${settings_dir}/settings-store.json"
    elif [[ -f "${settings_dir}/settings.json" ]]; then
        settings_file="${settings_dir}/settings.json"
    else
        log_debug "Docker Desktop settings file not found in ${settings_dir}"
        return 0
    fi

    # Detect which key format is used in the file
    local memory_key=""
    if grep -q "\"MemoryMiB\"" "${settings_file}" 2>/dev/null; then
        memory_key="MemoryMiB"
    elif grep -q "\"memoryMiB\"" "${settings_file}" 2>/dev/null; then
        memory_key="memoryMiB"
    else
        log_debug "No memory key found in ${settings_file}"
        return 0
    fi

    # Detect CPU key format
    local cpu_key=""
    if grep -q "\"Cpus\"" "${settings_file}" 2>/dev/null; then
        cpu_key="Cpus"
    elif grep -q "\"cpus\"" "${settings_file}" 2>/dev/null; then
        cpu_key="cpus"
    elif grep -q "\"CPUs\"" "${settings_file}" 2>/dev/null; then
        cpu_key="CPUs"
    elif grep -q "\"CpuCount\"" "${settings_file}" 2>/dev/null; then
        cpu_key="CpuCount"
    elif grep -q "\"cpuCount\"" "${settings_file}" 2>/dev/null; then
        cpu_key="cpuCount"
    fi

    log_info "Configuring Docker Desktop resource settings..."
    log_debug "Using settings file: ${settings_file}"
    log_debug "Detected memory key: ${memory_key}"
    if [[ -n "${cpu_key}" ]]; then
        log_debug "Detected CPU key: ${cpu_key}"
    fi

    # Get total system memory in MiB
    local total_mem_mib mem_80
    total_mem_mib=$(($(sysctl -n hw.memsize) / 1024 / 1024))
    mem_80=$((total_mem_mib * 80 / 100))

    # Get available CPU count and calculate 80% (rounded to nearest integer)
    local total_cpus cpu_80
    total_cpus=$(sysctl -n hw.ncpu)
    # Calculate 80% and round to nearest integer: (cpu * 80 + 50) / 100
    cpu_80=$(((total_cpus * 80 + 50) / 100))

    log_info "System RAM: ${total_mem_mib} MiB"
    log_info "Recommended Docker Desktop memory: ${mem_80} MiB (80% of system RAM)"
    if [[ -n "${cpu_key}" ]]; then
        log_info "Available CPUs: ${total_cpus}"
        log_info "Recommended Docker Desktop CPUs: ${cpu_80} (80% of available CPUs)"
    fi

    local prompt_msg="We recommend setting Docker Desktop resources for optimal performance:
  - Memory: ${mem_80} MiB (80% of system RAM)"
    if [[ -n "${cpu_key}" ]]; then
        prompt_msg="${prompt_msg}
  - CPUs: ${cpu_80} (80% of available CPUs)"
    fi
    prompt_msg="${prompt_msg}
Would you like to proceed?"

    # Prompt user before modifying settings
    if ! confirm_action "${prompt_msg}"; then
        log_info "Skipping Docker Desktop resource configuration"
        return 0
    fi

    # Backup settings file
    if cp "${settings_file}" "${settings_file}.bak" 2>/dev/null; then
        log_debug "Backup created at: ${settings_file}.bak"
    else
        log_warning "Failed to create backup of settings file"
    fi

    local update_success=true

    # Update memory key in settings file (handle both MemoryMiB and memoryMiB)
    if sed -i '' "s/\"${memory_key}\": *[0-9][0-9]*/\"${memory_key}\": ${mem_80}/" "${settings_file}" 2>/dev/null; then
        log_success "Updated ${memory_key} in Docker Desktop settings to ${mem_80} MiB"
    else
        log_warning "Failed to update ${memory_key} in Docker Desktop settings"
        update_success=false
    fi

    # Update CPU key in settings file if detected
    if [[ -n "${cpu_key}" ]]; then
        if sed -i '' "s/\"${cpu_key}\": *[0-9][0-9]*/\"${cpu_key}\": ${cpu_80}/" "${settings_file}" 2>/dev/null; then
            log_success "Updated ${cpu_key} in Docker Desktop settings to ${cpu_80}"
        else
            log_warning "Failed to update ${cpu_key} in Docker Desktop settings"
            update_success=false
        fi
    fi

    if [[ "${update_success}" == "true" ]]; then
        return 0
    else
        log_warning "Update failed. Restoring backup..."
        # Restore backup if update failed
        if [[ -f "${settings_file}.bak" ]]; then
            mv "${settings_file}.bak" "${settings_file}" 2>/dev/null
        fi
        return 1
    fi
}

# Enable insecure registry in Docker daemon configuration
# Adds host.docker.internal:50000 to Docker daemon.json insecure-registries
enable_insecure_registry() {
    local insecure_registry="host.docker.internal:50000"

    # Determine config file and restart method
    local config_file
    local restart_method
    if [ -f "${HOME}/.docker/daemon.json" ]; then
        config_file="${HOME}/.docker/daemon.json"
        restart_method="MANUAL"  # Docker Desktop
    elif [ -f "/etc/docker/daemon.json" ]; then
        config_file="/etc/docker/daemon.json"
        restart_method="SYSTEMCTL"
    else
        config_file="/etc/docker/daemon.json"
        restart_method="SYSTEMCTL"
    fi

    log_info "Configuring Docker insecure registries..."
    log_debug "Target Docker daemon config: ${config_file}"

    # Ensure jq is available
    if ! check_command "jq" "Please install jq (e.g., 'brew install jq' or 'sudo apt install jq')."; then
        return 1
    fi

    # Read existing JSON or use empty object
    local json_content
    if [ -f "${config_file}" ]; then
        json_content=$(cat "${config_file}")
    else
        json_content="{}"
    fi

    # Update JSON (ensure array type and avoid nested empty array entries)
    local updated_json
    updated_json=$(echo "${json_content}" | jq \
        --arg reg "${insecure_registry}" \
        '( .["insecure-registries"] |= ( (if . == null then [] elif (type=="array") then . else [.] end) + [$reg] | unique ) )'
    )

    # Write back
    if [ "${config_file}" = "/etc/docker/daemon.json" ]; then
        echo "${updated_json}" | sudo tee "${config_file}" > /dev/null
    else
        echo "${updated_json}" > "${config_file}"
    fi

    log_success "Added ${insecure_registry} to ${config_file}"

    # Configure Docker Desktop memory settings before restart (macOS only)
    if [ "${restart_method}" = "MANUAL" ]; then
        if ! configure_docker_desktop_memory; then
            log_info "Memory configuration will be applied when you quit Docker Desktop"
        fi
    fi

    # Restart instructions
    if [ "${restart_method}" = "SYSTEMCTL" ]; then
        log_info "Restarting Docker daemon via systemctl..."
        if sudo systemctl restart docker; then
            log_success "Docker daemon restarted successfully"
        else
            log_warning "Docker restart failed. Check 'journalctl -xe' or restart manually."
        fi
    else
        log_warning "=========================================================="
        log_warning "  ACTION REQUIRED: Docker Desktop Restart Needed"
        log_warning "=========================================================="
        log_warning "Docker configuration has been updated at:"
        log_warning "  ${config_file}"
        log_warning ""
        log_warning "Please restart Docker Desktop now for changes to take effect:"
        log_warning "  1. Quit Docker Desktop"
        log_warning "  2. Launch Docker Desktop"
        log_warning "=========================================================="

        if [[ -t 0 ]]; then
            log_info ""
            read -rp "Press Enter after restarting Docker Desktop to continue..."
            log_info ""
        fi
    fi

    return 0
}

# Setup Docker registry for Kind cluster
# This function ensures the local Docker registry is created, enabled, and connected
setup_kind_docker_registry() {
    log_info "Setting up Docker registry for Kind cluster..."

    # Check if Docker is available
    if ! check_docker; then
        log_warning "Docker not available, skipping registry setup"
        return 1
    fi

    # Enable insecure registry in Docker daemon
    if ! enable_insecure_registry; then
        log_warning "Failed to enable insecure registry"
        return 1
    fi

    # Ensure local Docker registry container exists and is running
    if ! ensure_local_docker_registry; then
        log_warning "Failed to ensure local registry"
        return 1
    fi

    log_success "Docker registry setup completed for Kind cluster"
    return 0
}

# Install Kind cluster
install_kind_cluster() {
    # This function is called after step 3 (Install Kind) is already logged
    # It handles registry setup (step 4) and cluster creation (step 5)

    # Registry must be set up before cluster creation (cluster config references it)
    log_step "Setting up Docker registry for Kind"
    setup_kind_docker_registry || log_warning "Registry setup had issues but continuing with installation"

    log_step "Creating Kubernetes cluster"
    log_info "Creating local Kubernetes cluster using Kind..."

    # Check if Kind is installed
    if ! command -v kind >/dev/null 2>&1; then
        log_info "Installing Kind..."

        # Detect OS and install Kind
        local os_type
        os_type=$(uname -s | tr '[:upper:]' '[:lower:]')

        case "${os_type}" in
            darwin)
                download_with_retry https://kind.sigs.k8s.io/dl/v0.30.0/kind-darwin-amd64 ./kind 5 2 || return 1
                chmod +x ./kind
                sudo mv ./kind /usr/local/bin/kind
                ;;
            linux)
                download_with_retry https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64 ./kind 5 2 || return 1
                chmod +x ./kind
                sudo mv ./kind /usr/local/bin/kind
                ;;
            *)
                log_error "Unsupported operating system: ${os_type}"
                log_info "Please install Kind manually: https://kind.sigs.k8s.io/docs/user/quick-start/"
                exit 1
                ;;
        esac

        # Verify Kind installation
        if ! command -v kind >/dev/null 2>&1; then
            log_error "Failed to install Kind"
            exit 1
        fi

        log_success "Kind installed successfully"
    else
        log_success "Kind is already installed"
    fi

    local cluster_name="odin-cluster"

    # Check if the cluster already exists
    if kind get clusters | grep -q "${cluster_name}"; then
        log_success "Kind cluster '${cluster_name}' already exists. Skipping creation."
    else
        log_info "Creating Kind cluster '${cluster_name}'..."
        # Create Kind cluster configuration for 3 nodes
        local kind_config="/tmp/kind-config.yaml"
        cat > "${kind_config}" << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: /var/run/docker.sock
    containerPath: /var/run/docker.sock
  - hostPath: ${HOME}
    containerPath: /local
  - hostPath: /tmp
    containerPath: /mnt/tmp
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."host.docker.internal:50000"]
    endpoint = ["http://kind-registry:5000"]
EOF

        log_debug "Kind configuration created at ${kind_config}"

        if ! kind create cluster --name "${cluster_name}" --config "${kind_config}" 2>&1 | tee -a "${LOG_FILE}"; then
            log_error "Failed to create Kind cluster"
            exit 1
        fi

        # Clean up config file
        rm -f "${kind_config}"
    fi

    # Set kubectl context
    log_info "Setting kubectl context to Kind cluster..."
    if ! kubectl cluster-info --context "kind-${cluster_name}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Failed to set kubectl context"
        return 1
    fi

    # Wait for nodes to be ready
    log_info "Waiting for cluster nodes to be ready (300s timeout)..."
    if ! kubectl wait --for=condition=Ready nodes --all --timeout=300s 2>&1 | tee -a "${LOG_FILE}"; then
        log_warning "Nodes may not be fully ready after 300s, but cluster creation/check completed."
    fi

    log_success "Kind cluster '${cluster_name}' is ready."
    log_info "kubectl context set to: kind-${cluster_name}"
    log_info "Your home directory is mounted at /local in the cluster."

    return 0
}

#==============================================================================
# MAIN VALIDATION RUNNER
#==============================================================================

# Run all prerequisite checks
run_prerequisite_checks() {
    log_info "Running prerequisite checks..."

    local checks_failed=false

    # Always check kubectl and helm
    if ! check_kubectl; then
        checks_failed=true
    fi

    if ! check_helm; then
        checks_failed=true
    fi

    # Check grpcurl (needed for local dev setup)
    if ! check_grpcurl; then
        checks_failed=true
    fi

    # If internal MySQL is enabled, automatically install/upgrade Percona operator in target namespace
    if is_internal_mysql_enabled "${VALUES_FILE}"; then
        log_step "Installing Percona MySQL Operator"
        log_info "Internal MySQL is enabled; ensuring Percona MySQL Operator is installed in namespace '${NAMESPACE}'"
        if ! install_percona_operator "upgrade" "0.12.0"; then
            checks_failed=true
        fi
    else
        log_step_skipped "Installing Percona MySQL Operator" "external MySQL configured"
    fi

    # Check KEDA only if orchestrator is enabled
    if is_orchestrator_enabled "${VALUES_FILE}"; then
        log_step "Installing KEDA"
        if ! check_keda; then
            checks_failed=true
        fi
    else
        log_step_skipped "Installing KEDA" "orchestrator disabled"
    fi

    if [[ "${checks_failed}" == "true" ]]; then
        log_error "One or more prerequisite checks failed"
        return 1
    fi

    log_success "All prerequisite checks passed"
    return 0
}
