# Source: https://www.devjhorst.com/2019/12/copy-files-between-microsoft-teams-using-microsoft-graph.html

function ProvisionDocumentAsTeamTab {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceTeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetTeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Filename
    )

    $accessToken = Get-GraphAccessToken -ClientId $ClientId

    $sourceTeam = Get-TeamById -AccessToken $accessToken -TeamId $SourceTeamId
    if ($sourceTeam -eq $null) {
        throw "Source team not found."
    }

    $targetTeam = Get-TeamById -AccessToken $accessToken -TeamId $TargetTeamId
    if ($targetTeam -eq $null) {
        throw "Target team not found."
    }
    
    $targetChannel = Get-ChannelByName -AccessToken $accessToken -TeamId $TargetTeamId -ChannelName 'General'

    $sourceFile = Search-FileByName -AccessToken $accessToken -TeamId $SourceTeamId -Filename $Filename
    $sourceFileContent = Download-File -AccessToken $accessToken -TeamId $SourceTeamId -FileId $sourceFile.id

    $targetFile = Upload-File -AccessToken $accessToken -TeamId $TargetTeamId -Filename $Filename -FileContent $sourceFileContent
    $tabPayload = Build-TabPayload -File $targetFile

    Create-Tab -AccessToken $accessToken -TeamId $TargetTeamId -ChannelId $targetChannel.id -Payload $tabPayload[1]  
}

function Get-TeamById {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId
    )

    $requestUrl = -join('https://graph.microsoft.com/v1.0/teams/', $TeamId)
    return Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $requestUrl -Method Get
}

function Get-ChannelByName {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ChannelName
    )

    $requestUrl = -join('https://graph.microsoft.com/v1.0/teams/', $TeamId, '/channels')
    $response = Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $requestUrl -Method Get
    $channels = ($response | select-object Value).Value[0]
    return $channels | where-object displayName -Match $ChannelName
}

function Search-FileByName {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Filename
    )

    $requestUrl = -join("https://graph.microsoft.com/v1.0/groups/", $TeamId, "/drive/root/search(q='", $Filename, "')")
    $files = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $requestUrl -Method Get
    return ($files | select-object Value).Value[0]
}

function Download-File {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FileId
    )

    $requestUrl = -join('https://graph.microsoft.com/v1.0/groups/', $TeamId, '/drive/items/', $FileId)
    $response = Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $requestUrl -Method Get
    $downloadUrl = $response | select-object "@microsoft.graph.downloadUrl"

    return Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $downloadUrl.'@microsoft.graph.downloadUrl' -Method Get
}

function Upload-File {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Filename,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $FileContent
    )

    $requestUrl = -join('https://graph.microsoft.com/v1.0/groups/', $TeamId, '/drive/root:/General/', $Filename,':/content')
    return Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $requestUrl -Method Put -Body $FileContent
}

function Build-TabPayload {
    param
    (
        [Parameter(Mandatory = $true)]
        #[ValidateNotNullOrEmpty()]
        $File,

        [Parameter(Mandatory = $false)]
        [string]$TeamsAppId = 'com.microsoft.teamspace.tab.file.staticviewer.pdf'
    )

    $File.'@microsoft.graph.downloadUrl' -match 'UniqueId=(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}'
    $uniqueId = $Matches[0].Split('=')[1]

    return @{
        'displayName' = $File.name.Split('.')[0]
        'teamsApp@odata.bind' = -join("https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/", $TeamsAppId)
        'configuration' = @{
             'entityId' = $uniqueId.ToUpper()
             'contentUrl' = [System.Web.HttpUtility]::UrlDecode($File.webUrl)
             'removeUrl' = $null
             'websiteUrl' = $null
          }
    }
}

function Create-Tab {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ChannelId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Payload
    )

    $requestUrl = -join('https://graph.microsoft.com/v1.0/teams/', $TeamId, '/channels/', $ChannelId, '/tabs')
    Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri $requestUrl -Method Post -Body ($Payload|ConvertTo-Json) -ContentType "application/json"
}

function Get-GraphAccessToken {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory = $false)]
        [string]$RedirectUri = 'https://localhost/',

        [Parameter(Mandatory = $false)]
        [string]$ResourceURI = 'https://graph.microsoft.com',

        [Parameter(Mandatory = $false)]
        [string]$Authority = 'https://login.microsoftonline.com/common'
    )
    
    # Checks if prerequisite is fulfilled.
    try 
    {
        $AadModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru
    }
    catch 
    {
        throw 'Prerequisites not installed (AzureAD PowerShell module not installed)'
    }

    $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $Authority

    # Gets token by prompting login window.
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
    $authResult = $authContext.AcquireTokenAsync($ResourceURI, $ClientID, $RedirectUri, $platformParameters)

    return $authResult.result.AccessToken
}