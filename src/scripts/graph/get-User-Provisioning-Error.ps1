#Requires -Version 3.0
# Make sure to fill in all the required variables before running the script
# Also make sure the AppID used corresponds to an app with sufficient permissions, as follows:
#    Group.Read.All or Directory.Read.All to read all Groups

#Variables to configure

$tenantID = "tenant.onmicrosoft.com" #your tenantID or tenant root domain
$appID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" #the GUID of your app.
$client_secret = "verylongsecurestring" #client secret for the app

#==========================================================================
#Main script starts here
#==========================================================================

#Obtain access token
$url = 'https://login.microsoftonline.com/' + $tenantId + '/oauth2/v2.0/token'

$Scopes = New-Object System.Collections.Generic.List[string]
$Scope = "https://graph.microsoft.com/.default"
$Scopes.Add($Scope)

$body = @{
    grant_type = "client_credentials"
    client_id = $appID
    client_secret = $client_secret
    scope = $Scopes
}

try { 
    Set-Variable -Name authenticationResult -Scope Global -Value (Invoke-WebRequest -Method Post -Uri $url -Debug -Verbose -Body $body)
    $token = ($authenticationResult.Content | ConvertFrom-Json).access_token
}
catch { $_; return }

if (!$token) { Write-Host "Failed to aquire token!"; return }
else {
    Write-Verbose "Successfully acquired Access Token"
        
    #Use the access token to set the authentication header
    Set-Variable -Name authHeader -Scope Global -Value @{'Authorization'="Bearer $token";'Content-Type'='application\json'}
}

#Use the /beta endpoint to fetch a list of all users
$uri = 'https://graph.microsoft.com/beta/users?$select=id,userPrincipalName,serviceProvisioningErrors'
$gr = Invoke-WebRequest -Headers $authHeader -Uri $uri -Verbose -Debug
$result = ($gr.Content | ConvertFrom-Json).value
 
#Filter only the users with errors
$err = $result | Where-Object {$_.serviceProvisioningErrors}
 
#Human-readable output
$err | Select-Object userPrincipalName, @{n="Errors";e={ ([xml]$_.serviceProvisioningErrors.errorDetail).ServiceInstance.ObjectErrors.ErrorRecord.ErrorDescription } }
