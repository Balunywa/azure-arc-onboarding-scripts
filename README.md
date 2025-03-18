
# Azure Arc Onboarding Scripts for Rapid POC

This repository contains scripts to rapidly onboard five to ten virtual machines to Azure Arc as part of a proof-of-concept (POC). These scripts are designed for both Linux and Windows environments, streamlining the onboarding process by dynamically generating required parameters (such as correlation identifiers and machine names) and handling prerequisite checks, resource provider registration, and logging.

---

## Overview

### Linux Script: `linux_onboard.sh`

#### Purpose

Onboards a Linux virtual machine to Azure Arc.

#### Features

- Accepts parameters for service principal credentials, subscription details, resource group, tenant identifier, location, and cloud environment.
- Dynamically generates a correlation identifier using the `uuidgen` tool.
- Retrieves the machine name using the `hostname` command.
- Checks and registers required Azure Arc resource providers (e.g., `Microsoft.HybridCompute` and `Microsoft.ExtendedLocation`).
- Prompts the user to confirm before proceeding with installation.
- Downloads and executes the Azure Arc agent installation script.
- Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent connect command.

#### Usage

Execute the script with the required parameters:

```bash
./linux_onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> \
                   <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>
Example:

./linux_onboard.sh 32e3951c-17d8-4af1-9360-47c34f4544a7 "YOUR_SECRET" \
                   a6513f2e-fae7-4e14-8818-87ecb1820f36 AZ-Migrate \
                   070b29e7-e047-4edc-85da-bb395204b580 eastus AzureCloud
Prerequisites

Bash shell
wget and uuidgen installed
Azure CLI (az) installed and configured
Azure Connected Machine Agent supported on the target Linux distribution
Windows Script: windows_onboard.ps1
Purpose

Onboards a Windows virtual machine to Azure Arc.

Features

Accepts parameters for service principal credentials, subscription details, resource group, tenant identifier, location, and cloud environment.
Automatically checks for administrator privileges and re-launches with elevation if needed.
Dynamically generates a new correlation identifier.
Retrieves the machine name from the system (with an optional override parameter).
Checks and registers required Azure Arc resource providers.
Prompts the user to confirm before proceeding with installation.
Downloads and executes the Azure Arc agent installation script for Windows.
Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent.
Logs errors remotely for troubleshooting.
Usage

Run the script with the necessary parameters:

PowerShell -ExecutionPolicy Bypass -File windows_onboard.ps1 `
  -ServicePrincipalId "<ServicePrincipalId>" `
  -ServicePrincipalClientSecret "<ServicePrincipalClientSecret>" `
  -SubscriptionId "<SubscriptionId>" `
  -ResourceGroup "<ResourceGroup>" `
  -TenantId "<TenantId>" `
  -Location "<Location>" `
  -Cloud "<Cloud>" `
  [-MachineNameOverride "<MachineName>"]
Example:

PowerShell -ExecutionPolicy Bypass -File windows_onboard.ps1 `
  -ServicePrincipalId "32e3951c-17d8-4af1-9360-47c34f4544a7" `
  -ServicePrincipalClientSecret "YOUR_SECRET" `
  -SubscriptionId "a6513f2e-fae7-4e14-8818-87ecb1820f36" `
  -ResourceGroup "AZ-Migrate" `
  -TenantId "070b29e7-e047-4edc-85da-bb395204b580" `
  -Location "eastus" `
  -Cloud "AzureCloud" `
  -MachineNameOverride "MyCustomVM"
Prerequisites

Windows PowerShell (version 5.0+ or PowerShell Core)
Administrator privileges (the script auto-elevates if needed)
Internet access for downloading the agent installation script
Azure CLI (az) installed (for resource provider registration)
Getting Started

1. Clone the Repository
Open your terminal or PowerShell window and run:

git clone https://github.com/<YourGitHubUsername>/azure-arc-onboarding-scripts.git
cd azure-arc-onboarding-scripts
2. Review and Configure
Linux:

Ensure your target virtual machines have wget, uuidgen, and the Azure CLI installed and configured.
Confirm that your Linux distribution is supported by the Azure Connected Machine Agent.
Windows:

Verify that your execution policy allows script execution (or use the -ExecutionPolicy Bypass flag).
Ensure that the Azure CLI is installed.
3. Deploy on Virtual Machines
For Linux VMs:

Execute the linux_onboard.sh script with the required parameters as shown in the usage example above.

For Windows VMs:

Run the windows_onboard.ps1 script with the necessary parameters as shown in the usage example above.

For rapid proof-of-concept deployments, you can integrate these scripts into orchestration tools such as Ansible, System Center Configuration Manager (SCCM), or other configuration management systems to roll them out across five to ten virtual machines quickly.

Notes

These scripts are intended for rapid POC deployments. For production environments, further testing, enhanced error handling, and security reviews are recommended.
Each execution dynamically generates a unique correlation identifier to aid in tracking and troubleshooting.
The scripts automatically check and register required Azure Arc resource providers (Microsoft.HybridCompute and Microsoft.ExtendedLocation).
User confirmation is requested before proceeding with the installation to ensure readiness.

This version ensures your **README.md** is structured, clean, and formatted correctly for GitHub, making it easy to follow for users deploying Azure Arc onboarding scripts. 🚀 Let me know if you need further refinements!