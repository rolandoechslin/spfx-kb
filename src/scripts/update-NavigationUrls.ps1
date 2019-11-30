<#

.SYNOPSIS
 
    Update-NavigationUrls.ps1 - Mass updated SharePoint Online navigation urls. 
   
 
.DESCRIPTION
    Author: Matti Paukkonen

    This script allows you to mass update SharePoint Online navigation urls, for example after renaming a site.
    Script utilized PnP PowerShell module, which needs to be installed.

    
.LINK
    Blog: https://mattipaukkonen.com
    Twitter: http://www.twitter.com/mpaukkon
     

#>
Param (

    [Parameter(mandatory = $true)][string]$SiteUrl,
    [Parameter(mandatory = $true)][string]$OldUrl,
   [Parameter(mandatory = $true)][string]$NewUrl,
   [Parameter(mandatory = $true)][ValidateSet('TopNavigationBar', 'QuickLaunch')][string]$Location

)

Function Set-NavigationNode
{
    param($navNode)
   
    
    if($navNode.Children.Count -gt 0)
    {
        foreach($childNode in $navNode.Children)
        {
            Set-NavigationNode $childNode
        }
    }
    if($navNode.Url -match $OldUrl)
    {
     Write-Host "Updating navigation node:" -NoNewline -ForegroundColor Yellow
     Write-Host $navNode.Title -ForegroundColor Yellow
     Write-host $navNode.Url -ForegroundColor Yellow
     $navNode.Url = $navNode.Url.ToLower().Replace($OldUrl.ToLower(),$NewUrl.ToLower())
     $navNode.Update()
     
    }


}

Write-Host "Connecting to site: $SiteUrl" -ForegroundColor Yellow
Connect-PnPOnline $SiteUrl -UseWebLogin
$site = Get-PnPSite -ErrorAction SilentlyContinue
if($site -ne $null)
{
Write-Host "Connected" -ForegroundColor Green
$navigationNodes = Get-PnPNavigationNode -Location $Location
foreach($navigationNode in $navigationNodes)
{
    $node = Get-PnPNavigationNode -Id $navigationNode.Id
    Set-NavigationNode $node
}
Invoke-PnPQuery
Disconnect-PnPOnline

}
else
{
    Write-Host "Connection to site failed!" -ForegroundColor Red
}



