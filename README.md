# Azure Arc Onboarding Scripts for Rapid POC

This repository contains scripts to rapidly onboard five to ten virtual machines to Azure Arc as part of a proof-of-concept. These scripts are designed for both Linux and Windows environments, streamlining the onboarding process by dynamically generating required parameters such as correlation identifiers and machine names and handling prerequisite checks and logging.

## Overview

### Linux Script: Onboard Shell Script

#### Purpose

This script onboards a Linux virtual machine to Azure Arc.

#### Features

- Accepts parameters for service principal credentials, subscription details, resource group, tenant identifier, location, and cloud environment.
- Dynamically generates a correlation identifier using the universally unique identifier generation tool.
- Retrieves the machine name using the hostname command.
- Downloads and executes the Azure Arc agent installation script.
- Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent connect command.

#### Usage

Execute the script with the required parameters.

Service principal identifier, service principal client secret, subscription identifier, resource group, tenant identifier, location, and cloud environment must be provided.

#### Prerequisites

- Bash shell
- Web get and universally unique identifier generation tools installed
- Azure Connected Machine Agent supported on the target Linux distribution

### Windows Script: Onboard PowerShell Script

#### Purpose

This script onboards a Windows virtual machine to Azure Arc.

#### Features

- Accepts parameters for service principal credentials, subscription details, resource group, tenant identifier, location, and cloud environment.
- Automatically checks for administrator privileges and re-launches with elevation if needed.
- Dynamically generates a new correlation identifier.
- Retrieves the machine name from the system with an optional override parameter.
- Downloads and executes the Azure Arc agent installation script for Windows.
- Connects the virtual machine to Azure Arc using the Azure Connected Machine Agent.
- Logs errors remotely for troubleshooting.

#### Usage

Run the script with the necessary parameters.

Service principal identifier, service principal client secret, subscription identifier, resource group, tenant identifier, location, and cloud environment must be provided.

Optionally, specify a machine name override.

#### Prerequisites

- Windows PowerShell version five or later or PowerShell Core
- Administrator privileges with automatic elevation
- Internet access for downloading the agent installation script

## Getting Started

### Clone the Repository

Clone the repository and navigate into the directory.

### Review and Configure

For Linux, ensure that the target virtual machines have the necessary utilities, including web get and universally unique identifier generation tools installed.

For Windows, verify that the execution policy allows script execution or run with bypass execution policy.

### Deploy on Virtual Machines

For Linux virtual machines, execute the onboard shell script with the required parameters.

For Windows virtual machines, run the onboard PowerShell script with the necessary parameters.

Use orchestration tools such as Ansible, System Center Configuration Manager, or other configuration management systems to deploy these scripts across five to ten virtual machines quickly for proof-of-concept implementation.

## Notes

These scripts are intended for rapid proof-of-concept deployments. For production environments, further testing, enhanced error handling, and security reviews are recommended.

Each execution dynamically generates a unique correlation identifier to aid in tracking and troubleshooting.

Ensure that your virtual machines meet the prerequisites and are supported by the Azure Arc Connected Machine Agent.


