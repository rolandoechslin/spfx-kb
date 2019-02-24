# http://sharepoint-tricks.com/disable-footer-globally-on-communication-sites/

$loginUrl   = "https://contoso-admin.sharepoint.com" #SharePoint Admin Center
$username   = "contoso@contoso.com"
$password   = "contoso"

$encpassword = convertto-securestring -String $password -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

Write-Host "Connection SharePoint Admin" $loginUrl
Connect-SPOService -Url $loginUrl -Credential $cred
$sites = Get-SPOSite #Get all the sites

foreach ($site in $sites){
 if ($site.Template -eq "SITEPAGEPUBLISHING#0"){
 try{
  Connect-PnPOnline -Url $site.url -Credentials $cred
  $web = Get-PnPWeb 
  $web.FooterEnabled = $false
  $web.Update()
  Invoke-PnPQuery
  Write-Host "Footer Disable on " $site.url
 }
 catch{
 Write-Host "No permission:" $site.url "- Site admin:" $site.owner
 }
 }
}
Write-Host "Press any key to Close..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")