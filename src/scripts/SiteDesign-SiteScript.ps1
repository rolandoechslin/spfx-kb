
<#  
README
    The scripts are not meant to be ran together. 
    These are a collection of scripts that can be pieced together.
    Each section below comments can perform a specific action.
    Update your info

CREATOR - Drew Madelung
LAST UPDATED - 3/15/2019

https://github.com/dmadelung/SiteDesignScripts/blob/master/SiteDesign-SiteScript.ps1

#>

#---CONNECT TO SPO---
#must download SPO module first - https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell/16.0.8029.0
$creds = Get-Credential
Connect-SPOService -Url https://domain-admin.sharepoint.com -Credential $creds

#---CREATING SITE SCRIPT---
#get JSON content and create site script
$sitescript = (Get-Content 'C:\filepath\filename.json' -Raw | Add-SPOSiteScript  -Title "SITE SCRIPT NAME") | Select -First 1 Id


#---CREATE SITE DESIGN AND ADD SITE SCRIPT---
#load site script by name and create a site design using that site script
$sitescript = Get-SPOSiteScript | where {$_.Title -eq "SITE SCRIPT NAME"} | select Id
$sitedesign = (Add-SPOSiteDesign -SiteScripts $sitescript.Id `
-Title "SITE DESIGN NAME" `
-WebTemplate 1 `
-Description "SITE DESIGN DESCRIPTION" `
-PreviewImageUrl "https://domain.sharepoint.com/SiteAssets/filename.jpg" `
-PreviewImageAltText "IMG ALT TEXT")

#---SET WEB TEMPLATE TO TEAM SITE---
#add -isDefault if needed
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE SCRIPT NAME"}
Set-SPOSiteDesign -Identity $sitedesign.Id -WebTemplate "64"

#---SET WEB TEMPLATE TO COMMUNICATION SITE---
#add -isDefault if needed
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE SCRIPT NAME"}
Set-SPOSiteDesign -Identity $sitedesign.Id -WebTemplate "68"

#---REMOVE SITE DESIGN---
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE SCRIPT NAME"}
Remove-SPOSiteDesign -Identity $sitedesign.Id

#---ADD SITE SCRIPT TO EXISTING SITE DESIGN---
#enter the site script you want to add and the site design you wand to add it to
$sitescript = Get-SPOSiteScript | where {$_.Title -eq "SITE SCRIPT NAME TO ADD"} 
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN TO BE ADDED TO"}
$existingsitescripts = New-Object System.Collections.ArrayList
if($sitedesign.SiteScriptIds.Length -lt 2){ 
    $singlesitescript = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
    if($singlesitescript -ne $sitescript.Id.ToString()) {
        $existingsitescripts.Add($singlesitescript)
        $existingsitescripts.Add($sitescript.Id.ToString())
     } else {
         Write-Host "Site Design already exists"
     }
} else {
    $existingsitescripts = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
    if($existingsitescripts.Contains($sitescript.Id.ToString())) {
        Write-Host "Site Design already exists"
    } else {
        $existingsitescripts.Add($sitescript.Id.ToString())
    }
}
if($sitedesign.SiteScriptIds.Length -lt 1) {
    Set-SPOSiteDesign -Identity $sitedesign.Id -SiteScripts $sitescript.Id.ToString()
} else {
    Set-SPOSiteDesign -Identity $sitedesign.Id -SiteScripts $existingsitescripts
}

#---REMOVE SITE SCRIPT FROM EXISTING SITE DESIGN---
#enter the site script you want to remove and the site design you wand to remove it from
$sitescript = Get-SPOSiteScript | where {$_.Title -eq "SITE SCRIPT NAME TO REMOVE"} 
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN TO REMOVE FROM"}
$existingsitescripts = New-Object System.Collections.ArrayList
if($sitedesign.SiteScriptIds.Length -lt 2){
    $singlesitescript = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
    $existingsitescripts.Remove($singlesitescript)
} else {
    $existingsitescripts = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
}
$existingsitescripts = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
$existingsitescripts.Remove($sitescript.Id.ToString())
Set-SPOSiteDesign -Identity $sitedesign.Id -SiteScripts $existingsitescripts


#---VIEW ALL SITE SCRIPTS FOR A SITE DESIGN---
#enter site design to see the titles of the site scripts 
$sitedesignsitescripts = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN NAME"} | select -ExpandProperty SiteScriptIds
foreach($ss in $sitedesignsitescripts){Get-SPOSiteScript -Identity $ss | select Title, Id}

#---SET SITE DESIGN RIGHTS---
#cannot use O365 groups, use mail enabled security
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN NAME"}
Grant-SPOSiteDesignRights `
  -Identity $sitedesign.Id `
  -Principals ("username@domain.com") `
  -Rights View

#---GET SITE DESIGN RIGHTS---
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN NAME"}
Get-SPOSiteDesignRights -Identity $sitedesign.Id

#---REMOVE SITE DESIGN RIGHTS---
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "Advanced Design"}
Revoke-SPOSiteDesignRights -Identity $sitedesign.Id -Principals "advancedsitedesigns@drewmadelung.com"

