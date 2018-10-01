#Graph Display name change
GET https://graph.microsoft.com/v1.0/groups/643abf91-7a8f-4045-b548-3cf2af7f416f


PATCH https://graph.microsoft.com/v1.0/groups/643abf91-7a8f-4045-b548-3cf2af7f416f
    {
      "displayName": "G_Franklin_MS_Ignite"

    }

#Get the unified group details
    Get-UnifiedGroup kumudinigroup  | Select DisplayName, Alias, PrimarySMTPAddress

#Update the SMTP address and Display name of the group as well as alias
    Set-UnifiedGroup kumudinigroup -PrimarySmtpAddress mikesgroup@M365x291009.onmicrosoft.com -DisplayName "Mike's Group" -alias "mikesgroup"

# Get the unified group details
Get-UnifiedGroup kumudinigroup| Select DisplayName, Alias, PrimarySMTPAddress

Get-UnifiedGroup mikesgroup| Select DisplayName, Alias, PrimarySMTPAddress


#Update the SMTP address and Display name of the group as well as alias
Set-UnifiedGroup mikesgroup -PrimarySmtpAddress kumudinigroup@M365x291009.onmicrosoft.com -DisplayName "Kumudini's Group" -alias "kumudinigroup"