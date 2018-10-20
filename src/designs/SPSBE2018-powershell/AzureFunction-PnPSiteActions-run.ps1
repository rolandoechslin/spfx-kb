#PnPSiteActions

$in = Get-Content $triggerInput -Raw -Encoding UTF8
$requestXml = [xml]$in
$siteUrl = $requestXml.actions.siteUrl

Write-Output "Connecting to site $siteUrl"
Connect-PnPOnline -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret -Url $siteUrl
$site = Get-PnPSite -Includes GroupId
$groupId = $site.GroupId.ToString("B")
Disconnect-PnPOnline

Write-Output " Iterating through actions"
foreach ($action in $requestXml.actions.ChildNodes) {
    $verb = $action.verb
    $value = $action.value
    Write-Output "  Verb: '$verb'"
    switch($verb) {
        setPrivacy {
            Write-Output "   Connecting to Graph API"
            Connect-PnPOnline -AppId $env:Graph_AppId -AppSecret $env:Graph_AppSecret -AADDomain $env:Graph_AADDomain 
            Write-Output "   Setting Office 365 Group privacy to '$value'"
            switch($value) {
                Public {
                    Set-PnPUnifiedGroup -Identity $groupId -IsPrivate:$false
                }
                Private {
                    Set-PnPUnifiedGroup -Identity $groupId -IsPrivate:$true
                }
                default {
                    Write-Output "   WARNING: Ignoring unknown privacy value"
                }
            }
        }
        addFrontPage {
            Connect-PnPOnline -AppId $env:SPO_AppId -AppSecret $env:SPO_AppSecret -Url $siteUrl
            $site = Get-PnPSite -Includes Id
            $web = Get-PnPWeb -Includes Id
            $siteId = $site.Id
            $webId = $web.Id
            $properties = @"
{"displayMaps":{"1":{"headingText":{"sources":["SiteTitle"]},"headingUrl":{"sources":["SitePath"]},"title":{"sources":["UserName","Title"]},"personImageUrl
":{"sources":["ProfileImageSrc"]},"name":{"sources":["Name"]},"initials":{"sources":["Initials"]},"itemUrl":{"sources":["WebPath"]},"activity":{"sources":[
"ModifiedDate"]},"previewUrl":{"sources":["PreviewUrl","PictureThumbnailURL"]},"iconUrl":{"sources":["IconUrl"]},"accentColor":{"sources":["AccentColor"]},
"cardType":{"sources":["CardType"]},"tipActionLabel":{"sources":["TipActionLabel"]},"tipActionButtonIcon":{"sources":["TipActionButtonIcon"]}},"2":{"column
1":{"heading":"","sources":["FileExtension"],"width":34},"column2":{"heading":"Title","sources":["Title"],"linkUrls":["WebPath"],"width":250},"column3":{"h
eading":"Modified","sources":["ModifiedDate"],"width":100},"column4":{"heading":"Modified By","sources":["Name"],"width":150}},"3":{"id":{"sources":["Uniqu
eID"]},"edit":{"sources":["edit"]},"DefaultEncodingURL":{"sources":["DefaultEncodingURL"]},"FileExtension":{"sources":["FileExtension"]},"FileType":{"sourc
es":["FileType"]},"Path":{"sources":["Path"]},"PictureThumbnailURL":{"sources":["PictureThumbnailURL"]},"SiteID":{"sources":["SiteID"]},"SiteTitle":{"sourc
es":["SiteTitle"]},"Title":{"sources":["Title"]},"UniqueID":{"sources":["UniqueID"]},"WebId":{"sources":["WebId"]},"WebPath":{"sources":["WebPath"]}},"4":{
"headingText":{"sources":["SiteTitle"]},"headingUrl":{"sources":["SitePath"]},"title":{"sources":["UserName","Title"]},"personImageUrl":{"sources":["Profil
eImageSrc"]},"name":{"sources":["Name"]},"initials":{"sources":["Initials"]},"itemUrl":{"sources":["WebPath"]},"activity":{"sources":["ModifiedDate"]},"pre
viewUrl":{"sources":["PreviewUrl","PictureThumbnailURL"]},"iconUrl":{"sources":["IconUrl"]},"accentColor":{"sources":["AccentColor"]},"cardType":{"sources"
:["CardType"]},"tipActionLabel":{"sources":["TipActionLabel"]},"tipActionButtonIcon":{"sources":["TipActionButtonIcon"]}}},"query":{"contentLocation":3,"co
ntentTypes":[1],"sortType":1,"filters":[{"filterType":1,"value":"sharepoint"}],"documentTypes":[3],"advancedQueryText":""},"templateId":1,"maxItemsPerPage"
:8,"hideWebPartWhenEmpty":false,"sites":[],"layoutId":"Card","dataProviderId":"Search","webId":"$webId","siteId":"$siteId"}
"@
            $frontPage = Add-PnPClientSidePage -Name "FrontPage" -LayoutType Home -CommentsEnabled:$true
            Add-PnPClientSidePageSection -Page $frontPage -SectionTemplate OneColumn 
            Add-PnPClientSideWebPart -Page $frontPage -Section 1 -Column 1 -DefaultWebPartType ContentRollup -WebPartProperties $properties
            Set-PnPClientSidePage -Identity $frontPage -PublishMessage "PnP Script published me!" -Publish:$true
            Set-PnPHomePage -RootFolderRelativeUrl "SitePages/FrontPage.aspx"
        }
        newTeam {
            Write-Output "   Creating Team"
            $username = $env:Teams_Username
            $password = $env:Teams_Password | ConvertTo-SecureString -asPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential($username,$password)
            Connect-MicrosoftTeams -TenantId "your-tenant-guid-here" -Credential $credential
            New-Team -Group $groupId 
        }
        default {
            Write-Output "   WARNING: Ignoring unknown verb."
        }
    }
}

Write-Output "End of run.ps1"