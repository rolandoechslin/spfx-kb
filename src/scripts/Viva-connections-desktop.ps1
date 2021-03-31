Write-Host "Welcome to Viva Connections desktop! This script will generate a Teams app package that will allow you to pin your SharePoint intranet in Teams."
Write-Host "Please ensure you have SharePoint admin privileges in your tenant before running this script."
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -MinimumVersion 16.0.20324.12000 -Force

# Get SharePoint Portal link from user
[uri]$configUrl = Read-Host -Prompt 'Enter the link of the SharePoint portal that you want to pin in Teams. Please ensure that it is a modern Communication site. We recommend that you use a Home Site'
[string]$domain = $configUrl.Host
$hostElement = $domain.Split(".")[0]

# Validating siteUrl
try{
    write-Host "Validating...."
    Connect-SPOService -Url https://$hostElement-admin.sharepoint.com
    $result = Get-SPOIsCommSite -SiteUrl $configUrl

    if ($result.Value) {
        write-Host "Current user has permission. Proceeding with app creation"
    }
    else {
        Write-host "The app cannot be created. Please ensure the site link provided is a modern SharePoint Communication site and you have admin privileges to SharePoint in your tenant."
        Throw
    }
} catch {
    Write-host "The app cannot be created. Please ensure the site link provided is a modern SharePoint Communication site and you have admin privileges to SharePoint in your tenant."
    Throw
}

## Search Info
$searchSiteVariable = '';
$searchUrlPath = $domain;

if ($configUrl.LocalPath -match '/teams' -or $configUrl.LocalPath -match '/sites') {
    $searchSiteVariable = '/siteall';
    if ($configUrl.LocalPath -match '^\/[^\/]+\/[^\/]+') { $searchUrlPath = $domain + $Matches[0]; }
}
$searchUrl = "https://$searchUrlPath/_layouts/15/search.aspx$searchSiteVariable" + 'q={searchQuery}'

# Get the Name of the App
$appname = Read-Host -Prompt 'Please enter the name of your app, as you want it to appear in Teams'
while([string]::IsNullOrEmpty($appname)){     
     Write-Output "App Name cannot be empty."
     $appname = Read-Host -Prompt 'Please enter the name of your app, as you want it to appear in Teams'
}

# Get the Short description
$shortDescription = Read-Host -Prompt 'Please enter short description for the app (less than 80 characters)'
while ($shortDescription.length -gt 80) {
    Write-Output "short description entered is greater than 80 characters,"
    $shortDescription = Read-Host -Prompt 'Please enter short description for the app (less than 80 characters)'
}

# Get the Long description
$longDescription = Read-Host -Prompt 'Please enter long description for the app (less than 4000 characters)'
while ($longDescription.length -gt 4000) {
    Write-Output "long description entered is greater than 4000 characters,"
    $longDescription = Read-Host -Prompt 'Please enter long description for the app (less than 4000 characters)'
}

# Get the Privacy Policy link
$PrivacyPolicyUrl = Read-Host -Prompt 'Provide a privacy policy link for the app. Press Enter if you want to use default privacy policy from Microsoft'
if([string]::IsNullOrEmpty($PrivacyPolicyUrl)){   
     Write-Output "Link not provided, adding Microsoft privacy link"  
     $PrivacyPolicyUrl = 'https://privacy.microsoft.com/en-us/privacystatement'
}

# Get the Terms and Usage Policy Link
$TermsOfUseUrl = Read-Host -Prompt 'Provide a Terms of Use link for the app. Press Enter if you want to use default Terms of Use from Microsoft'
if([string]::IsNullOrEmpty($TermsOfUseUrl)){
     Write-Output "Link not provided, adding Microsoft Terms Of Use link" 
     $TermsOfUseUrl = 'https://go.microsoft.com/fwlink/?linkid=2039674'
}

# Get the Company Name
$companyName = Read-Host -Prompt "Provide your organization's name"  #add
if([string]::IsNullOrEmpty($companyName)){
     Write-Output "Organization's name not provided, adding name as Microsoft Corp"  
     $companyName = 'Microsoft Corp'
}

