# Azure Arc Onboarding Scripts for Rapid POC

This repository contains scripts to rapidly onboard five to ten virtual machines to Azure Arc as part of a proof-of-concept (POC). These scripts are designed for both Linux and Windows environments, streamlining the onboarding process by dynamically generating required parameters (such as correlation identifiers and machine names) and handling prerequisite checks, resource provider registration, and logging.

---

## Linux Onboarding

### Script: `linux_onboard.sh`

#### Purpose

Onboards a Linux virtual machine to Azure Arc.

#### Features

- Accepts parameters for service principal credentials, subscription details, resource group, tenant ID, location, and cloud environment.
- Dynamically generates a correlation identifier using `uuidgen`.
- Retrieves the machine name using the `hostname` command.
- Checks and registers required Azure Arc resource providers (`Microsoft.HybridCompute` and `Microsoft.ExtendedLocation`).
- Prompts the user to confirm before proceeding with installation.
- Downloads and executes the Azure Arc agent installation script.
- Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent.

#### Usage

```sh
./linux_onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> \
                   <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>

Prerequisites

Bash shell
wget and uuidgen installed
Azure CLI (az) installed and configured
Azure Connected Machine Agent supported on the target Linux distribution
Windows Onboarding

Script: windows_onboard.ps1
Purpose

Onboards a Windows virtual machine to Azure Arc.

Features

Accepts parameters for service principal credentials, subscription details, resource group, tenant ID, location, and cloud environment.
Automatically checks for administrator privileges and re-launches with elevation if needed.
Dynamically generates a new correlation identifier.
Retrieves the machine name from the system (with an optional override parameter).
Checks and registers required Azure Arc resource providers.
Prompts the user to confirm before proceeding with installation.
Downloads and executes the Azure Arc agent installation script for Windows.
Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent.
Logs errors remotely for troubleshooting.
Usage

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
Administrator privileges (script auto-elevates if needed)
Internet access for downloading the agent installation script
Azure CLI (az) installed (for resource provider registration)
Getting Started

1. Clone the Repository
git clone https://github.com/<YourGitHubUsername>/azure-arc-onboarding-scripts.git
cd azure-arc-onboarding-scripts
2. Review and Configure
Linux

Ensure wget, uuidgen, and Azure CLI are installed.
Confirm the Linux distribution is supported by the Azure Connected Machine Agent.
Windows

Ensure execution policy allows scripts (-ExecutionPolicy Bypass).
Confirm the Azure CLI is installed.
3. Deploy on Virtual Machines
Linux

./linux_onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> \
                   <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>
Windows

PowerShell -ExecutionPolicy Bypass -File windows_onboard.ps1 `
  -ServicePrincipalId "<ServicePrincipalId>" `
  -ServicePrincipalClientSecret "<ServicePrincipalClientSecret>" `
  -SubscriptionId "<SubscriptionId>" `
  -ResourceGroup "<ResourceGroup>" `
  -TenantId "<TenantId>" `
  -Location "<Location>" `
  -Cloud "<Cloud>" `
  [-MachineNameOverride "<MachineName>"]
To automate deployments across multiple machines, use orchestration tools like Ansible, System Center Configuration Manager (SCCM), or other configuration management systems.

Notes

These scripts are for rapid POC deployments. For production use, implement additional error handling and security reviews.
Each execution generates a unique correlation identifier for tracking and troubleshooting.
The scripts automatically register required Azure Arc resource providers (Microsoft.HybridCompute, Microsoft.ExtendedLocation).
User confirmation is required before installation to prevent unintended deployments.