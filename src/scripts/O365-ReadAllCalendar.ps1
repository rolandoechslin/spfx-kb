
# Sourcce: https://raw.githubusercontent.com/spjeff/office365/master/office365-read-all-calendar/O365-ReadAllCalendar.ps1

# Config
$clientID       = "1f22e467-cb59-4cc7-91a9-a816d5666c75"
$tenantName     = "0a9449ca-3619-4fca-8644-bdd67d0c8ca6"
$ClientSecret   = "VtKm16o6~G0~U44.JAs~.Sr7eBt7C7ScVS"

function AuthO365() {
    # Auth call
    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        client_Id     = $clientID
        Client_Secret = $clientSecret
        Scope         = "https://graph.microsoft.com/.default"
    } 
    return Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method "POST" -Body $ReqTokenBody
}

function readCalendar($token) {
    # Loop all users
    $api = "https://graph.microsoft.com/v1.0/users"
    $users = $null
    $users = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)" } -Uri $api -Method "GET" -ContentType "application/json"
    foreach ($u in $users) {

        # All events for user
        $upn = $u.value[0].userPrincipalName
        $api = "https://graph.microsoft.com/v1.0/users/$upn/events?`$top=999&`$filter=start/dateTime ge '2020-01-01' and end/dateTime le '2020-07-29'"
        Write-Host $api -Fore Green
        $events = $null
        $events = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)" } -Uri $api -Method "GET" -ContentType "application/json"

        do {
            foreach ($r in $events.value) {
                # Properties
                $id                 = $r.id
                $subject            = $r.subject
                $bodyPreview        = $r.bodyPreview
                $start              = [datetime]$r.start.dateTime
                $end                = [datetime]$r.end.dateTime
                $attendeesCount     = $r.attendees.count
                $organizername      = $r.organizer.emailAddress.name
                $organizeraddress   = $r.organizer.emailAddress.address

                Write-Host "EVENT: Start=$start End=$end Id=$id" -Fore Yellow
            }
            if ($events.'@Odata.NextLink') {
                $events = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)" } -Uri $events.'@Odata.NextLink' -Method "GET" -ContentType "application/json"
            }
        }  while ($events.'@Odata.NextLink')
    }
}

function Main() {
    $token = AuthO365
    $token
    readCalendar $token
}
Main