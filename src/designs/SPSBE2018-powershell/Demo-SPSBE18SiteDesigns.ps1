Connect-PnPOnline -Url https://yourtenant-admin.sharepoint.com

# TO ADD NEW SITE DESIGN
$contractDocSiteScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Contracts" }
Add-PnPSiteDesign -Title "SPSBE18 Demo Design" -SiteScriptIds $contractDocSiteScript.Id -WebTemplate TeamSite

# TO UPDATE EXISTING SITE DESIGN
$spsbe18SiteDesign = Get-PnPSiteDesign  | Where-Object { $_.Title -eq "SPSBE18 Demo Design"}
$themeScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Multicolored theme" }
Set-PnPSiteDesign -Identity $spsbe18SiteDesign.Id -SiteScriptIds $contractDocSiteScript.Id, $themeScript.Id

# TO LIST ALL SITE DESIGNS
Get-PnPSiteDesign

# TO REMOVE A SITE DESIGN
Remove-PnPSiteDesign -Identity $spsbe18SiteDesign.Id