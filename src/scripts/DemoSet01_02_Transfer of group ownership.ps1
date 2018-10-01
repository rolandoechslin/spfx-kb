
# Need to connect to AAD first

    Connect-AzureAD -Credential $UserCredential

# Get the list of owned Groups

    $UserOwnedObjects = Get-AzureADUser -SearchString adelev| Get-AzureADUserOwnedObject |  Where-Object {$_.ObjectType -eq "Group"}
    
    $UserOwnedGroups = @()
    for($i=0; $i -lt $UserOwnedObjects.Count; $i++)
    {
        $mbx = Get-UnifiedGroup $UserOwnedObjects[$i].ObjectId -ErrorAction SilentlyContinue
        if ( $mbx -ne $null )
        {
            $UserOwnedGroups += $mbx
        }
    } 

# Get the count of owned groups

    $UserOwnedGroups.Count

#Assign a new owner
    for($i=0; $i -lt $UserOwnedGroups.Count; $i++)
    {
        Add-UnifiedGroupLinks $UserOwnedGroups.Alias -LinkType member -Links AlexW@M365x291009.OnMicrosoft.com
        Add-UnifiedGroupLinks $UserOwnedGroups.Alias -LinkType Owner -Links AlexW@M365x291009.OnMicrosoft.com
    }

#Remove the previous owner from the group
    for($i=0; $i -lt $UserOwnedGroups.Count; $i++)
    {
        Remove-UnifiedGroupLinks –Identity $UserOwnedGroups.Alias –LinkType Owners –Links AdeleV@M365x291009.OnMicrosoft.com -Confirm:$false
        Remove-UnifiedGroupLinks –Identity $UserOwnedGroups.Alias –LinkType Members –Links AdeleV@M365x291009.OnMicrosoft.com -Confirm:$false
    }


# Delete the group if there are no members - its a soft-delete of group

    for($i=0; $i -lt $UserOwnedGroups.Count; $i++)
    {
    $OwnerCount = ([array](Get-UnifiedGroupLinks  $UserOwnedGroups[$i].Id -LinkType Owner)).Count
    $MemberCount = ([array](Get-UnifiedGroupLinks  $UserOwnedGroups[$i].Id -LinkType Member)).Count
    if (($OwnerCount -eq 1) -and ($MemberCount -eq 0))
    {
    Remove-UnifiedGroup $UserOwnedGroups[$i].Alias
    }
    } 

