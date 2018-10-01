
# Get Ownerless groups
    $OwnerlessGroups =[array](Get-UnifiedGroup | 
    Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Owners)).Count -eq 0})

# Get Ownerless group count
    $OwnerlessGroups.count

# Get details about Ownerless groups
    $OwnerlessGroups

    $OwnerlessGroups| 
    Select DisplayName, ManagedBy, 
    alias

# Set Yourself as the Owner of the group or set another user as owner of the group
    
    for($i=0; $i -lt $OwnerlessGroups.Count; $i++)
    {
    Add-UnifiedGroupLinks $OwnerlessGroups.Alias -LinkType member -Links admin@M365x291009.onmicrosoft.com
    Add-UnifiedGroupLinks $OwnerlessGroups.Alias -LinkType Owner -Links admin@M365x291009.onmicrosoft.com
    }


    for($i=0; $i -lt $OwnerlessGroups.Count; $i++)
    {
    Add-UnifiedGroupLinks $OwnerlessGroups.Alias -LinkType member -Links adelev@M365x291009.onmicrosoft.com
    Add-UnifiedGroupLinks $OwnerlessGroups.Alias -LinkType Owner -Links adelev@M365x291009.onmicrosoft.com
    }


    Add-UnifiedGroupLinks G_Don -LinkType member -Links alexw@M365x291009.onmicrosoft.com
    Add-UnifiedGroupLinks G_Don -LinkType Owner -Links alexw@M365x291009.onmicrosoft.com


# Identify groups with members
    $OwnerlessGroups | 
    Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Member)).Count -ne 0}




# Send email to the group members

    $To =  'G_jd7_@M365x291009.onmicrosoft.com'
    $From = 'admin@M365x291009.onmicrosoft.com'
    $SmtpServer = 'smtp.office365.com'
    $SmtpPort = '587'
        $mail = @{
                    To = $To
                    From = $From
                    Subject = 'Your group does not have an owner. Please volunteer. '
                    Body = '<html><body><b>We have seen that your group does not have an owner. Request people to nominate yourself to be become the owner, so that you can manage the group easily.</b></body></html>'
                    SmtpServer = $SmtpServer
                    Port = $SmtpPort
                    Credential = $UserCredential 
    }
    Send-MailMessage @mail -usessl -BodyAsHtml
