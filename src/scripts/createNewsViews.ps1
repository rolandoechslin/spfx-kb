Write-Host "Type the site collection URL"
$siteCollection = Read-Host 
Connect-PnPOnline -url $siteCollection

Add-PnPView -List "Site Pages" -Title "All News" -Fields "Title", "Name", "Editor", "Modified" -Query "<Where><Eq><FieldRef Name='PromotedState'></FieldRef><Value Type='Number'>2</Value></Eq></Where>" 

Add-PnPView -List "Site Pages" -Title "SharePoint News" -Fields "Title", "Name", "Editor", "Modified" -Query "<Where><And><Eq><FieldRef Name='PromotedState' /><Value Type='Number'>2</Value></Eq><Eq><FieldRef Name='PageLayoutType' /><Value Type='Text'>Article</Value></Eq></And></Where>"

Add-PnPView -List "Site Pages" -Title "News link" -Fields "Title", "Name", "Editor", "Modified", "_OriginalSourceUrl" -Query "<Where><And><Eq><FieldRef Name='PromotedState' /><Value Type='Number'>2</Value></Eq><Eq><FieldRef Name='PageLayoutType' /><Value Type='Text'>RepostPage</Value></Eq></And></Where>"
