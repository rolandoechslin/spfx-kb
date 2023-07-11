function Submit-PnPSearchQueryAll {
    <#
.SYNOPSIS
    Submits a PnP search query to SharePoint and retrieves all results.

.DESCRIPTION
    This function uses the Submit-PnPSearchQuery cmdlet to send a search query to SharePoint.
    It retrieves results in batches of 500 (the maximum for a single request), making multiple requests if necessary to retrieve all results. If the -ShowProgress switch is provided, the function will display the total number of results and a progress bar.
    You have to already be connected to your M365 tenant using Connect-PnPOnline before using this function.

.PARAMETER query
    The search query to send to SharePoint.

.PARAMETER ShowProgress
    If this switch is provided, the function will display a progress bar.

.EXAMPLE
    Submit-PnPSearchQueryAll -query "autorun.inf"

    This will send the search query 'autorun.inf' to SharePoint and retrieve all results.

.EXAMPLE
    Submit-PnPSearchQueryAll -query "autorun.inf" -ShowProgress

    This will send the search query 'autorun.inf' to SharePoint, retrieve all results, and display a progress bar.
#>
    param(
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $false)]
        [switch]$ShowProgress
    )

    # Check if we're connected to a SharePoint site
    $connection = Get-PnPConnection
    if ($null -eq $connection) {
        Write-Error "Not connected to a SharePoint site. Use Connect-PnPOnline to connect."
        return
    }    
    
    # Initial variables
    $startRow = 0
    $pageSize = 500  # number of results per query

    do {
        # Perform query
        Write-Verbose "Getting results starting at row $startRow"
        $results = Submit-PnPSearchQuery -Query $query -StartRow $startRow 

        # Show total number of results on first run
        if ($ShowProgress -and $startRow -eq 0) {
            Write-Host "Total results: $($results.TotalRows)"
        }

        # For each result, create a PSCustomObject with the desired properties
        foreach ($resultRow in $results.ResultRows) {
            [PSCustomObject]@{
                Title = $resultRow.Title
                FileExtension = $resultRow.FileExtension
                Size = $resultRow.Size
                Description = $resultRow.Description
                Path = $resultRow.Path
                OriginalPath = $resultRow.OriginalPath
                ParentLink = $resultRow.ParentLink
                SPWebUrl = $resultRow.SPWebUrl
                SiteName = $resultRow.SiteName
                IsDocument = $resultRow.IsDocument
            }
        }

        # Show the number of results 
        if($ShowProgress) {
            Write-Progress -Activity "Getting results" -Status "Getting results" -PercentComplete (($startRow / $results.TotalRows) * 100)
        }
        Write-Verbose "Found $($results.RowCount) results"

        # Increment the StartRow
        $startRow += $pageSize

        # Show the current StartRow
        Write-Verbose "Getting results starting at row $startRow"
    }
    while ($startRow -lt $results.TotalRows) # continue querying while we're below the total number of results

}