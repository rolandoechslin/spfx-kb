#
# Considering the performance, adding the account to site collection admin should be better workaround. 
# Source: https://github.com/Chunlong101/SharePointScripts/blob/b54b8b1282c0185602634695248c456f0fa67a58/AddUserReadPermissionForAllSitesLists.ps1
#

$tenantName = "xxxx"

$userName = "xxx@zzz"

$ErrorActionPreference = "Stop"

$cred = Get-Credential

Function GetUniquePermissionsLists ($Web) {  
    $lists = @() 

    try {
        $listColl = Get-PnPList -Web $web -Includes HasUniqueRoleAssignments  
       
        foreach ($list in $listColl) {    
            if ($list.HasUniqueRoleAssignments) {  
                $lists += $list
            }        
        } 
    }
    catch {
        Write-Host $_ -ForegroundColor Red 
    }

    return $lists
}  
  
Function GetRootWeb() {  
    $web = $null 

    try {
        $web = Get-PnPWeb 
    } 
    catch {
        Write-Host $_ -ForegroundColor Red
    } 

    return $web
}  
  
Function GetSubWebs() {  
    $webs = $null 

    try {
        $webs = Get-PnPSubWebs -Recurse 
    } 
    catch {
        Write-Host $_ -ForegroundColor Red
    } 

    return $webs
}  
 
Function CheckIfWebHasUniquePermission ($Web) {
    $result = $false

    try {
        $result = Get-PnPProperty -ClientObject $Web -Property HasUniqueRoleAssignments
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    }

    return $result
} 

Function RemoveUserReadPermissionFromWeb ($Web, $userName) {
    try {
        "Removing read only permission for $($userName) on $($web.Url)" 
                    
        Set-PnPWebPermission -Web $Web.Id -User $userName -RemoveRole "Read" 
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    }
} 

Function RemoveUserReadPermissionFromList ($Web, $List, $userName) {
    try {
        "Removing read only permission for $($userName) on $($web.Url)$($list.DefaultViewUrl)"

        Set-PnPListPermission -Identity $list.Title -User $userName -RemoveRole 'Read' 
    } 
    catch {
        Write-Host $_ -ForegroundColor Red        
    } 
} 

Function AddUserReadPermissionFromWeb ($Web, $userName) {
    try {
        "Setting read only permission for $($userName) on $($web.Url)"
    
        Set-PnPWebPermission -Web $web.Id -User $userName -AddRole "Read"
    }
    catch {
        Write-Host $_ -ForegroundColor Red
    }
} 

Function AddUserReadPermissionFromList ($Web, $List, $userName) {
    try {
        "Setting read only permission for $($userName) on $($web.Url)$($list.DefaultViewUrl)"

        Set-PnPListPermission -Identity $list.Title -User $userName -AddRole 'Read'
    } 
    catch {
        Write-Host $_ -ForegroundColor Red        
    } 
} 

Function RemoveUserReadPermissionFromAllSitesLists ($userName, $tenantName, $cred) {
    Connect-PnPOnline -Url https://$tenantName.sharepoint.com -Credentials $cred

    $sites = Get-PnPTenantSite

    foreach ($site in $sites) {
        try {
            Connect-PnPOnline -Url $site.Url -Credentials $cred
        }
        catch {
            Write-Host $_ -ForegroundColor Red
            continue
        }

        $webs = @()

        $rootWeb = GetRootWeb

        if ($rootWeb) {
            $webs += $rootWeb
        }

        $subWebs = GetSubWebs

        if ($subWebs) {
            $webs += $subWebs
        }

        foreach ($web in $webs) {
            if (CheckIfWebHasUniquePermission $web) {
                RemoveUserReadPermissionFromWeb $web $userName
            }

            $lists = GetUniquePermissionsLists $web

            foreach ($list in $lists) {
                if (!$list.Hidden) {
                    RemoveUserReadPermissionFromList $web $list $userName
                }
            }
        }
    }
}

Function AddUserReadPermissionForAllSitesLists ($userName, $tenantName, $cred) {
    Connect-PnPOnline -Url https://$tenantName.sharepoint.com -Credentials $cred

    $sites = Get-PnPTenantSite

    foreach ($site in $sites) {
        try {
            Connect-PnPOnline -Url $site.Url -Credentials $cred
        }
        catch {
            Write-Host $_ -ForegroundColor Red
            continue
        }

        $webs = @()

        $rootWeb = GetRootWeb

        if ($rootWeb) {
            $webs += $rootWeb
        }

        $subWebs = GetSubWebs

        if ($subWebs) {
            $webs += $subWebs
        }

        foreach ($web in $webs) {
            if (CheckIfWebHasUniquePermission $web) {
                AddUserReadPermissionFromWeb $web $userName
            }

            $lists = GetUniquePermissionsLists $web

            foreach ($list in $lists) {
                if (!$list.Hidden) {
                    AddUserReadPermissionFromList $web $list $userName
                }
            }
        }
    }
}

#RemoveUserReadPermissionFromAllSitesLists $userName $tenantName $cred

AddUserReadPermissionForAllSitesLists $userName $tenantName $cred