#---APPLY SITE DESIGN (SMALL)---
Invoke-SPOSiteDesign -Identity $sitedesign.Id -WebUrl "https://domain.sharepoint.com/sites/sitename"

#---APPLY SITE DESIGN (LARGE, USE THIS ONE)---
Add-SPOSiteDesignTask -SiteDesignId $sitedesign.Id -WebUrl "https://domain.sharepoint.com/sites/sitename"

#---VIEW SITE DESIGNS APPLIED TO A SITE---
Get-SPOSiteDesignRun -WebUrl "https://domain.sharepoint.com/sites/sitename"

#---VIEW SITE DESIGNS APPLIED, JUST BY TITLE---
Get-SPOSiteDesignRun -WebUrl "https://domain.sharepoint.com/sites/sitename" | select SiteDesignTitle

#---VIEW SITE DESIGN APPLIED DETAILS BY RUN---
$sitedesignruns = Get-SPOSiteDesignRun -WebUrl "https://domain.sharepoint.com/sites/sitename"
foreach($sdr in $sitedesignruns){Get-SPOSiteDesignRunStatus -Run $sdr}

#---GET SINGLE SITE DESIGN APPLIED DETAILS BY RUN---
Get-SPOSiteDesignRunStatus -Run $sdr[0] | more

#GET ALL SITE DESIGNS FOR AN UPDATE
#TODO

#---SET HUB SITE SITE DESIGN---
$hubsite = Get-SPOHubSite | where {$_.Title -eq "HUB SITE NAME"}
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN NAME"}
Set-SPOHubSite -Identity $hubsite -SiteDesignId $sitedesign.Id

#---GET JSON FROM EXISTING LIST---
$listextract = Get-SPOSiteScriptFromList "https://domain.sharepoint.com/sites/sitename/lists/listname"

#---GET JSON FROM EXISTING LIST AND EXPORT TO FILE THEN ADD TO EXISTING SITE DESIGN---
$jsonfile = "C:\filepath\filename.json"
Get-SPOSiteScriptFromList "https://domain.sharepoint.com/sites/sitename/lists/listname" | Out-File $jsonfile
#review and modify the json file
$sitescriptfile = Get-Content $jsonfile -Raw
$sitescript = Add-SPOSiteScript -Title "SITE SCRIPT NAME" -Content $sitescriptfile
$sitedesign = Get-SPOSiteDesign | where {$_.Title -eq "SITE DESIGN NAME"}
$existingsitescripts = New-Object System.Collections.ArrayList
$existingsitescripts = $sitedesign.SiteScriptIds | select -ExpandProperty Guid
$existingsitescripts.Add($sitescript.Id.ToString())
Set-SPOSiteDesign -Identity $sitedesign.Id -SiteScripts $existingsitescripts
