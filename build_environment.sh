#!/usr/bin/env bash
#
#  - Build script for serverless microservice environment
#
# Usage:
#
#  AZ_SUBSCRIPTION_ID=1234 AZ_BASE_NAME='random-123' ./build_environment.sh
#
# Based on a template by BASH3 Boilerplate v2.3.0
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace


# Environment variables (and their defaults) that this script depends on
AZ_SUBSCRIPTION_ID="${AZ_SUBSCRIPTION_ID:-1234}"                        # Azure subscription id
ARM_TEMPLATE_URI="${ARM_TEMPLATE_URI:-https://raw.githubusercontent.com/kawo123/azure-serverless-microservice/master/arm/main.json}"               # File path to Azure environment ARM template
AZ_REGION="${AZ_REGION:-eastus}"                                        # Azure region
AZ_BASE_NAME="${AZ_BASE_NAME:-GEN-UNIQUE}"                              # Base name for Azure resources


### Functions
##############################################################################

function __b3bp_log () {
  local log_level="${1}"
  shift

  # shellcheck disable=SC2034
  local color_info="\x1b[32m"
  local color_warning="\x1b[33m"
  # shellcheck disable=SC2034
  local color_error="\x1b[31m"

  local colorvar="color_${log_level}"

  local color="${!colorvar:-${color_error}}"
  local color_reset="\x1b[0m"

  if [[ "${NO_COLOR:-}" = "true" ]] || [[ "${TERM:-}" != "xterm"* ]] || [[ ! -t 2 ]]; then
    if [[ "${NO_COLOR:-}" != "false" ]]; then
      # Don't use colors on pipes or non-recognized terminals
      color=""; color_reset=""
    fi
  fi

  # all remaining arguments are to be printed
  local log_line=""

  while IFS=$'\n' read -r log_line; do
    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
  done <<< "${@:-}"
}

function error ()     { __b3bp_log error "${@}"; true; }
function warning ()   { __b3bp_log warning "${@}"; true; }
function info ()      { __b3bp_log info "${@}"; true; }


### Runtime
##############################################################################

if ! [ -x "$(command -v az)" ]; then
  error "command not found: az. Please install Azure CLI before executing this setup script. See https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest to install Azure CLI."
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  error "command not found: jq. Please install jq before executing this setup script."
  exit 1
fi

az_rg_name="${AZ_BASE_NAME}-rg"

info "Initiating login to Azure"
az login > /dev/null
info "Successfully login to Azure"

info "Setting Az CLI subscription context to '${AZ_SUBSCRIPTION_ID}'"
az account set \
--subscription "${AZ_SUBSCRIPTION_ID}"

info "Creating resource group '${az_rg_name}' in region '${AZ_REGION}'"
az group create \
--subscription "${AZ_SUBSCRIPTION_ID}" \
--location "${AZ_REGION}" \
--name "${az_rg_name}" 1> /dev/null

info "Validating ARM template '${ARM_TEMPLATE_URI}' deployment to resource group '${az_rg_name}'"
az group deployment validate \
--resource-group "${az_rg_name}" \
--template-uri "${ARM_TEMPLATE_URI}" \
--parameters location="${AZ_REGION}" baseName="${AZ_BASE_NAME}" > /dev/null

if [ $? -eq 0 ]; then
  info "ARM template validation passes"
else
  error "ARM template validation fails. Exiting.."
  exit 1
fi

info "Deploying ARM template '${ARM_TEMPLATE_URI}' deployment to resource group '${az_rg_name}'"
arm_template_output=$(az group deployment create \
--resource-group "${az_rg_name}" \
--template-uri "${ARM_TEMPLATE_URI}" \
--parameters location="${AZ_REGION}" baseName="${AZ_BASE_NAME}" | jq ".properties.outputs")
echo $arm_template_output | jq
info "ARM template deployment finishes"
