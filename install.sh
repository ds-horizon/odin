#!/bin/bash

#==============================================================================
# Odin Installation Script
#==============================================================================

set -euo pipefail

# Configuration
readonly REPO_URL="https://github.com/dream-horizon-org/odin.git"
readonly BRANCH="${BRANCH:-master}"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Detect if running from a cloned repository
is_local_install() {
    # Check if scripts/main.sh exists (indicating we're in a cloned repo)
    [[ -f "${BASH_SOURCE[0]%/*}/scripts/main.sh" ]]
}

# Bootstrap installation (when run via curl)
bootstrap_install() {
    local temp_dir=""
    temp_dir=$(mktemp -d)

    # Trap for cleanup
    trap 'if [[ -n "${temp_dir:-}" ]] && [[ -d "${temp_dir}" ]]; then rm -rf "${temp_dir}"; fi' EXIT INT TERM

    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║             Odin Helm Chart Installation                  ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""

    # Check prerequisites
    echo -e "${BLUE}Checking prerequisites...${NC}"
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}✗ Git is required but not installed${NC}"
        echo "  Install git: https://git-scm.com/downloads"
        exit 1
    fi

    echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
    echo ""

    # Clone repository
    echo -e "${BLUE}Cloning Odin repository...${NC}"
    echo "  Repository: ${REPO_URL}"
    echo "  Branch: ${BRANCH}"
    echo ""

    if ! git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}" "${temp_dir}/odin" >/dev/null 2>&1; then
        echo -e "${RED}✗ Failed to clone repository${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Repository cloned successfully${NC}"
    # Run local installation from cloned repo
    cd "${temp_dir}/odin"

    if ./install.sh "$@"; then
        echo -e "${GREEN}✓ Installation completed successfully!${NC}"
        return 0
    else
        echo -e "${RED}✗ Installation failed${NC}"
        return 1
    fi
}

# Local installation (when repo is already cloned)
local_install() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local main_script="${script_dir}/scripts/main.sh"

    # Check if main script exists
    if [[ ! -f "${main_script}" ]]; then
        echo -e "${RED}ERROR: Main installation script not found: ${main_script}${NC}"
        echo "Please ensure the 'scripts' directory and its contents are present."
        exit 1
    fi

    # Execute main installation script with all arguments
    exec "${main_script}" "$@"
}

# Main execution
main() {
    if is_local_install; then
        # Running from cloned repository
        local_install "$@"
    else
        # Running via curl, need to bootstrap
        bootstrap_install "$@"
    fi
}

# Execute
main "$@"
