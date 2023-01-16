Clear-Host
 <#Information
  
    Author: thewatchernode
    Contact: andrew.moran@lyncme.co.uk
    Published: 16th January 2023
    Source: https://www.blogabout.cloud/2023/01/9168/
 
    .DESCRIPTION
    Tool to assist with removal of legacy installed PowerShell Module from PSGallery
 
    Version Changes             : 0.1 Initial Script Build
                                : 1.0 Initial Build Release
      
    .EXAMPLE
    .\Get-InstalledModulesUpdate.ps1
 
    Description
    -----------
    Runs script with default values.
 
 
    .INPUTS
    None. You cannot pipe objects to this script.
#>
 #region Shortnames
 $Red = 'Red'
 $Green = 'Green'
 $DarkRed = 'DarkRed'
 $White = 'White'
 $DarkCyan = 'DarkCyan'
 $DarkGray = 'DarkGray'
 #endregion
 
# Array for Modules
    #$CommonO365Module = @('MSOnline', 'Microsoft365DSC', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'Microsoft.Online.Sharepoint.PowerShell', 'ORCA','AzureAD')
    $Array = @(Get-InstalledModule)
  
  
Function Get-ModuleUpdates {# Check and update all modules to make sure that we're at the latest version
# Check and remove older versions of the modules from the PC
    ForEach ($Module in $array) {
        Write-Host 'INFO: Checking for older versions of' $Module.Name 'installed on client device' -BackgroundColor $DarkCyan -ForegroundColor $White
        $AllVersions = Get-InstalledModule -Name $Module.Name -AllVersions
        $AllVersions = $AllVersions | Sort-Object -Property PublishedDate -Descending 
        $MostRecentVersion = $AllVersions[0].Version
        Write-Host 'Most recent version (' $MostRecentVersion ') for' $Module.Name 'is installed on client device'
    
    If ($AllVersions.Count -gt 1 ) { # More than a single version installed
            ForEach ($Version in $AllVersions) { #Check each version and remove old versions
                If ($Version.Version -ne $MostRecentVersion)  { # Old version - remove
                    Write-Host 'Uninstalling version' $Version.Version 'of Module' $Module.Name -BackgroundColor $DarkRed -ForegroundColor $White 
                    Uninstall-Module -Name $Module.Name -RequiredVersion $Version.Version -Force
                } #End if
            } #End ForEach
        } #End If
    } #End ForEach
}
 
 Write-host 'Version information - You are running script version 1.0' -ForegroundColor $White -BackgroundColor $DarkGray
  @'
  ┌─────────────────────────────────────────────────────────────┐
           Updating your PSGallery PowerShell Modules
 
               Follow @thewatchernode on Twitter                               
  └─────────────────────────────────────────────────────────────┘
'@
Start-Transcript -Path $env:USERPROFILE\desktop\ModuleUpdate_Log.txt
Get-ModuleUpdates
Stop-Transcript