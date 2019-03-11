# Read more: http://www.sharepointdiary.com/2018/04/sharepoint-online-powershell-to-update-list-view.html#ixzz5hq35HxOJ

# Config Variables
$SiteURL = "https://crescenttech.sharepoint.com"
$ListName = "Projects"
$ViewName = "Active Projects"
$ViewQuery = "<Where><Eq><FieldRef Name = 'ProjectStatus' /><Value Type ='Choice'>Active</Value></Eq></Where>"
 
# Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials (Get-Credential)
 
# Get the Client Context
$Context = Get-PnPContext
  
# Get the List View
$View = Get-PnPView -Identity $ViewName -List $ListName
  
# Update the view Query
$View.ViewQuery = $ViewQuery
$View.Update()
$Context.ExecuteQuery()


