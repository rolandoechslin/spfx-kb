$SitesUpdated = 0
DesignID = "11c2efae-d0eb-4eb9-af71-4f4f5c5c6db8"
$Groups = (Get-UnifiedGroup | ? {$_.SharePointSiteUrl -ne $Null} | Select SharePointSiteUrl, DisplayName, Alias)
ForEach ($G in $Groups) {
     Try {
          Write-Host "Processing" $G.SharePointSiteUrl "for group" $G.DisplayName
          Invoke-SPOSiteDesign -Identity $DesignID -WebUrl $G.SharePointSiteURL -ErrorAction Stop
          $SitesUpdated++
          Set-UnifiedGroup -Identity $G.Alias -CustomAttribute13 "Site Design Updated" }
    Catch {
          Write-Host "Problem Processing" $G.SharePointSiteURL }
}
Write-Host $SitesUpdated "sites updated successfully. You need to check the following and update them manually"
Get-UnifiedGroup -Filter {CustomAttribute13 -eq $Null} | Sort DisplayName | Format-Table DisplayName, SharePointSiteURL