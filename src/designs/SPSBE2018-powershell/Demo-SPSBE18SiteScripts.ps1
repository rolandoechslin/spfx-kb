Connect-PnPOnline -Url https://yourtenant-admin.sharepoint.com/ 

$script = @"
{
    "$schema": "schema.json",
        "actions": [
            {
                "verb": "createSiteColumn",
                "fieldType": "User",
                "internalName": "pnpOwner",
                "displayName": "Owner",
                "isRequired": true
            },
            {
                "verb": "createSiteColumn",
                "fieldType": "DateTime",
                "internalName": "pnpExpirationDate",
                "displayName": "Expiration date",
                "isRequired": true
            },
            {
                "verb": "createContentType",
                "name": "Contract",
                "description": "Contract",
                "parentName": "Document",
                "hidden": false,
                "subactions":
                    [
                        {
                            "verb": "addSiteColumn",
                            "internalName": "pnpOwner"
                        },
                        {
                            "verb": "addSiteColumn",
                            "internalName": "pnpExpirationDate"
                        }
                    ]
            },
            {
                "verb": "createSPList",
                "listName": "Contracts",
                "templateType": 101,
                "subactions": [
                    {
                        "verb": "addContentType",
                        "name": "Contract"
                    },
                    {
                       "verb": "removeContentType",
                       "name": "Document"
                    },
                    {
                        "verb": "addSPView",
                        "name": "Contracts",
                        "viewFields": 
                        [
                            "DocIcon", 
                            "LinkFilename",
                            "pnpOwner",
                            "pnpExpirationDate"
                        ],
                        "query": "<OrderBy><FieldRef Name=\"ID\" /></OrderBy>",
                        "rowLimit": 30,
                        "isPaged": true,
                        "makeDefault": true
                    }
                ]
            },
            {
               "verb": "addNavLink",
               "url": "/Contracts",
               "displayName": "Contracts",
               "isWebRelative": true
            }
        ],
        "bindata": { },
        "version": 1
}
"@

# TO ADD NEW SITE SCRIPT
$newScript = Add-PnPSiteScript -Title "Contracts" -Description "Includes contract document content type and required fields." -Content $script
$contractDocSiteScriptId = $newScript.Id 

# TO MODIFY EXISTING SITE SCRIPT
$siteScript = Get-PnPSiteScript | Where-Object { $_.Title -eq "Contracts" }
Set-PnPSiteScript -Identity $siteScript.Id -Title "Contracts" -Content $script

# TO LIST ALL SITE SCRIPTS
Get-PnPSiteScript