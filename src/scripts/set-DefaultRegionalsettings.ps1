function SetDefaultRegionalsettings()
{
    Connect-GwSharePointAdmin
 
    $siteScriptJSON = @'
    {
"$schema": "schema.json",
"actions": [
      {
       "verb": "setRegionalSettings",
       "timeZone": 4, /* Bern */
       "locale": 2055, /* Swiss German */
       "sortOrder": 25, /* Default */
       "hourFormat": "24"
      }
   ],
      "bindata": { },
"version": 1
}
 
'@
  
    
    $siteScript = Add-PnPSiteScript -Title "Set Swiss Regional Settings" -Content $siteScriptJSON 
    # Setzt das Script auf alle neu erstellten Teamsites
    $siteDesign = Add-PnPSiteDesign -Title "Set Swiss Regional Settings" -SiteScriptIds $siteScript.Id -WebTemplate TeamSite -IsDefault
 
}