#Read more: http://www.sharepointdiary.com/2018/03/sharepoint-online-get-all-features-using-powershell.html#ixzz5gW6rk2R4

# ========================================================================
# This PowerShell script gets all active features of a given URL's site and web scopes.
# ========================================================================

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Variables
$SiteURL = "https://crescenttech.sharepoint.com"
 
#Setup Credentials to connect
#$Cred= Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
 
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = $Credentials
 
#Get Site Collection Features
$SiteCollFeatures = $Ctx.Site.Features
$Ctx.Load($SiteCollFeatures)
$Ctx.ExecuteQuery()

#Loop through each feature and get feature data
Write-host "Site Collection Features:"
ForEach ($Feature in $SiteCollFeatures) {
    $Feature.Retrieve("DisplayName")
    $Ctx.Load($Feature)
    $Ctx.ExecuteQuery()
    $Feature | Select-Object DisplayName, DefinitionId
}

# ========================================================================
# Here is the PowerShell to get SharePoint online features at web scope.
# ========================================================================

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Variables
$SiteURL = "https://crescenttech.sharepoint.com"
 
#Setup Credentials to connect
$Cred = Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
 
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = $Credentials
 
#Get Web Level Features
Write-host "`nWeb Scoped Features:"
#Get web Features
$WebFeatures = $Ctx.Web.Features
$Ctx.Load($WebFeatures)
$Ctx.ExecuteQuery()

#Loop through each feature and get feature data
ForEach ($Feature in $WebFeatures) {
    $Feature.Retrieve("DisplayName")
    $Ctx.Load($Feature)
    $Ctx.ExecuteQuery()
    $Feature | Select-Object DisplayName, DefinitionId
}
