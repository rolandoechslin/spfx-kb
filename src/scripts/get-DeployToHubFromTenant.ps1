# https://reshmeeauckloo.com/posts/powershell_spfxdeploytohubfromtenant/ 

$AdminCenterURL="https://contoso-admin.sharepoint.com"
$tenantAppCatalogUrl = "https://contoso.sharepoint.com/sites/appcatalog"
$hubSiteUrl = "https://contoso.sharepoint.com"
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "\Log_Tenant-" + $dateTime + ".csv"
$OutPutView = $directorypath + $fileName
 
$sppkgFolder = "./packages"
 
Set-Location $PSScriptRoot
$packageFiles = Get-ChildItem $sppkgFolder
 
Connect-PnPOnline $tenantAppCatalogUrl -Interactive
$appCatConnection  = Get-PnPConnection
 
Connect-PnPOnline $AdminCenterURL -Interactive
$adminConnection  = Get-PnPConnection
 
$SiteAppUpdateCollection = @()
 
$HubSiteID = (Get-PnPTenantSite -Identity $hubSiteUrl -Connection $adminConnection ).HubSiteId
 
#Get associated sites with hub
$associatedSites = Get-PnPTenantSite -Detailed -Connection $adminConnection| Where-Object { $_.HubSiteId -eq $HubSiteID }
 
foreach($package in $packageFiles)
{
  $packageName = $package.PSChildName
  Write-Host ("Installing {0}..." -f $packageName) -ForegroundColor Yellow
 
  Start-Sleep -Seconds 10
    #deploy sppkg assuming app catalog is already configured
   Add-pnpapp -Path ("{0}/{1}" -f $sppkgFolder , $package.PSChildName) -Scope Tenant -Overwrite -Publish
}
 
#Get all site collections associated with the hub site
#TO Test with updated changes
$associatedSites | Select-Object url | ForEach-Object {
    $Site = Get-PnPTenantSite $_.url -Connection $adminConnection
     Connect-PnPOnline -Url $Site.url -Interactive
     $siteConnection  = Get-PnPConnection
 
      Write-Host ("Deploying packages to {0}..." -f $Site.url) -ForegroundColor Yellow
 
       foreach($package in $packageFiles)
       {
          $ExportVw = New-Object PSObject
          $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $Site.url
          $packageName = $package.PSChildName
       
          $ExportVw | Add-Member -MemberType NoteProperty -name "Package Name" -value $packageName
           #Find Name of app from installed package
           $RestMethodUrl = '/_api/web/lists/getbytitle(''Apps%20for%20SharePoint'')/items?$select=Title,LinkFilename'
           $apps = (Invoke-PnPSPRestMethod -Url $RestMethodUrl -Method Get -Connection $appCatConnection).Value
           $appTitle = ($apps | where-object {$_.LinkFilename -eq $packageName} | Select-Object Title).Title
 
             #Install App to the Site if not already installed
        $web = Get-PnPWeb -Includes AppTiles -Connection $siteConnection
        $app = $web.AppTiles  |  where-object {$_.Title -eq $currentPackage.Title }
        if(!$app)
        {
            Install-PnPApp -Identity $currentPackage.Id -Connection $siteConnection
            Start-Sleep -Seconds 5
        }
 
           # Get the current version of the SPFx package
          $currentPackage = Get-PnPApp -Identity  $appTitle -Connection $siteConnection
          Write-Host "Current package version on site $($site.Url): $($currentPackage.InstalledVersion)"
         
          Write-Host "Latest package version: $($currentPackage.AppCatalogVersion)"
 
    # Update the package to the latest version
    if ($currentPackage.InstalledVersion -ne $currentPackage.AppCatalogVersion) {
        Write-Host "Upgrading package on site $($site.Url) to latest version..."
        Update-PnPApp -Identity $currentPackage.Id
        $currentPackage = Get-PnPApp -Identity $appTitle -Connection $siteConnection
        $ExportVw | Add-Member -MemberType NoteProperty -name "Package Version" -value $currentPackage.AppCatalogVersion
        $SiteAppUpdateCollection += $ExportVw
    } else {
        Write-Host "Package already up-to-date on site $($site.Url)."
    }
  }
}
 
#Export the result Array to CSV file
$SiteAppUpdateCollection | Export-CSV $OutPutView -Force -NoTypeInformation
 
Disconnect-PnPOnline
