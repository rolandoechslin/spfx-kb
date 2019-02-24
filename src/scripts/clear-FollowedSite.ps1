# https://www.techmikael.com/2018/05/quickly-clear-followed-sites-using-pnp.html

$followedSitesUrl = "/personal/<user site>/Social/Private/FollowedSites"
$sites = Get-PnPListItem -List Social -Query "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FileDirRef'/><Value 
Type='Text'>$followedSitesUrl</Value></Eq></Where></Query></View>"
$sites |% { Remove-PnPListItem -List Social -Identity $_.ID -Force }