#Read more: http://www.sharepointdiary.com/2017/08/page-layouts-usage-analysis-report-using-powershell.html#ixzz5QfeLigoV

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
Function Get-PageLayouts {
    param
    (
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.SPSite]$Site
    )
     
    #Get the Publishing Site object
    [Microsoft.Sharepoint.Publishing.PublishingSite]$PublishingSite = New-Object Microsoft.SharePoint.Publishing.PublishingSite($Site)
     
    #Get All page layouts 
    $PageLayouts = $PublishingSite.GetPageLayouts($false)
         
    ForEach ($PageLayout in $PageLayouts) {
        Write-host $PageLayout.Name : $PageLayout.ServerRelativeUrl
    }
}
 
#Get a Site collection
$Site = Get-SPSite "https://<tenantUrl>"
 
#Call the function to get all available page layouts
Get-PageLayouts -Site $Site



Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
Function Get-PageLayoutsUsage {
    param
    (
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.SPSite]$Site,
        [Parameter(Mandatory = $true)][String]$ReportFile
    )
     
    #Array to store Result
    $ResultSet = @()
  
    #Iterate through each web of the site collection
    ForEach ($web in $Site.AllWebs) {
        Write-host -f Cyan "Scanning site $($Web.URL)..."
        $PublishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($Web)
         
        if ($PublishingWeb.PagesList) {
            foreach ($Page in $PublishingWeb.GetPublishingPages()) {
                #Get the page layout details   
                $Result = new-object PSObject
                $Result | add-member -membertype NoteProperty -name "URL" -Value $web.Url
                $Result | add-member -membertype NoteProperty -name "Page URL" -Value $Page.Uri.ToString()
                $Result | add-member -membertype NoteProperty -name "PageLayout URL" -Value $Page.Layout.ServerRelativeUrl
                $Result | add-member -membertype NoteProperty -name "PageLayout Name" -Value $Page.Layout.Name
 
                $ResultSet += $Result
            }           
        }
    }
    #Export Result to csv file
    $ResultSet |  Export-Csv $ReportFile -notypeinformation
     
    Write-Host "Page Layouts Usage Report Generated Successfully!" -f Green
}
 
#Get a Site collection
$Site = Get-SPSite "https://tenantUrl"
$ReportFile = "C:\Temp\PageLayouts.csv"
 
#Call the function to get page layouts usage
Get-PageLayoutsUsage -Site $Site -ReportFile $ReportFile


