Write-Host "Type your tenant name:"

$tenenatName = Read-Host 
$templateName = "To Do"
$templateDescription = "To Do is a task management list to help you stay organized and manage your day-to-day." 
$templateIconName = "ClipboardList"
$templateColorName = "Blue" 
$templateThumbnail = "https://handsontek.net/images/Lists/Templates/ToDoThumbnail.png"

Connect-SPOService -url ("https://{0}-admin.sharepoint.com" -f $tenenatName)

$listTemplate = Get-Content -path '.\ToDoList.json' -Raw

$siteScript = Add-SPOSiteScript -Title $templateName -Description $templateDescription -Content $listTemplate 

Add-SPOListDesign -Title $templateName -Description $templateDescription -SiteScripts $siteScript.Id -ListColor $templateColorName -ListIcon $templateIconName -Thumbnail $templateThumbnail 
  