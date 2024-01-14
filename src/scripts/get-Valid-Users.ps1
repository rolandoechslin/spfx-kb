# https://pnp.github.io/script-samples/get-spo-invalid-user-accounts/README.html?tabs=pnpps


#extract all users from a site collection and check for validity
$SiteURL = "https://contoso.sharepoint.com/sites/workspaces"
if(-not $conn)
{
    $conn = Connect-PnPOnline -Url $SiteURL -Interactive -ReturnConnection
}

function Get-AllUsersFromUPA
{
    $allUPAusers = @()
    $UPAusers = Submit-PnPSearchQuery -Query "*" -SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31" -SelectProperties "Title,WorkEmail" -All -Connection $conn
    foreach($user in $UPAusers.ResultRows)
    {
        $allUPAusers += $user.LoginName
    }
    $allUPAusers
}

function Get-UserFromGraph 
{
    $disabledusersfromgraph = @()
    $result = Invoke-PnPGraphMethod -Url "users?`$select=displayName,mail, AccountEnabled" -Connection $conn

    $result.value.Count
    foreach($account in $result.value)
    {
        if($account.accountEnabled -eq $false)
        {
            $disabledusersfromgraph += $account.mail
        }
    }
    $disabledusersfromgraph
}

$disabledusersfromgraph = Get-UserFromGraph
$allUPAusers = Get-AllUsersFromUPA

$allSiteUsers = Get-PnPUser -Connection $conn
$validUsers = @()
$invalidUsers = @()
foreach($user in $allSiteUsers)
{
    try {
        $userObj = Get-PnPUser -Identity $user.LoginName -Connection $conn -ErrorAction Stop
        if($userObj.Email -in $disabledusersfromgraph)
        {
            Write-Host "User $($userObj.LoginName) is disabled in Azure AD"
            $invalidUsers += $user
        }
        else
        {
            $hit = $allUPAusers | Where-Object {$_ -eq $userObj.LoginName}
            if(-not $hit)
            {
                Write-Host "User $($userObj.LoginName) is not in the UPA"
                $invalidUsers += $user
            }
        }
        
        
    }
    catch {
        $invalidUsers += $user
    }
}
$invalidUsers | Export-Csv -Path "C:\temp\invalidusers.csv" -Delimiter "|" -Encoding utf8 -Force
