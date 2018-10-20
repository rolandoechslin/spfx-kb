Connect-SPOService "https://yourtenant-admin.sharepoint.com"

$privateSiteScript = @"
{
    "`$schema": "schema.json",
    "actions": [
    {
        "verb": "triggerFlow",
        "url": "https://prod-19.westeurope.logic.azure.com:443/workflows/1234581a92f47ba8887d99b3ea43ce6/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FURFi0aEEhP0pJY11LFnC3fyh4aySA0vYzGJ1234567",
        "name": "Set site as Private",
        "parameters": {
            "event": "setPrivacy",
            "product": "Private"
        }
    }
    ],
    "bindata": {},
    "version": 1
}
"@

$publicSiteScript = @"
{
    "`$schema": "schema.json",
    "actions": [
    {
        "verb": "triggerFlow",
        "url": "https://prod-19.westeurope.logic.azure.com:443/workflows/550d4481a92f47ba8887d99b31234567/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FURFi0aEEhP0pJY11LFnC3fyh4aySA0vYzGJ1234567",
        "name": "Set site as Public",
        "parameters": {
            "event": "setPrivacy",
            "product": "Public"
        }
    }
    ],
    "bindata": {},
    "version": 1
}
"@

$addFrontPageSiteScript = @"
{
    "`$schema": "schema.json",
    "actions": [
    {
        "verb": "triggerFlow",
        "url": "https://prod-19.westeurope.logic.azure.com:443/workflows/550d4481a92f47ba8887d99b3e123456/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FURFi0aEEhP0pJY11LFnC3fyh4aySA0vYzGJ1234567",
        "name": "Create custom front page",
        "parameters": {
            "event": "addFrontPage",
            "product": ""
        }
    }
    ],
    "bindata": {},
    "version": 1
}
"@

# A sample script to start a flow
$newTeamSiteScript = @"
{
    "`$schema": "schema.json",
    "actions": [
    {
        "verb": "triggerFlow",
        "url": "https://prod-19.westeurope.logic.azure.com:443/workflows/550d4481a92f47ba8887d99b3e123456/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FURFi0aEEhP0pJY11LFnC3fyh4aySA0vYzGJ1234567",
        "name": "Create new Team",
        "parameters": {
            "event": "newTeam",
            "product": ""
        }
    }
    ],
    "bindata": {},
    "version": 1
}
"@

Add-SPOSiteScript -Title "Set site as Public" -Content $publicSiteScript
Add-SPOSiteScript -Title "Set site as Private" -Content $privateSiteScript
Add-SPOSiteScript -Title "Create custom front page" -Content $addFrontPageSiteScript
Add-SPOSiteScript -Title "Create new Team" -Content $newTeamSiteScript
Get-SPOSiteScript

Set-SPOSiteScript -Identity "2f113eeb-7a0f-44d1-b1e4-82285585f360" -Content $privateSiteScript
Set-SPOSiteScript -Identity "8c8d8fc7-1aff-4ba6-acb5-24eda71a90f3" -Content $publicSiteScript

Add-SPOSiteDesign -Title "Team site with Teams" -WebTemplate 64 -SiteScripts "e5e1bc88-1649-4230-a921-91df87968ae9"


Add-SPOSiteDesign -Title "Public Team Site" -WebTemplate 64 -SiteScripts "8c8d8fc7-1aff-4ba6-acb5-24eda71a90f3" 
Add-SPOSiteDesign -Title "Private Team Site" -WebTemplate 64 -SiteScripts "2f113eeb-7a0f-44d1-b1e4-82285585f360" 
Set-SPOSiteDesign -Identity "af4dae0b-27e5-4c1b-80df-903cd3e18f99" -SiteScripts "8c8d8fc7-1aff-4ba6-acb5-24eda71a90f3","58921458-8876-48ef-9859-475aba67adb2"
Set-SPOSiteDesign -Identity "1a19bd87-e966-48fe-b8ac-0b46f5e12ea5" -SiteScripts "2f113eeb-7a0f-44d1-b1e4-82285585f360","58921458-8876-48ef-9859-475aba67adb2"

Get-SPOSiteDesign