# Get the Company Website
$companyWebsite = Read-Host -Prompt "Provide your organization's public website link"
if([string]::IsNullOrEmpty($companyWebsite)){
     Write-Output "Organization's public website link not provided, adding Microsoft's URL" 
     $companyWebsite = 'https://go.microsoft.com/fwlink/?linkid=868076'
}

#Adding query param with app=portal
if ($ConfigUrl -contains '`?') {
   [uri]$finalconfigUrl = $configUrl.ToString() + '&app=portals'
} 
else {
   [uri]$finalconfigUrl = $configUrl.ToString() + '?app=portals'
}
#Write-Host "Company Portal: '$finalConfigUrl'"

# Generate random GUID
$guid = [System.Guid]::NewGuid()
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Get the color and outline icon paths from user
Function Get-FileName($windowTitle)
{
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $windowTitle
    $OpenFileDialog.InitialDirectory = $DesktopPath
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    # Out-Null supresses the "OK" after selecting the file.
    $OpenFileDialog.ShowDialog() | Out-Null
    return $OpenFileDialog.FileName
}
Write-Host "Please upload colored-icon[192x192]px"
$color = Get-FileName("Please upload colored-icon[192x192]px")
$color_filename = Split-Path $color -leaf
Write-Host "Please upload outline-icon[32x32]px"
$outline = Get-FileName("Please upload outline-icon[32x32]px")
$outline_filename = Split-Path $outline -leaf
Write-Host "Selected icons paths, color icon path: '$color' Outline-icon path: '$outline'"

#https://developer.microsoft.com/en-us/json-schemas/teams/v1.8/MicrosoftTeams.schema.json
#https://raw.githubusercontent.com/OfficeDev/microsoft-teams-app-schema/preview/DevPreview/MicrosoftTeams.schema.json
# Json object
$json = @"
{
  "`$schema": "https://developer.microsoft.com/en-us/json-schemas/teams/v1.9/MicrosoftTeams.schema.json",
  "manifestVersion": "1.9",
  "version": "1.0",
  "id": "$guid",
  "packageName": "com.microsoft.teams.$appname",
  "developer": {
    "name": "$companyName",
    "websiteUrl": "$companyWebsite",
    "privacyUrl": "$PrivacyPolicyUrl",
    "termsOfUseUrl": "$TermsOfUseUrl"
  },
  "icons": {
    "color": "$color_filename",
    "outline": "$outline_filename"
  },
  "name": {
    "short": "$appName",
    "full": "$appName"
  },
  "description": {
    "short": "$shortDescription",
    "full": "$longDescription"
  },
  "accentColor": "#40497E",
  "isFullScreen": true,
  "staticTabs": [
        {
            "entityId": "sharepointportal_$guid",
            "name": "Portals-$appName",
            "contentUrl": "https://$domain/_layouts/15/teamslogon.aspx?spfx=true&dest=$finalconfigUrl",
            "websiteUrl": "$configUrl",
            "searchUrl": "https://$searchUrlPath/_layouts/15/search.aspx?q={searchQuery}",
            "scopes": ["personal"],
            "supportedPlatform" : ["desktop"]
        }
    ],
  "permissions": [
    "identity",
    "messageTeamMembers"
  ],
  "validDomains": [
    "$domain",
    "*.login.microsoftonline.com",
    "*.sharepoint.com",
    "*.sharepoint-df.com",
    "spoppe-a.akamaihd.net",
    "spoprod-a.akamaihd.net",
    "resourceseng.blob.core.windows.net",
    "msft.spoppe.com"
  ],
  "webApplicationInfo": {
    "id": "00000003-0000-0ff1-ce00-000000000000",
    "resource": "https://$domain"
  }
}
"@

$tempPath = [System.IO.Path]::GetTempPath()
$manifestPath = $tempPath + '\manifest.json'

#Writing content to manifest file in temp location
Set-Content -Path $manifestPath $json

# Creating zip file
Compress-Archive -DestinationPath $DesktopPath\$appName.zip -Force -LiteralPath $manifestPath,$color,$outline -CompressionLevel Optimal
Write-Host "Your Viva Connections desktop app has been successfully created! Please find the app manifest in location '$DesktopPath', filename '$appName'.zip."
Write-Host "Please upload this app in Teams Admin Center to proceed."
