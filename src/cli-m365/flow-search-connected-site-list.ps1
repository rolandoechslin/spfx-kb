# https://www.cloudappie.nl/search-flows-connections/

Write-Output "Retrieving all environments"

$environments = m365 flow environment list -o json | ConvertFrom-Json
$searchString = "15f5b014-9508-4941-b564-b4ab1b863a7a" #listGuid
$path = "exportedflow.json";

ForEach ($env in $environments) {
    Write-Output "Processing $($env.displayName)..."

    $flows = m365 flow list --environment $env.name --asAdmin -o json | ConvertFrom-Json

    ForEach ($flow in $flows) {
        Write-Output "Processing $($flow.displayName)..."
        m365 flow export --id $flow.name --environment $env.name --format json --path $path

        $flowData = Get-Content -Path $path -ErrorAction SilentlyContinue

        if($null -ne $flowData) {
            if ($flowData.Contains($searchString)) {
                    Write-Output $($flow.displayName + "contains your search string" + $searchString)
                    Write-Output $flow.id
            }

            Remove-Item $path -Confirm:$false
        }
    }
}