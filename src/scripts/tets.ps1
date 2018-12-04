param (
    $mycreds
)
# Need to set_executionpolicy for this file
# Need to download pnp powershell from https://github.com/SharePoint/PnP-PowerShell/releases
# If you are running PowerShell side by side, then run this statement (as per https://www.erwinmcm.com/running-the-various-versions-of-pnp-powershell-side-by-side/)

# Original: https://raw.githubusercontent.com/kevmcdonk/Mcd79SharePointScripts/master/CreateTeamSiteWithCustomModernPage.ps1

import-module C:\SourceCode\Tools\PnPPowerShell\SharePointPnPPowerShellOnline\3.2.1810.0\SharePointPnPPowerShellOnline.psd1 -DisableNameChecking

$sharePointHome = "https://yourtenant.sharepoint.com" 
$tenantSitesUrl = "https://yourtenant.sharepoint.com/sites/"
$adminSiteUrl = "https://yourtenant-admin.sharepoint.com"
$stockImageSite = "StockImages"
$ownerEmail = "an.account@yourtenant.com"

$departmentName = "Ops"
$departmentDisplayName = "Operations"
$bannerImageUrl = "/sites/StockImages/Photos/stormtrooper.jpg"

function SetBannerImage{
    param(
        [string]$pageName,
        [string]$bannerImageLink,
        [string]$departmentName
    )
    
    $stockImageUrl = $tenantSitesUrl + $stockImageSite
    Write-Output "Banner Image - Connecting to stock images at $stockImageUrl"
    Connect-PnPOnline $stockImageUrl -Credentials $mycreds
    $bannerImageItem = Get-PnPFile -Url $bannerImageLink -AsListItem
    $bannerImageId = $bannerImageItem["UniqueId"]
    Write-Output "Banner Image - Banner image item: $bannerImageItem"

    $siteUrl = $tenantSitesUrl + $BranchName + "/" + $departmentName
    Connect-PnPOnline $siteUrl -Credentials $mycreds
    Write-Output "Banner Image - Connecting to department site"
    $page = Get-PnPClientSidePage $pageName
    $layoutWebPartsText = $page.PageListItem["LayoutWebpartsContent"]
    
    $layoutWebPartsXml = New-Object -TypeName XML
    $layoutWebPartsXml.LoadXml($layoutWebPartsText)
    $controlDataText = $layoutWebPartsXml.ChildNodes[0].ChildNodes[0].Attributes["data-sp-controldata"]
    $controlData = ConvertFrom-Json -InputObject $controlDataText.'#text'
    $controlData.serverProcessedContent.imageSources | Add-Member imageSource $bannerImageLink -Force
    $controlData.properties | Add-Member uniqueId $bannerImageId -Force
    $controlData.properties | Add-Member imageSourceType 2 -Force
    $controlDataTextUpdated = ConvertTo-Json -InputObject $controlData
    $layoutWebPartsXml.ChildNodes[0].ChildNodes[0].Attributes["data-sp-controldata"].Value = $controlDataTextUpdated
    $page.PageListItem["LayoutWebpartsContent"] = $layoutWebPartsXml.OuterXml
    $page.PageListItem.Update()
    $ctx = Get-PnPContext
    $ctx.Load($page.PageListItem)
    $ctx.ExecuteQuery()
    Write-Output "Banner Image - Completed"
}

function ProcessDepartmentSite{
    param(
        [string]$departmentName,
        [string]$bannerImageUrl
    )
    Write-Output "Process Department Site - Connecting to department site"
    $siteUrl = $tenantSitesUrl + $departmentName

    
    $homePageUrl = "SitePages/home.aspx"
    Set-PnPWeb -Title "$departmentDisplayName"
    Write-Output "Process Department Site - remove current homepage"
    $removedFile = Remove-PnPFile -SiteRelativeUrl $homePageUrl -Force
    Write-Output "Process Department Site - Add new homepage"
    $newHomepage = Add-PnPClientSidePage -Name "Home" -LayoutType Article
    
    Write-Output "Process Department Site - Retrieve Property Home Page content type"
    $homepage = Get-PnPClientSidePage -Identity Home
    Write-Output "Process Department Site - Connecting to department site"
    $homepage.Sections.Clear()

    Write-Output "Process Department Site - Add web parts"
    Add-PnPClientSidePageSection -Page Home -SectionTemplate TwoColumnLeft

    Add-PnPClientSideWebPart -Page Home -DefaultWebPartType ContentRollup -Section 1 -Column 1
    $ctx = Get-PnPContext
    $web = Get-PnPWeb
    $ctx.Load($web.RootFolder)
    $web.RootFolder.WelcomePage = "sitepages/Home.aspx"
    $web.RootFolder.Update()
    $ctx.ExecuteQuery()

    Write-Output "CreateHomepage-6 - Get documents list"
    $documentsList = Get-PnPList -Identity "Documents"
    Add-PnPClientSideWebPart -Page Home -DefaultWebPartType List -Section 1 -Column 2 -Order 1 -WebPartProperties @{"isDocumentLibrary"=$true;"selectedListId"=$documentsList.Id;"listTitle"=$documentsList.Title;"selectedListUrl"=$documentsList.RootFolder.ServerRelativeUrl;"webpartHeightKey"=4}
    SetBannerImage -pageName "Home" -bannerImageLink $bannerImageUrl -departmentName $departmentName
}

function CreateTeamSite{
    Write-Output "CreateTeamSite1 - Creating Team Site"
    Connect-PnPOnline -Url $sharePointHome -Credentials $mycreds
    $DepartmentUrl = $tenantSitesUrl + $departmentName
    Write-Output "CreateTeamSite1 - Creating site $DepartmentUrl"
    #New-PnPSite -Type TeamSite -Title $departmentDisplayName -Alias $departmentName
    Connect-PnPOnline $DepartmentUrl -Credentials $mycreds
    # If needed, add additional admins
    # Add-PnPSiteCollectionAdmin -Owners @("another.user@yourtenant.com", $ownerEmail)
}

$branchSiteUrl = $tenantSitesUrl + $BranchName
Write-Output "0 - Applying branch template to $branchSiteUrl"

Write-Output "1 - Retrieving credentials"
$mycreds
if ($null -eq $mycreds) {
    $mycreds = Get-Credential
}

CreateTeamSite
ProcessDepartmentSite -departmentName $departmentName -bannerImageUrl $bannerImageUrl