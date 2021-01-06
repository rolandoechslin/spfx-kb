<#  

.Description
    Outputs a .csv file of records that represent user/groups found in Flow 
    throughout the tenant it is run in. Result feature records will include:
        - User/Groups used in Flows

.Link
    PowerApps PowerShell installation instructions and documentation:
    - https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell
    - https://www.powershellgallery.com/packages/Microsoft.PowerApps.Administration.PowerShell/2.0.102
    - https://www.powershellgallery.com/packages/AzureADPreview/2.0.2.129

.Example
    PS C:\> .\findFlowOwnerRoles.ps1 -EnvironmentName "<name>" -Path "<path>"
    PS C:\> .\findFlowOwnerRoles.ps1

#>

param(
    [string]$EnvironmentName,
    [string]$Path = 'C:\Temp\flowOwnerRoles.csv'
)

Clear-Host

function Assert-ModuleExists([string]$ModuleName) {
    $module = Get-Module $ModuleName -ListAvailable -ErrorAction SilentlyContinue
    if (!$module) {
        Write-Host "Module [$($ModuleName)] not installed!" -ForegroundColor Red
        exit
    }
}

Assert-ModuleExists -ModuleName "Microsoft.PowerApps.Administration.PowerShell"
Assert-ModuleExists -ModuleName "AzureAD*"


# connect to tenant
# Add-PowerAppsAccount
# Connect-AzureAD

if (-not [string]::isNullOrEmpty($EnvironmentName))
{
    $flows = Get-AdminFlow -EnvironmentName $EnvironmentName
}
else 
{
    $flows = Get-AdminFlow 
}


$flowRoleAssignments = @()

# loop through each app
foreach ($flow in $flows)
{

    $roleassignments = Get-AdminFlowOwnerRole -FlowName $flow.FlowName -EnvironmentName $flow.EnvironmentName


    # loop through each app roleassignments
    foreach($role in $roleassignments)
    {

        if ($role.PrincipalType -eq "Group"){

            # Fix: PrincipalDisplayName is missing in PowerApps Module
            $group = Get-AzureADGroup -ObjectId $role.PrincipalObjectId

            $row = [pscustomobject]@{
                "FlowDisplayName" = $flow.DisplayName
                "FlowEnvironmentName" = $flow.EnvironmentName
                "FlowName" = $flow.FlowName
                "PrincipalDisplayName" = $group.DisplayName
                "PrincipalObjectId" = $role.PrincipalObjectId
                "PrincipalType" = $role.PrincipalType
                "RoleType" = $role.RoleType
              }
    
              $flowRoleAssignments += $row
    
        }

    }
}

# output to file

$flowRoleAssignments

$flowRoleAssignments | Export-Csv -Path $Path -Encoding UTF8 -Delimiter ";" -NoTypeInformation

