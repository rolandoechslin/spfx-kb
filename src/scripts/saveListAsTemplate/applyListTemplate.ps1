$siteURL =  "https://contoso.sharepoint.com/sites/hr"
$templateName = "listTemplate"

$path = [regex]::Replace($MyInvocation.MyCommand.Definition, "\\applyListTemplate.ps1", "")
cd $path

Connect-PnPOnline -Url $siteURL

Apply-PnPProvisioningTemplate -Path ("{0}.xml" -f $templateName)



