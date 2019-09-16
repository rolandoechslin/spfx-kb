$siteURL = "https://contoso.sharepoint.com/sites/hr"
$listName = "listName"
$templateName = "listTemplate"

$path = [regex]::Replace($MyInvocation.MyCommand.Definition, "\\saveListTemplate.ps1", "")
cd $path

Connect-PnPOnline -Url $siteURL
Get-PnPProvisioningTemplate -Handlers Lists -ListsToExtract $listName -Out ("{0}.xml" -f $templateName)
Add-PnPDataRowsToProvisioningTemplate -path ("{0}.xml" -f $templateName) -List $listName -Query '<view></view>'

