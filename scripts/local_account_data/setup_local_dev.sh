#!/bin/bash

# Consolidated Local Development Setup Script for Odin Account Manager
# This script creates local dev account and associated provider service accounts

GRPC_HOST="localhost:8080"
ORG_HEADER="orgId: 0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              LOCAL DEVELOPMENT SETUP                        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get the script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"

# Function to check if server is running
check_server() {
    echo -e "${YELLOW}🔍 Checking if Odin Account Manager server is running...${NC}"
    if ./grpcurl -plaintext "${GRPC_HOST}" list > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server is running and accessible${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not accessible at ${GRPC_HOST}${NC}"
        echo -e "${RED}   Please ensure the Odin Account Manager server is running${NC}"
        return 1
    fi
}

# Function to execute grpcurl with error handling
execute_grpc_call() {
    local description="$1"
    local command="$2"

    echo -e "${BLUE}🔄 ${description}${NC}"
    echo "Executing: ${command}"
    echo ""

    # Execute the command
    if eval "${command}"; then
        echo -e "${GREEN}✅ ${description} - SUCCESS${NC}"
    else
        echo -e "${RED}❌ ${description} - FAILED${NC}"
        return 1
    fi
    echo "----------------------------------------"
    echo ""
    return 0
}

# Main setup function
main() {
    # Check if server is running
    if ! check_server; then
        exit 1
    fi

    echo ""
    echo -e "${BLUE}📝 This script will create:${NC}"
    echo -e "   • Local dev provider account (with dsjfrog linked account)"
    echo -e "   • KIND service account for local Kubernetes"
    echo -e "   • DockerRegistry service account for local Docker registry"
    echo ""

    # Load local dev account data
    LOCAL_DATA=$(cat "${DATA_DIR}/provider_accounts/local_dev_account.json")

    execute_grpc_call "Create Local Dev Account (Default)" \
    "./grpcurl -plaintext -H \"${ORG_HEADER}\" -d '{\"name\": \"local\", \"provider_name\": \"local\", \"provider_data\": ${LOCAL_DATA}, \"is_default\": true}' ${GRPC_HOST} dream11.oam.provideraccount.v1.ProviderAccountService/CreateProviderAccount" || exit 1

    # Load KIND service account data
    KIND_DATA=$(cat "${DATA_DIR}/provider_service_accounts/kind_service_account.json")

    execute_grpc_call "Create KIND Service Account (local/dev)" \
    "./grpcurl -plaintext -H \"${ORG_HEADER}\" -d '{\"provider_service_name\": \"KIND\", \"provider_account_name\": \"local\", \"provider_service_data\": ${KIND_DATA}, \"is_active\": true}' ${GRPC_HOST} dream11.oam.psa.v1.ProviderServiceAccountService/CreateProviderServiceAccount" || exit 1

    # Load Docker local service account data
    DOCKER_LOCAL_DATA=$(cat "${DATA_DIR}/provider_service_accounts/docker_local_service_account.json")

    execute_grpc_call "Create DockerRegistry Service Account (local/dev)" \
    "./grpcurl -plaintext -H \"${ORG_HEADER}\" -d '{\"provider_service_name\": \"DockerRegistry\", \"provider_account_name\": \"local\", \"provider_service_data\": ${DOCKER_LOCAL_DATA}, \"is_active\": true}' ${GRPC_HOST} dream11.oam.psa.v1.ProviderServiceAccountService/CreateProviderServiceAccount" || exit 1

    echo ""
    echo -e "${GREEN}🎉 Local Development Setup Completed Successfully!${NC}"
    echo ""
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Setup interrupted by user${NC}"; exit 1' INT

# Check dependencies
if [[ ! -x "./grpcurl" ]]; then
    echo -e "${RED}❌ ./grpcurl is not available${NC}"
    echo -e "${RED}   Please ensure install.sh was run to setup grpcurl${NC}"
    exit 1
fi

# Run main function
main "$@"
