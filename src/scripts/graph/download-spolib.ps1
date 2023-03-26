# SOurce: https://sposcripts.com/how-to-download-a-sharepoint-library-using-graph/
# Script to download a SharePoint Library using Graph
# Author: Serkar Aydin - Serkar@sposcripts.com
# Accept input parameters
Param (
    $Tenant = "m365x69801090",
    $AppID = "333d169e-7f2d-417c-b349-8498b2248802",
    $SiteID = "74667e94-9fcf-41ab-8e2f-0dfaf0294de8",
    $LibraryURL = "https://m365x69801090.sharepoint.com/sites/Retail/Shared%20Documents",
    $Path = "C:\Users\Serkar\Desktop\Retail"
)

Function DownloadDriveItem {

    param(
        $DriveItem,
        $URL,
        $Header,
        $Path
        
    )
    
    #if there is no downloadurl, it is a folder
    If (!$DriveItem. '@microsoft.graph.downloadUrl') {
    
        Write-Output "Downloading the folder $($DriveItem.weburl)"
    
        #Create a folder for the SharePoint folder
        $FolderPath = "$Path\$($DriveItem.name)"
        New-Item -ItemType Directory -Path $FolderPath | Out-Null

        $Url  = "https://graph.microsoft.com/v1.0/drives/$DriveID/items/$($DriveItem.ID)/children"
        $Response =  Invoke-RestMethod -Uri $Url -Headers $Header -Method Get -ContentType 'multipart/form-data' 

        $Response.value | ForEach-Object {

            DownloadDriveItem -DriveItem $_ -URL $Url -Header $Header -Path $FolderPath

        }

    }

    #Else it is a file
    Else{
    
        Write-Output "Downloading the file $($DriveItem.weburl)"
        Invoke-WebRequest -Uri $DriveItem.'@microsoft.graph.downloadUrl' -OutFile "$Path\$($DriveItem.name)"
    }
}


# Prompt for application credentials
$AppCredential = Get-Credential($AppID)

#region authorize

# Set the scope for the authorization request
$Scope = "https://graph.microsoft.com/.default"

# Build the body of the authorization request
$Body = @{
    client_id = $AppCredential.UserName
    client_secret = $AppCredential.GetNetworkCredential().password
    scope = $Scope
    grant_type = 'client_credentials'
}

# Build the URL for the authorization request
$GraphUrl = "https://login.microsoftonline.com/$($Tenant).onmicrosoft.com/oauth2/v2.0/token"

# Send the authorization request and retrieve the access token
$AuthorizationRequest = Invoke-RestMethod -Uri $GraphUrl -Method "Post" -Body $Body
$Access_token = $AuthorizationRequest.Access_token

# Build the header for API requests
$Header = @{
    Authorization = $AuthorizationRequest.access_token
    "Content-Type"= "application/json"
}

#endregion

#region get drives

# Build the URL to retrieve the list of drives in the SharePoint site
$GraphUrl = "https://graph.microsoft.com/v1.0/sites/$SiteID/drives"

# Convert the body of the authorization request to JSON and send the API request
$BodyJSON = $Body | ConvertTo-Json -Compress
$Result = Invoke-RestMethod -Uri $GraphUrl -Method 'GET' -Headers $Header -ContentType "application/json"

# Find the ID of the specified SharePoint library
$DriveID = $Result.value| Where-Object {$_.webURL -eq $LibraryURL } | Select-Object id -ExpandProperty id

# If the SharePoint library cannot be found, throw an error
If ($DriveID -eq $null){
    Throw "SharePoint Library under $LibraryURL could not be found."
}

#endregion

#region create folder. If there is already one, replace it with the new folder

Try {

    New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null
}
Catch {

        Remove-Item $Path -Force -Recurse
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
}
#endregion

#region download library

$Url  = "https://graph.microsoft.com/v1.0/drives/$DriveID/root/children"
$Response =  Invoke-RestMethod -Uri $Url -Headers $Header -Method Get -ContentType 'multipart/form-data' 

$Response.value | ForEach-Object {

    DownloadDriveItem -DriveItem $_ -URL $Url -Header $Header -Path $Path

}

#endregion