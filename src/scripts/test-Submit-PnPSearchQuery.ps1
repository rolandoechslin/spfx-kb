# Source: https://pnp.github.io/script-samples/spo-search-export-to-csv/README.html?tabs=pnpps

$itemsToSave = @()

$query = "PromotedState:2"
$properties = "Title,Path,Author"

$search = Submit-PnPSearchQuery -Query $query -SelectProperties $properties -All

foreach ($row in $search.ResultRows) {


  $data = [PSCustomObject]@{
    "Title"      = $row["Title"]
    "Author"     = $row["Author"]
    "Path"       = $row["Path"]
  }

  $itemsToSave += $data
}

$itemsToSave | Export-Csv -Path "SearchResults.csv" -NoTypeInformation
