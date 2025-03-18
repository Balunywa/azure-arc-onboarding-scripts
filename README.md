
Azure Arc Onboarding Scripts for Rapid POC

This repository provides scripts to rapidly onboard 5–10 virtual machines to Azure Arc as part of a proof-of-concept (POC). The scripts support both Linux and Windows environments, streamlining the onboarding process by dynamically generating required parameters, handling prerequisite checks, registering resource providers, and managing logging.

Table of Contents

Overview
Scripts
Linux Onboarding
Windows Onboarding
Getting Started
Notes
Overview

Purpose: Quickly integrate virtual machines with Azure Arc for POC scenarios.
Key Benefits:
Automated parameter generation (e.g., correlation IDs, machine names)
Prerequisite and resource provider checks
Cross-platform support (Linux and Windows)
User confirmation to safeguard against unintended deployments
Scripts

Linux Onboarding
Script Name

linux_onboard.sh

Purpose

Onboards a Linux virtual machine to Azure Arc.

Features

Parameter Inputs:
Accepts service principal credentials, subscription details, resource group, tenant ID, location, and cloud environment.
Dynamic Generation:
Uses uuidgen for correlation identifiers and hostname for machine names.
Resource Provider Checks:
Validates and registers Microsoft.HybridCompute and Microsoft.ExtendedLocation.
User Interaction:
Prompts for confirmation before proceeding.
Agent Installation:
Downloads and executes the Azure Arc agent installation script.
Connection:
Connects the virtual machine using the Azure Connected Machine Agent.
Usage

./linux_onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> \
                   <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>
Prerequisites

Bash shell
wget and uuidgen installed
Azure CLI (az) installed and configured
Supported Linux distribution for the Azure Connected Machine Agent
Windows Onboarding
Script Name

windows_onboard.ps1

Purpose

Onboards a Windows virtual machine to Azure Arc.

Features

Parameter Inputs:
Accepts service principal credentials, subscription details, resource group, tenant ID, location, and cloud environment.
Admin Privileges:
Checks for administrator rights and auto-elevates if necessary.
Dynamic Generation:
Creates a new correlation identifier.
Machine Name:
Retrieves the machine name with an optional override.
Resource Provider Checks:
Validates and registers required providers.
User Interaction:
Prompts for confirmation before proceeding.
Agent Installation:
Downloads and executes the Azure Arc agent installation script for Windows.
Logging:
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
Example

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
Administrator privileges (auto-elevation if needed)
Internet access for downloading the agent installation script
Azure CLI (az) installed for resource provider registration
Getting Started

Clone the Repository
git clone https://github.com/<YourGitHubUsername>/azure-arc-onboarding-scripts.git
cd azure-arc-onboarding-scripts
Review and Configure
Linux:
Ensure wget, uuidgen, and Azure CLI are installed.
Confirm the Linux distribution is supported by the Azure Connected Machine Agent.
Windows:
Ensure the execution policy allows scripts (using -ExecutionPolicy Bypass).
Confirm Azure CLI is installed.
Deploy on Virtual Machines
Linux:
./linux_onboard.sh <ServicePrincipalId> <ServicePrincipalClientSecret> \
                   <SubscriptionId> <ResourceGroup> <TenantId> <Location> <Cloud>
Windows:
PowerShell -ExecutionPolicy Bypass -File windows_onboard.ps1 `
  -ServicePrincipalId "<ServicePrincipalId>" `
  -ServicePrincipalClientSecret "<ServicePrincipalClientSecret>" `
  -SubscriptionId "<SubscriptionId>" `
  -ResourceGroup "<ResourceGroup>" `
  -TenantId "<TenantId>" `
  -Location "<Location>" `
  -Cloud "<Cloud>" `
  [-MachineNameOverride "<MachineName>"]
Automation Tip:
For deployments across multiple machines, consider orchestration tools like Ansible, System Center Configuration Manager (SCCM), or other configuration management systems.
Notes

POC Focus:
These scripts are optimized for rapid POC deployments. For production, additional error handling and security reviews are recommended.
Correlation Identifier:
Each execution generates a unique identifier for tracking and troubleshooting.
Resource Providers:
Automatically registers the required Azure Arc resource providers (Microsoft.HybridCompute and Microsoft.ExtendedLocation).
User Confirmation:
A confirmation step is included to prevent accidental deployments.