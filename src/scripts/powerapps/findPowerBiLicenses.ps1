# https://www.sqlshack.com/connect-query-power-bi-azure-using-powershell/

param(
    [string]$Path = 'C:\Temp\powerBiLicenses.csv'
)

Clear-Host

function Assert-ModuleExists([string]$ModuleName) {
    $module = Get-Module $ModuleName -ListAvailable -ErrorAction SilentlyContinue
    if (!$module) {
        Write-Host "Module [$($ModuleName)] not installed!" -ForegroundColor Red
        exit
    }
}

Assert-ModuleExists -ModuleName "AzureAD*"

#-------------------------------------------------------------------------------

# Connect to Azure

$password = "xxx" | ConvertTo-SecureString -asPlainText -Force
$username = "xxx@xxx.onmicrosoft.com" 
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Connect-AzureAD -Credential $credential

#-------------------------------------------------------------------------------

# Collect license info
$PBILicenses = Get-AzureADSubscribedSku #| ?{$_.SkuPartNumber -like '*POWER_BI*' -and $_.CapabilityStatus -eq "Enabled"} | SELECT SkuPartNumber, ConsumedUnits, SkuId

# Return global license count
$PBILicenses | Select-Object SkuPartNumber, ConsumedUnits, @{n="ActiveUnits";e={$_.PrepaidUnits.Enabled}}

#-------------------------------------------------------------------------------

# Loop through each license and list all users
foreach($license in $PBILicenses)
{
    $PBIUsers = Get-AzureADUser -All 1 | Where-Object{($_.AssignedLicenses | Where-Object{$_.SkuId -eq $license.SkuId})} | Select-Object DisplayName, UserPrincipalName, @{l="License";e={$license.SkuPartNumber}} 
}

$PBIUsers | Export-CSV -Path $Path -Encoding UTF8 -Delimiter ";" -NoTypeInformation

$PBIUsers

#-------------------------------------------------------------------------------



