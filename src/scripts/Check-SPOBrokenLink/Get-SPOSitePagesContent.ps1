Function Get-SPOSitePagesContent{
 <#
		.SYNOPSIS
		Return all pages of a site collection and their content
		
		.DESCRIPTION
		Return an object of all pages of a library and their content using the REST API. The function assumes you already made a connection to a site.  
		
		.PARAMETER SiteURL
		The entire URL with tenant and site
		
		.PARAMETER Library
		the library whose pages you would like to obtain

		.EXAMPLE
		Get-SPOSitePagesContent -SiteURL "https://YourTenant.sharepoint.com/sites/inf" -Library "Pages%20du%20site" 

		.EXAMPLE
		$Pages = Get-SPOSitePagesContent -SiteURL "https://YourTenant.sharepoint.com"
		
		.NOTES
		FunctionName : Get-SPOSitePagesContent
		Created by   : Yann Greder
		Date Coded   : 09/24/2020
		Source       : 
#>
		
    Param
    (
        [Parameter(Mandatory=$true)]$SiteURL,
        [Parameter(Mandatory=$false)]$Library = "SitePages"
    )

    $Web = Invoke-PnPSPRestMethod -url "$SiteURL/_api/web/lists/getbytitle('$Library')/Items" 

    $ArrayPages = @()

    # for unknown reason, the $web object is case sensitive
    foreach($Page in $web.value){
        $ObjPage = [PSCustomObject]@{
            Title    = $Page.Title
            Created  = $Page.Created
            Modified = $Page.Modified
            Content  = $Page.CanvasContent1
        }
        $ArrayPages += $ObjPage 
    }

    Return $ArrayPages
}
