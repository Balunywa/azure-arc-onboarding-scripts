#!/bin/bash
# Onboard Linux VM to Azure Arc with Resource Provider Registration
#
# This script performs the following steps:
# 1. Parses required parameters.
# 2. Generates a unique correlation ID.
# 3. Retrieves the machine name.
# 4. Checks if required Azure Arc resource providers (Microsoft.HybridCompute and Microsoft.ExtendedLocation)
#    are registered in the subscription; if not, it registers them.
# 5. Downloads and runs the Azure Connected Machine Agent installation script.
# 6. Connects the machine to Azure Arc.
#
# Usage:
#   ./onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>

set -e

if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <ServicePrincipalId> <ServicePrincipalClientSecret> <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>"
  exit 1
fi

ServicePrincipalId="$1"
ServicePrincipalClientSecret="$2"
SubscriptionId="$3"
ResourceGroup="$4"
TenantId="$5"
Location="$6"
Cloud="$7"

# Generate a unique correlation ID
CorrelationId=$(uuidgen)
echo "Generated Correlation ID: $CorrelationId"

# Retrieve the machine name
MachineName=$(hostname)
echo "Detected Machine Name: $MachineName"

# Check for Azure CLI (az) installation
if ! command -v az &> /dev/null; then
  echo "Error: Azure CLI (az) is not installed. Please install Azure CLI."
  exit 1
fi

# Optionally, log in using the service principal if not already logged in
# az login --service-principal -u "$ServicePrincipalId" -p "$ServicePrincipalClientSecret" --tenant "$TenantId"

# Set the active subscription
az account set --subscription "$SubscriptionId"

# Check and register required Azure Arc resource providers
echo "Checking required Azure Arc resource providers..."
for provider in Microsoft.HybridCompute Microsoft.ExtendedLocation; do
    state=$(az provider show --namespace $provider --query "registrationState" --output tsv 2>/dev/null)
    if [ "$state" != "Registered" ]; then
         echo "Registering $provider..."
         az provider register --namespace $provider
         echo "$provider registered."
    else
         echo "$provider is already registered."
    fi
done

# Download the Azure Connected Machine Agent installation script
INSTALL_SCRIPT="/tmp/Install_linux_azcmagent.sh"
echo "Downloading Azure Arc agent installation script..."
wget https://aka.ms/azcmagent -O "$INSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the installation script."
    exit 1
fi

chmod +x "$INSTALL_SCRIPT"
echo "Running the installation script..."
bash "$INSTALL_SCRIPT"

# Connect the machine to Azure Arc
echo "Connecting machine to Azure Arc..."
azcmagent connect --service-principal-id "$ServicePrincipalId" \
  --service-principal-secret "$ServicePrincipalClientSecret" \
  --resource-group "$ResourceGroup" \
  --tenant-id "$TenantId" \
  --location "$Location" \
  --subscription-id "$SubscriptionId" \
  --cloud "$Cloud" \
  --correlation-id "$CorrelationId"

if [ $? -eq 0 ]; then
  echo -e "\033[33mTo view your onboarded server(s), navigate to:\nhttps://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.HybridCompute%2Fmachines\033[m"
else
  echo "Azure Arc onboarding failed."
  exit 1
fi

