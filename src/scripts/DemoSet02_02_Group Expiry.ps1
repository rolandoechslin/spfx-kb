# Groups that are expiring
  
    $ExpiringGroups = Get-UnifiedGroup | Where-Object {$_.ExpirationTime -ne $null} | Where-Object {($_.ExpirationTime - (Get-Date)).TotalDays -le 180} | select Alias, DisplayName, AccessType, ExpirationTime


# Count the ownerless expiring groups
    $ExpiringGroups.count


#Get the expiring groups details


# Get one group

Get-UnifiedGroup G_jd7_ | fl *ExternalDirectoryObjectId*


# Get the ExternalDirectory Object Id of the groups
    for($i=0; $i -lt $ExpiringGroups.Count; $i++)
    {
    $objectIdForRenew = Get-UnifiedGroup  $ExpiringGroups[$i].alias | Select ExternalDirectoryObjectId
    Write-Host “External object ID for the expiring group ” $ExpiringGroups[$i].DisplayName "is: " $objectIdForRenew.ExternalDirectoryObjectId
    }



#Get groups that are expiring as well as ownerless
    $OwnerlessExpiringGroups =[array](Get-UnifiedGroup | Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Owners)).Count -eq 0}) | Where-Object {$_.ExpirationTime -ne $null} | Where-Object {($_.ExpirationTime - $now).TotalDays -le 30} | select Alias, DisplayName, AccessType, ExpirationTime


# Renew through MS Graph
# Go to Graph explorer
# Sign in

#Renew the groups through MS Graph 
# POST https://graph.microsoft.com/v1.0/groups/3c2e3bff-54c1-497e-9eeb-b97e999c8b6d/renew 
# POST https://graph.microsoft.com/v1.0/groups/{Group ExternalDirectory Object ID}/renew 

#  $Now = Get-Date