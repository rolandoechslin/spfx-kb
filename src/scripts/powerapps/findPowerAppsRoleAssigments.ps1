<#  

.Description
    Outputs a .csv file of records that represent user/groups found in PowerApps and Flow 
    throughout the tenant it is run in. Result feature records will include:
        - User/Groups used in PowerApps
.Link
    PowerApps PowerShell installation instructions and documentation: 
    - https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell
    - https://www.powershellgallery.com/packages/Microsoft.PowerApps.Administration.PowerShell/2.0.102

.Example
    PS C:\> .\findPowerAppsRoleAssigments.ps1 -EnvironmentName "<name>" -Path "<path>"
    PS C:\> .\findPowerAppsRoleAssigments.ps1

#>

param(
    [string]$EnvironmentName,
    [string]$Path = 'C:\Temp\powerAppsRoleAssigments.csv'
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

# connect to tenant
# Add-PowerAppsAccount


if (-not [string]::isNullOrEmpty($EnvironmentName))
{
    $apps = Get-AdminPowerApp -EnvironmentName $EnvironmentName
}
else 
{
    $apps = Get-AdminPowerApp 
}


# Returns all role assignments for the specified app in the environment.
# Get-AdminPowerAppRoleAssignment -AppName "9fa53031-bc8b-45c5-acfa-0649a9393fac" -EnvironmentName "Default-4dc000c5-c2a3-4221-bfc3-bc646b2916a3"

$appRoleAssignments = @()

# loop through each app
foreach ($app in $apps)
{

    $roleassignments = Get-AdminPowerAppRoleAssignment -AppName $app.AppName -EnvironmentName $app.EnvironmentName

    # loop through each app roleassignments
    foreach($role in $roleassignments)
    {

        if ($role.PrincipalType -eq "Group"){

            $row = [pscustomobject]@{
                "AppDisplayName" = $app.DisplayName
                "AppEnvironmentName" = $app.EnvironmentName
                "AppName" = $app.AppName
                "PrincipalDisplayName" = $role.PrincipalDisplayName
                "PrincipalObjectId" = $role.PrincipalObjectId
                "PrincipalType" = $role.PrincipalType
                "RoleType" = $role.RoleType
              }
    
              $appRoleAssignments += $row
    
        }

    }
}

# output to file
$appRoleAssignments

$appRoleAssignments | Export-Csv -Path $Path -Encoding UTF8 -Delimiter ";" -NoTypeInformation

