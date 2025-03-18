<#
.SYNOPSIS
    Onboards a Windows machine to Azure Arc with Resource Provider Registration.

.DESCRIPTION
    This script automates the following steps:
      1. Ensures the script is running with administrator privileges (relaunches if needed).
      2. Parses required parameters.
      3. Generates a unique correlation ID.
      4. Determines the machine name (with optional override).
      5. Checks if required Azure Arc resource providers (Microsoft.HybridCompute and Microsoft.ExtendedLocation)
         are registered in the subscription; if not, it registers them.
      6. Downloads and runs the Azure Connected Machine Agent installation script.
      7. Connects the machine to Azure Arc.

.PARAMETER ServicePrincipalId
    The Service Principal Application ID.

.PARAMETER ServicePrincipalClientSecret
    The Service Principal Client Secret.

.PARAMETER SubscriptionId
    Your Azure Subscription ID.

.PARAMETER ResourceGroup
    The Azure Resource Group for onboarding.

.PARAMETER TenantId
    Your Azure Tenant ID.

.PARAMETER Location
    The Azure region (e.g., eastus).

.PARAMETER Cloud
    The cloud name (e.g., AzureCloud).

.PARAMETER MachineNameOverride
    (Optional) Overrides the machine name. If not provided, the script uses the computer name.

.EXAMPLE
    PowerShell -ExecutionPolicy Bypass -File onboard_windows.ps1 `
      -ServicePrincipalId " " `
      -ServicePrincipalClientSecret " " `
      -SubscriptionId " " `
      -ResourceGroup " " `
      -TenantId " " `
      -Location "eastus" `
      -Cloud "AzureCloud"
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ServicePrincipalId,

    [Parameter(Mandatory=$true)]
    [string]$ServicePrincipalClientSecret,

    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$TenantId,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$Cloud,

    [Parameter(Mandatory=$false)]
    [string]$MachineNameOverride
)

$global:scriptPath = $MyInvocation.MyCommand.Definition

function Restart-AsAdmin {
    $pwshCommand = "powershell"
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $pwshCommand = "pwsh"
    }
    try {
        Write-Host "This script requires administrator permissions to install the Azure Connected Machine Agent. Attempting to restart with elevated permissions..."
        $arguments = "-NoExit -Command `"& '$scriptPath'`""
        Start-Process $pwshCommand -Verb runAs -ArgumentList $arguments
        exit 0
    }
    catch {
        throw "Failed to elevate permissions. Please run this script as Administrator."
    }
}

# Ensure the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ([System.Environment]::UserInteractive) {
        Restart-AsAdmin
    }
    else {
        throw "This script requires administrator permissions. Please run it as Administrator."
    }
}

try {
    # Generate a new correlation ID
    $CorrelationId = [guid]::NewGuid().ToString()
    Write-Host "Generated Correlation ID: $CorrelationId"

    # Determine machine name (override if provided)
    if ($MachineNameOverride) {
        $MachineName = $MachineNameOverride
    }
    else {
        $MachineName = $env:COMPUTERNAME
    }
    Write-Host "Using Machine Name: $MachineName"

    # Check if Azure CLI is installed
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Azure CLI (az) is not installed. Please install Azure CLI."
        exit 1
    }

    # Set the active subscription
    az account set --subscription $SubscriptionId | Out-Null

    # Check and register required Azure Arc resource providers
    Write-Host "Checking required Azure Arc resource providers..."
    $providers = @("Microsoft.HybridCompute", "Microsoft.ExtendedLocation")
    foreach ($provider in $providers) {
        $state = az provider show --namespace $provider --query "registrationState" --output tsv 2>$null
        if ($state -ne "Registered") {
            Write-Host "Registering $provider..."
            az provider register --namespace $provider | Out-Null
            Write-Host "$provider registered."
        }
        else {
            Write-Host "$provider is already registered."
        }
    }

    # Set environment variables for the agent connection
    $env:SUBSCRIPTION_ID = $SubscriptionId
    $env:RESOURCE_GROUP    = $ResourceGroup
    $env:TENANT_ID         = $TenantId
    $env:LOCATION          = $Location
    $env:AUTH_TYPE         = "principal"
    $env:CORRELATION_ID    = $CorrelationId
    $env:CLOUD             = $Cloud

    # Ensure TLS 1.2 is used
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072

    # Download the Azure Arc agent installation script for Windows
    $InstallScript = "$env:TEMP\install_windows_azcmagent.ps1"
    Write-Host "Downloading Azure Arc agent installation script..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/azcmagent-windows" -TimeoutSec 30 -OutFile $InstallScript

    Write-Host "Running the installation script..."
    & $InstallScript
    if ($LASTEXITCODE -ne 0) { exit 1 }

    # Connect the machine to Azure Arc
    Write-Host "Connecting machine to Azure Arc..."
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect `
      --service-principal-id $ServicePrincipalId `
      --service-principal-secret $ServicePrincipalClientSecret `
      --resource-group $env:RESOURCE_GROUP `
      --tenant-id $env:TENANT_ID `
      --location $env:LOCATION `
      --subscription-id $env:SUBSCRIPTION_ID `
      --cloud $env:CLOUD `
      --correlation-id $env:CORRELATION_ID `
      --machine-name $MachineName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Azure Arc onboarding successful."
    }
    else {
        Write-Host "Azure Arc onboarding failed."
        exit 1
    }
}
catch {
    $logBody = @{
        subscriptionId = $env:SUBSCRIPTION_ID
        resourceGroup  = $env:RESOURCE_GROUP
        tenantId       = $env:TENANT_ID
        location       = $env:LOCATION
        correlationId  = $env:CORRELATION_ID
        authType       = $env:AUTH_TYPE
        operation      = "onboarding"
        messageType    = $_.FullyQualifiedErrorId
        message        = "$_"
    }
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | Out-Null
    Write-Host -ForegroundColor Red $_.Exception
}
