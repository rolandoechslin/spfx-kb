
# Source: https://github.com/koltyakov/sp-sig-20180705-demo/blob/master/provisioning/Deploy.ps1

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True)]
  [string]$SchemaPath,

  [Parameter(Mandatory=$False)]
  [string]$SiteUrl,

  [Parameter(Mandatory=$False)]
  [boolean]$DebugMode = $False
);

. "$PSScriptRoot\lib\Functions.ps1";

Function Main() {
  Try {
    $StartTime = Get-Date;

    $Context = Get-SpAuthContext -Path "./config/private.json";

    If ([string]::IsNullOrEmpty($SiteUrl)) {
      $SiteUrl = $Context.siteUrl;
    }

    Write-Output "Target site: $SiteUrl";

    If ($DebugMode) {
      Set-PnPTraceLog -On -Level Debug;
    }

    Connect-PnPOnline -Url $SiteUrl -Credential $Context.Credentials;

    Apply-PnPProvisioningTemplate -Path $SchemaPath;

    $EndTime = Get-Date;
    $TimeSpan = New-TimeSpan $StartTime $EndTime;

    PrintSuccessMessage "Execution time: $timespan";
  }
  Catch [Exception] {
    PrintErrorMessage $_.Exception.Message;
  }
}

Main;