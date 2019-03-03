# Original: https://sharepointframework-dev.blogspot.com/2019/02/delete-api-pending-requests.html

$Url = Read-Host -Prompt 'Input your tenant admin URL (e.g. https://mytenant-admin.sharepoint.com)'
Connect-SPOService -Url $Url
do{
    $requests = Get-SPOTenantServicePrincipalPermissionRequests
    $requestsToGraph = $requests | ? { $_.Resource -eq 'Microsoft Graph' }
    foreach ($req in $requestsToGraph){
        if ($req -ne $null)
        {
            Deny-SPOTenantServicePrincipalPermissionRequest -RequestId $req.Id
            Write-Output $req.Id
        }   
    }
}while($requestsToGraph -ne $null -and $requestsToGraph.length -gt 0)
Disconnect-SPOService