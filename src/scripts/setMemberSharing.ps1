
# https://techcommunity.microsoft.com/t5/SharePoint-Developer/Changing-the-quot-Allow-members-to-share-quot-SharePoint-site/m-p/276511#M5805
function DisableMemberSharing($siteUrl) {

    Connect-PnPOnline -Url $siteUrl

    $web = Get-PnPWeb -Includes MembersCanShare, AssociatedMemberGroup.AllowMembersEditMembership
    $web.MembersCanShare=$false
    $web.AssociatedMemberGroup.AllowMembersEditMembership=$false
    $web.AssociatedMemberGroup.Update()
    $web.RequestAccessEmail = $null
    $web.Update()
    $web.Context.ExecuteQuery()

}