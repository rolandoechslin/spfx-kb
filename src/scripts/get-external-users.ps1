# https://absolute-sharepoint.com/2018/03/create-a-report-of-sharepoint-online-external-users-with-powershell.html
# http://www.sharepointdiary.com/2017/11/sharepoint-online-find-all-external-users-using-powershell.html


$SiteCollections = Get-SPOSite -Limit All
foreach ($site in $SiteCollections) {
    try {
        for ($i = 0; ; $i += 50) {

            $ExternalUsers += Get-SPOExternalUser -SiteUrl $site.Url -PageSize 50 -Position $i -ea Stop | Select DisplayName, EMail, AcceptedAs, WhenCreated, InvitedBy, @{Name = "Url" ; Expression = { $site.url } }

            # ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount
            # It shows you all the external accounts that have been invited to your tenant using an e-mail address, 
            # but they have accepted the invitation and are using a different e-mail address to authenticate to your SharePoint Online.
            # $ExternalUsers += Get-SPOExternalUser -ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount $true -PageSize 50 -Position $i  -ea Stop

        }
    }
    catch {
    }
}

$ExternalUsers | Export-Csv -Path "C:\temp\ExternalUsersPerSC.csv" -NoTypeInformation


