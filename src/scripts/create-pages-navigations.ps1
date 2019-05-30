$HelpAndQAUrl = "https://[YourTenant].sharepoint.com/sites/SiteCollection/helpsite"
$CSVFilePath = "C:\Business-CheckList.csv"

##Connecting to site - get and save your O365 credentials
[string]$username = "Admin@YourTenant.onmicrosoft.com"
[string]$PwdTXTPath = "C:\SECUREDPWD\ExportedPWD-$($username).txt"
$secureStringPwd = ConvertTo-SecureString -string (Get-Content $PwdTXTPath)
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

# ---------------------------------------------------------------------------------------------------------------

[string]$TextTemplateToPut = ""
[string]$pageFilename = ""
[string]$pageFileTitle = ""
[string]$PageTopic = ""
[string]$PageTitleFull = ""
[string]$pageFilename = ""
[string]$PageTitleToUpdate = ""
[int]$ParentNodeID = 0
[int]$PageNodeID = 0

# ---------------------------------------------------------------------------------------------------------------
#GET CSV File
$AllPagesToCreate = Import-Csv -Path $CSVFilePath

# --------------------------------------------------------------------------------------------
#Loop for each line
foreach ($PageToCreate in $AllPagesToCreate)
{
	# ---------------------------------------------------------------------------------------------------------------
	Write-host " ==> Page ID", $PageToCreate.CHECKID, "- Name:", $PageToCreate.CHECKNAME , "- Topic:", $PageToCreate.CHECKTOPIC -ForegroundColor Yellow
	# ---------------------------------------------------------------------------------------------------------------

	$pageFileTitle = $PageToCreate.CHECKID
	$PageTopic = $PageToCreate.CHECKTOPIC
	$PageTitleFull = $PageToCreate.CHECKNAME
	if($PageTitleFull.IndexOf("(") -gt 0)
	{
		$PageTitleShort = $PageTitleFull.Substring(0, $PageTitleFull.IndexOf("("))
	}
	else
	{
		$PageTitleShort = $PageTitleFull
	}
	$pageFilename =  -join($pageFileTitle, ".aspx")

	$TextTemplateToPut = "<h2>Task Title: $($PageTitleFull)</h2>"
	$TextTemplateToPut += "<h3>Topic:</h3><ul><li>$($PageTopic)</li></ul>"
	$TextTemplateToPut += "<h3>Description:</h3><p>&nbsp;</p><p>&nbsp;</p>"
	$TextTemplateToPut += "<h3>Estimated Time:</h3><ul><li>&nbsp;</li></ul>"
	$TextTemplateToPut += "<h3>Person in charge:</h3><ul><li>&nbsp;</li></ul>"
	$TextTemplateToPut += "<h3>Starting time:</h3><ul><li>&nbsp;</li></ul><p>&nbsp;</p>"

	$PageTitleToUpdate = -join($pageFileTitle, " - ", $PageTitleShort)
	$ParentNodeID = 0
	$PageNodeID = 0

	Write-host " "
	Write-host " -------------------------------------------------------------------------------------------- " -ForegroundColor green
	Write-host " ---- START THE PAGE CREATION:", $pageFileTitle, "-", $pageFilename -ForegroundColor green
	Write-host " ---- Page Title Full:", $PageTitleFull -ForegroundColor green
	Write-host " ---- Page Title Short:",  $PageTitleShort -ForegroundColor green
	Write-host " -------------------------------------------------------------------------------------------- " -ForegroundColor green

	# ---------------------------------------------------------------------------------------------------------------
	#connect to the web site using the stored credentials
	Write-host " "
	Write-host " -------------------------------------------------------------------------------------------- " -ForegroundColor green
	Write-host " ---- CONNECT THE SITE --- " -ForegroundColor green
	Write-host "   CONNECTED SITE:", $HelpAndQAUrl  -ForegroundColor Yellow
	Connect-PnPOnline -Url $HelpAndQAUrl -Credential $cred
	Write-host " -------------------------------------------------------------------------------------------- " -ForegroundColor green
	$checkpage = Get-PnPClientSidePage -Identity $pageFilename -ErrorAction SilentlyContinue

	if($checkpage -eq $null)
	{
		Write-Host "  >>>  Page does not exist or is not modern"
		$page = Add-PnPClientSidePage -Name $pageFilename -LayoutType "Article"
	}
	else
	{
		Write-Host "  >>> We have a modern page present"
		$page = $checkpage
	}
	#Add text webpart to page
	Add-PnPClientSideText -Page $page -Text $TextTemplateToPut
	Set-PnPClientSidePage -Identity $page -LayoutType "Article" -Title $PageTitleToUpdate

	$page = Get-PnPClientSidePage -Identity $pageFilename -ErrorAction SilentlyContinue

	Write-host "   ==>> PAGE HEADERS ImageServerRelativeUrl:", $page.PageHeader.ImageServerRelativeUrl  -ForegroundColor Green
	$ctx = Get-PnPContext
	Write-host "   ==>> WEB Relative URL:", $ctx.Web.ServerRelativeUrl  -ForegroundColor Yellow
	$mySiteRelativeURL = $ctx.Web.ServerRelativeUrl
	$myPageRelativeURL = -join($mySiteRelativeURL, "/", $page.PagesLibrary, "/", $pageFilename)
	Write-host "   ==>> PAGE Relative URL:", $myPageRelativeURL  -ForegroundColor Yellow

	$page.PageHeader.ImageServerRelativeUrl = $mySiteRelativeURL +"/SiteAssets/$($PageTopic).JPG"
	$page.Save()
	$page.Publish()



	Get-PnPConnection
	$AllQuicklaunchNodes = Get-PnPNavigationNode

	foreach($MyNode in $AllQuicklaunchNodes)
	{
		if($MyNode.Title -eq $PageTopic)
		{
			Write-host "   ->>>>  PARENT - MenuNode Title:", $MyNode.Title, "- ID:", $MyNode.ID  -ForegroundColor Yellow
			$ParentNodeID = $MyNode.ID
		}
		else
		{
			Write-host "   - MenuNode Title:", $MyNode.Title, "- ID:", $MyNode.ID  -ForegroundColor Green
		}
	}
	if($ParentNodeID -eq 0)
	{
		Write-host "               ===>>>>  TOPIC LINK NOT EXIST, Need to create it"  -ForegroundColor Red
		$AddMyNode = Add-PnPNavigationNode -Title $PageTopic -Url $mySiteRelativeURL -Location "QuickLaunch"
		$ParentNodeID = $AddMyNode.Id
	}
	
	$Topicnodes = Get-PnPNavigationNode -Id $ParentNodeID	
	foreach($MyPageNode in $Topicnodes.Children)
	{
		if($MyPageNode.Title -eq $PageTitleToUpdate)
		{
			Write-host "            ->>>>  PAGE NODE EXIST- MenuNode Title:", $MyPageNode.Title, "- ID:", $MyPageNode.ID  -ForegroundColor Red
			$PageNodeID = $MyPageNode.ID
		}
		else
		{
			Write-host "            ->>>>  PAGE NODE - MenuNode Title:", $MyPageNode.Title, "- ID:", $MyPageNode.ID  -ForegroundColor green
		}
	}
	if($PageNodeID -eq 0)
	{
		$AddMyNode = Add-PnPNavigationNode -Title $PageTitleToUpdate -Url $myPageRelativeURL -Location "QuickLaunch" -Parent $ParentNodeID
	}
}