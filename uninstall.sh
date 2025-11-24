#!/bin/bash

set -euo pipefail

# Simple Odin Helm chart uninstaller
# - Uninstalls the Odin Helm release from the specified or detected namespace
# - Does NOT remove prerequisites (KEDA, Percona operator, Redis, etc.)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/odin-uninstall-$(date +%Y%m%d-%H%M%S).log"
export LOG_FILE

# Defaults
DEFAULT_RELEASE="odin"
DEFAULT_NAMESPACE="odin"

RELEASE_NAME=""
NAMESPACE=""
ASSUME_YES=false
export DEBUG=false

# Source shared logging and helpers
if [[ -f "${SCRIPT_DIR}/scripts/utils.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/scripts/utils.sh"
else
  echo "[ERROR] utils.sh not found at ${SCRIPT_DIR}/scripts/utils.sh" >&2
  exit 1
fi

show_help() {
  cat << EOF
Usage: $(basename "$0") [options]

Options:
  -r, --release NAME     Helm release name (default: autodetect or '${DEFAULT_RELEASE}')
  -n, --namespace NAME   Kubernetes namespace (default: autodetect or '${DEFAULT_NAMESPACE}')
  -y, --yes              Do not prompt for confirmation
      --debug            Enable debug output
  -h, --help             Show this help

Behavior:
  If release/namespace are not provided, the script tries to detect the Odin Helm
  release by scanning all namespaces. If multiple matches are found, flags are required.
EOF
}

# Note: use log_info/log_warning/log_error/log_debug from utils.sh

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r|--release)
        RELEASE_NAME="$2"; shift 2;;
      -n|--namespace)
        NAMESPACE="$2"; shift 2;;
      -y|--yes)
        ASSUME_YES=true; shift;;
      --debug)
        DEBUG=true; shift;;
      -h|--help)
        show_help; exit 0;;
      *)
        log_error "Unknown option: $1"; show_help; exit 1;;
    esac
  done
}

uninstall_release() {
  log_info "Preparing to uninstall release: ${RELEASE_NAME} (namespace: ${NAMESPACE})"

  # If the specified release does not exist, exit gracefully
  if ! helm status "${RELEASE_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
    log_info "Release '${RELEASE_NAME}' not found in namespace '${NAMESPACE}'. Nothing to uninstall."
    exit 0
  fi

  if [[ "${ASSUME_YES}" != "true" ]]; then
    if ! confirm_action "Proceed to uninstall '${RELEASE_NAME}' from namespace '${NAMESPACE}'?"; then
      log_info "Aborted by user."
      exit 0
    fi
  fi

  log_info "Running: helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}"
  if helm uninstall "${RELEASE_NAME}" -n "${NAMESPACE}"; then
    log_info "Uninstall command executed. Verifying resources..."
  else
    log_error "Helm uninstall failed for release '${RELEASE_NAME}' in namespace '${NAMESPACE}'"
    exit 1
  fi

  # Optional: quick check if any release with same name remains
  if helm status "${RELEASE_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
    log_warn "Release '${RELEASE_NAME}' may still exist. Check manually: helm list -n ${NAMESPACE}"
  else
    log_info "Release '${RELEASE_NAME}' removed from namespace '${NAMESPACE}'."
  fi
}

main() {
  parse_args "$@"

  # If values not provided, use sensible defaults instead of autodetect
  RELEASE_NAME="${RELEASE_NAME:-${DEFAULT_RELEASE}}"
  NAMESPACE="${NAMESPACE:-${DEFAULT_NAMESPACE}}"

  uninstall_release
}

main "$@"
