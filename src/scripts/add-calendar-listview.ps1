# Source: https://pnp.github.io/script-samples/spo-add-modern-calendar-view/README.html?tabs=pnpps

###### Declare and Initialize Variables ######  

$url = 'https://<tenant>.sharepoint.com/sites/sitename'
$listname = "Calendar" #Change to the SharePoint list name to be used
$newViewTitle = "Modern Calendar View" #Change if you require a different View name


## Connect to SharePoint Online site  

Connect-PnPOnline -Url $url -Interactive

$viewCreationJson = @"
{
    "parameters": {
        "__metadata": {
            "type": "SP.ViewCreationInformation"
        },
        "Title": "$newViewTitle",
        "ViewFields": {
            "__metadata": {
                "type": "Collection(Edm.String)"
            },
            "results": [
                "EventDate",
                "EndDate",
                "Title"
            ]
        },
        "ViewTypeKind": 1,
        "ViewType2": "MODERNCALENDAR",
        "ViewData": "<FieldRef Name=\"Title\" Type=\"CalendarMonthTitle\" /><FieldRef Name=\"Title\" Type=\"CalendarWeekTitle\" /><FieldRef Name=\"Title\" Type=\"CalendarWeekLocation\" /><FieldRef Name=\"Title\" Type=\"CalendarDayTitle\" /><FieldRef Name=\"Title\" Type=\"CalendarDayLocation\" />",
        "CalendarViewStyles": "<CalendarViewStyle Title=\"Day\" Type=\"day\" Template=\"CalendarViewdayChrome\" Sequence=\"1\" Default=\"FALSE\" /><CalendarViewStyle Title=\"Week\" Type=\"week\" Template=\"CalendarViewweekChrome\" Sequence=\"2\" Default=\"FALSE\" /><CalendarViewStyle Title=\"Month\" Type=\"month\" Template=\"CalendarViewmonthChrome\" Sequence=\"3\" Default=\"TRUE\" />",
        "Query": "",
        "Paged": true,
        "PersonalView": false,
        "RowLimit": 0
    }
}
"@

Invoke-PnPSPRestMethod -Method Post -Url "$url/_api/web/lists/GetByTitle('$listname')/Views/Add" -ContentType "application/json;odata=verbose" -Content $viewCreationJson

#Optional Commands

Set-PnPList -Identity $listname -ListExperience NewExperience # Set list experience to force the list to display in Modern

Set-PnPView -List $listname -Identity $newViewTitle -Values @{DefaultView=$true;MobileView=$true;MobileDefaultView=$true} #Set newly created view To Be Default