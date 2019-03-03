# Original: https://sharepointframework-dev.blogspot.com/2019/02/delete-api-pending-requests.html

$Url = Read-Host -Prompt 'Input your tenant admin URL (e.g. https://mytenant-admin.sharepoint.com)'
Connect-SPOService -Url $Url
do{
    $requests = Get-SPOTenantServicePrincipalPermissionRequests
    foreach ($req in $requests ){
        if ($req -ne $null)
        {
            Deny-SPOTenantServicePrincipalPermissionRequest -RequestId $req.Id
            Write-Output $req.Id
        }   
    }
}while($requests -ne $null -and $requests.length -gt 0)
Disconnect-SPOService