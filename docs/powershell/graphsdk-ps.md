# Graph SDK Powershell

- [Microsoft Graph PowerShell SDK](https://github.com/microsoftgraph/msgraph-sdk-powershell)

## Learning 

- [Get to know the Microsoft Graph PowerShell SDK better with the Graph Explorer](https://github.com/tomwechsler/Microsoft_Graph/blob/main/Learning_Tutorials/01_Graph_explorer_and_powershell.md)
- [Microsoft PowerShell Graph SDK – Woes](https://helloitsliam.com/2022/12/21/microsoft-powershell-graph-sdk-woes/)
- [Pluralsight: Using the Microsoft Graph PowerShell SDK](https://app.pluralsight.com/library/courses/microsoft-graph-powershell-sdk/table-of-contents)

## Security

- [Using a Certificate for Authentication with the Microsoft Graph SDK for PowerShell](https://practical365.com/use-certificate-authentication-microsoft-graph-sdk/)

## Azure Automation

- [Using Azure Automation to Process Exchange Online Data with PowerShell](https://practical365.com/use-azure-automation-exchange-online/)
- [Using the Microsoft Graph SDK for PowerShell with Azure Automation](https://practical365.com/microsoft-graph-sdk-powershell-azure-automation/)
- [Updating Microsoft Graph PowerShell Modules for Azure Automation](https://practical365.com/update-graph-sdk-azure-automation/) 

## Uddate Process

- [Updating Microsoft Graph PowerShell Modules for Azure Automation](https://practical365.com/update-graph-sdk-azure-automation/)

## Work

- [How to Connect to Microsoft Graph API from PowerShell](https://www.sharepointdiary.com/2023/04/how-to-connect-to-microsoft-graph-api-from-powershell.html)

Check

```Powershell
Get-InstalledModule | Where-Object {$_.Name -match "Microsoft.Graph"}
```

Install

```Powershell
Install-Module -Name "Microsoft.Graph"
```

Update

```Powershell
Update-Module Microsoft.Graph
```

Uninstall (all)

```Powershell
Uninstall-Module Microsoft.Graph

# Uninstall all Sub-modules of Graph
Get-InstalledModule Microsoft.Graph.* | ForEach-Object { if($_.Name -ne "Microsoft.Graph.Authentication") {
    Uninstall-Module $_.Name }
}
 
# Uninstall the dependant module
Uninstall-Module Microsoft.Graph.Authentication
```

Connect with Delegated Access 

```Powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"
 
# Get All users
$users = Get-MgUser
$users | Select-Object DisplayName, UserPrincipalName, Mail
```

Connect with App ID and Certificate

```Powershell
# App Config
$TenantID = "<placeholder>"
$ClientID = "<placeholder>" # App ID
$CertThumbPrint = "<placeholder>"
 
# Connect to Microsoft Graph using App
Connect-MgGraph -ClientID $ClientID -TenantId $TenantID -CertificateThumbprint $CertThumbPrint
```

Connect with Client Secret

```Powershell
# App Registration details
$TenantID = "<placeholder>"
$ClientID = "<placeholder>"
$ClientSecret = "<placeholder>"
 
$Body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}
 
$Connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token `
    -Method POST `
    -Body $body
 
# Get the Access Token
$Token = $Connection.access_token
 
# Connect to Microsoft Graph
Connect-MgGraph -AccessToken $Token
```

## Check Size

- [FUNCTION CANNOT BE CREATED BECAUSE FUNCTION CAPACITY 4096 HAS BEEN EXCEEDED FOR THIS SCOPE](https://evotec.xyz/function-cannot-be-created-because-function-capacity-4096-has-been-exceeded-for-this-scope/)

```ps
Get-Variable Max*Count
```

```ps
$Modules = Get-Module -ListAvailable
$ListModules = foreach ($Module in $Modules) {
    [PScustomObject] @{
        Name          = $Module.Name
        Version       = $Module.Version
        FunctionCount = ($Module.ExportedFunctions).Count
    }
}
$ListModules | Sort-Object -Property FunctionCount -Descending | Format-Table -AutoSize
```

##  AzureAD Module Migration

- [PSAzureMigrationAdvisor](https://github.com/FriedrichWeinmann/PSAzureMigrationAdvisor)
- [Challenges of PowerShell Scripting with Microsoft 365](https://practical365.com/challenges-of-powershell-scripting-with-microsoft-365/)





