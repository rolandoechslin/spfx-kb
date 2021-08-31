
### Microsoft Planner Tenant To Tenant Migration Script       ###
###                                                           ###
### Version 1.0                                               ###
###                                                           ###
### Author: Alexander Holmeset                                ###
###                                                           ###
### Twitter: twitter.com/alexholmeset                         ###
###                                                           ###
### Blog: alexholmeset.blog                                   ###
###                                                           ###
### This scripts migrates Planner plans with buckets,         ###
### tasks, labels, checklists, task asignees,                 ###
### task description and task proggress to a new tenant.      ###
### The script does not migrate atachments and conversations. ###

### Prereq:                                                                                         ###
###     - Groups created and popluated with owner/members in destination tenant.                    ###
###     - Group.ReadWrite.All rights in Graph API in source and destiantion tenant.                 ###
###     - Admin user added as owner and member in the groups in both source and destination tenant. ###

# Source: https://alexholmeset.blog/2019/10/14/planner-tenant-to-tenant-migration/

#Enter Source details
$clientIdSource = "91433c0c-769b-4fdf-a4d8-1e00deec8c77"
$tenantIdSource = "e99c0533-933c-4dc5-8252-076d5bd5ef55"
$domainSource = "M365x628786.onmicrosoft.com"

#Enter Destination details
$clientIdDestination = "067aa1c2-dbe4-44b2-b4cf-3866cecf0944"
$tenantIdDestination = "2749339e-69b9-4986-99b9-678ae30badba"
$domainDestination = "M365x842993.onmicrosoft.com"



# Application (client) ID, tenant ID, resource and scope i the source tenant
$resourceSource = "https://graph.microsoft.com/"
$scopeSource = ""

$codeBodySource = @{ 

    resource  = $resourceSource
    client_id = $clientIdSource
    scope     = $scopeSource

}

# Get OAuth Code
$codeRequestSource = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantIdSource/oauth2/devicecode" -Body $codeBodySource

# Print Code to console
"Source tenant"
Write-Host "`n$($codeRequestSource.message)"

$tokenBodySource = @{

    grant_type = "urn:ietf:params:oauth:grant-type:device_code"
    code       = $codeRequestSource.device_code
    client_id  = $clientIdSource

}

# Get OAuth Token
while ([string]::IsNullOrEmpty($tokenRequestSource.access_token)) {

    $tokenRequestSource = try {

        Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantIdSource/oauth2/token" -Body $tokenBodySource

    }
    catch {

        $errorMessageSource = $_.ErrorDetails.Message | ConvertFrom-Json

        # If not waiting for auth, throw error
        if ($errorMessageSource.error -ne "authorization_pending") {

            throw

        }

    }

}

$tokenSource = $tokenRequestSource.access_token


# Application (client) ID, tenant ID, resource and scope

$resourceDestination = "https://graph.microsoft.com/"
$scopeDestination = "Group.ReadWrite.All"

$codeBodyDestination = @{ 

    resource  = $resourceDestination
    client_id = $clientIdDestination
    scope     = $scopeDestination

}

# Get OAuth Code
$codeRequestDestination = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantIdDestination/oauth2/devicecode" -Body $codeBodyDestination

# Print Code to console
"Destination tenant"
Write-Host "`n$($codeRequestDestination.message)"

$tokenBodyDestination = @{

    grant_type = "urn:ietf:params:oauth:grant-type:device_code"
    code       = $codeRequestDestination.device_code
    client_id  = $clientIdDestination

}

# Get OAuth Token
while ([string]::IsNullOrEmpty($tokenRequestDestination.access_token)) {

    $tokenRequestDestination = try {

        Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantIdDestination/oauth2/token" -Body $tokenBodyDestination

    }
    catch {

        $errorMessageDestination = $_.ErrorDetails.Message | ConvertFrom-Json

        # If not waiting for auth, throw error
        if ($errorMessageDestination.error -ne "authorization_pending") {

            throw

        }

    }

}

$tokenDestination = $tokenRequestDestination.access_token




#Gets all groups in source tenant.
$uri = 'https://graph.microsoft.com/v1.0/groups/'


$groups = while (-not [string]::IsNullOrEmpty($uri)) {

    # API Call
    $apiCall = try {
        
        Invoke-RestMethod -Method GET -Uri $uri -ContentType "application/json" -Headers  @{Authorization = "Bearer $tokenSource" }

    }
    catch {
        
        $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json

    }
    
    $uri = $null

    if ($apiCall) {

        # Check if any data is left
        $uri = $apiCall.'@odata.nextLink'

        $apiCall

    }

}

$groups = $groups.value

$BucketOverview = @()

#Gets all groups in destination tenant.
$uriDestination = 'https://graph.microsoft.com/v1.0/groups/'


$groupsDestination = while (-not [string]::IsNullOrEmpty($uriDestination)) {

    # API Call
    $apiCall = try {
        
        Invoke-RestMethod -Method GET -Uri $uriDestination -ContentType "application/json" -Headers  @{Authorization = "Bearer $tokenDestination" }

    }
    catch {
        
        $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json

    }
    
    $uriDestination = $null

    if ($apiCall) {

        # Check if any data is left
        $uriDestination = $apiCall.'@odata.nextLink'

        $apiCall

    }

}

$groupsDestination = $groupsDestination.value

Foreach ($group in $groups) {

    #Checks if group in source tenant have a Planner plan.
    $groupID = $group.id
    $groupDisplayName = $group.displayName
    $uri2 = 'https://graph.microsoft.com/v1.0/groups/' + $groupID + '/planner/plans'
    $query2 = Invoke-RestMethod -Method GET -Uri $uri2 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
    $plans = $query2.value


    Foreach ($plan in $plans) {

        #Plan ID in source tenant.
        $planID = $plan.id

        #Finds all buckets in plan.
        $uri5 = 'https://graph.microsoft.com/v1.0/planner/plans/' + $planID + '/buckets/'
        $query5 = Invoke-RestMethod -Method GET -Uri $uri5 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
        $buckets = $query5.value | Sort-Object orderhint -Descending

        #Finds all categories in plan
        $uriDestination545 = 'https://graph.microsoft.com/v1.0/planner/plans/' + $planID + '/details/'
        $query545 = Invoke-RestMethod -Method GET -Uri $uriDestination545 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
        $categories = ((($query545.categoryDescriptions).psobject.members) | Where-Object { $_.MemberType -eq 'NoteProperty' }) | Select-Object name, value


        #Destination
        $GroupDestinationID = ($groupsDestination | Where-Object { $_.displayName -eq "$groupdisplayname" } | Select-Object ID).id
        $RequestBody2 = @"
        {
            "owner": "$groupdestinationID",
            "title": "$groupdisplayname",
          }

"@
        #Creates plan in destination tenant.
        $uriDestination2 = 'https://graph.microsoft.com/v1.0/planner/plans/'
        $queryDestination2 = Invoke-RestMethod -Method POST -Uri $uriDestination2   -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenDestination" } -Body $requestbody2
        $planDestination = $queryDestination2
        $planDestinationID = $queryDestination2.id
      
        #Create labels in destination tenant.
        $uriDestination223423 = 'https://graph.microsoft.com/v1.0/planner/plans/' + $planDestinationID + '/details'
        $queryDestination223423 = Invoke-RestMethod -Method GET -Uri $uriDestination223423   -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenDestination" }
        $planDestinationEtag = $queryDestination223423.'@odata.etag'

        $headers = @{ }
        $headers.Add("if-match", $planDestinationEtag)
        $headers.Add("Authorization", "Bearer $tokendestination")


        if (($categories | Where-Object { $_.name -eq 'category1' }).value) { $category1 = '"category1": "' + (($categories | Where-Object { $_.name -eq 'category1' }).value) + '",' }
        Else { $category1 = '"category1" : null,' }

        if (($categories | Where-Object { $_.name -eq 'category2' }).value) { $category2 = '"category2": "' + (($categories | Where-Object { $_.name -eq 'category2' }).value) + '",' }
        Else { $category2 = '"category2" : null,' }

        if (($categories | Where-Object { $_.name -eq 'category3' }).value) { $category3 = '"category3": "' + (($categories | Where-Object { $_.name -eq 'category3' }).value) + '",' }
        Else { $category3 = '"category3" : null,' }

        if (($categories | Where-Object { $_.name -eq 'category4' }).value) { $category4 = '"category4": "' + (($categories | Where-Object { $_.name -eq 'category4' }).value) + '",' }
        Else { $category4 = '"category4" : null,' }

        if (($categories | Where-Object { $_.name -eq 'category5' }).value) { $category5 = '"category5": "' + (($categories | Where-Object { $_.name -eq 'category5' }).value) + '",' }
        Else { $category5 = '"category5" : null,' }

        if (($categories | Where-Object { $_.name -eq 'category6' }).value) { $category6 = '"category6": "' + (($categories | Where-Object { $_.name -eq 'category6' }).value) + '",' }
        Else { $category6 = '"category6" : null,' }
        

        $RequestBody223423 = @"
        {
            "categoryDescriptions": {
                $category1
                $category2
                $category3
                $category4
                $category5
                $category6
            }
          }

"@



        $queryDestination2342342 = Invoke-RestMethod -Uri $uriDestination223423 -Headers $headers -Method PATCH -Body $RequestBody223423 -ContentType application/json





        Foreach ($bucket in $buckets) {

            #Creates plan buckets in destiantion tenant.
            $bucketnameDestination = $bucket.name
            $planDestinationID = $planDestination.id
            $RequestBody3 = @"
                            {
                    "name": "$bucketnamedestination",
                    "planId": "$planDestinationID",
                    "orderHint": " !"
                }
"@
            $uriDestination3 = 'https://graph.microsoft.com/v1.0/planner/buckets/'
            $queryDestination3 = Invoke-RestMethod -Method POST -Uri $uriDestination3   -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenDestination" } -Body $requestbody3
            $BucketDestination = $queryDestination3

            $Object = [PSCustomObject]@{

                'BucketIDSource'      = $bucket.id
                'BucketIDDestination' = $BucketDestination.id
                'BucketName'          = $bucketnameDestination

            }
            $BucketOverview += $Object


                
                
                    

        }

        
        #Finds all tasks for planc in source tenant.
        $uri55 = 'https://graph.microsoft.com/v1.0/planner/plans/' + $planID + '/tasks/'
        $query55 = Invoke-RestMethod -Method GET -Uri $uri55 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
        $tasks = $query55.value | Sort-Object orderHint  -Descending

        foreach ($task in $tasks) {

            $taskBucketID = $task.bucketId
            $taskTitle = $task.title
            $taskID = $task.id
            $taskPercentComplete = $task.percentComplete

            $TaskBucketDestinationID = ($BucketOverview | Where-Object { $_.BucketIDSource -eq $taskBucketID }).BucketIDDestination
            $TaskstartDateTime = If($task.startDateTime){ $task.startDateTime | Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'}
            $TaskdueDateTime = If($task.dueDateTime){$task.dueDateTime | Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'}

            If (!$TaskstartDateTime) { '' }
            Else { $TaskstartDateTime = [string]('"startDateTime" : "' + $TaskstartDateTime + '",') }
            If (!$TaskdueDateTime) { '' }
            Else { $TaskdueDateTime = [string]('"dueDateTime" : "' + $TaskdueDateTime + '",') }

            $taskappliedCategories = ((($task.appliedCategories).psobject.members) | Where-Object { $_.membertype -eq 'NoteProperty' }).name
            $CustomAppliedCategory = @()
            $AppliedCategoriesBody = @()
            If ($taskappliedCategories) {
                
                foreach ($appliedcategory in $taskappliedCategories) {
                    $applied = '"' + $appliedcategory + '": true,
                    '
                    $CustomAppliedCategory += $applied
                }

                $AppliedCategoriesBody = @"
                "appliedCategories": {
                    $customappliedcategory
                },
"@

            }

            

            #Users assigned to task in source tenant.
            $assignees = ($task.assignments | get-member -MemberType 'NoteProperty').name
            
            if ($assignees) {
                $Addusers = @()
                foreach ($assignee in $assignees) {
                    
                    $DestinationUserID = @()
                    $DestinationUPN = @()
                    $query5555 = @()
                    $query555 = @()
                    $SourceUPN = @()

                    $AddUser = @()
                    $uri555 = 'https://graph.microsoft.com/v1.0/users/' + "$assignee"
                    $query555 = Invoke-RestMethod -Method GET -Uri $uri555 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
                    $SourceUPN = $query555.userPrincipalName
                    $DestinationUPN = ($SourceUPN).Replace($domainSource, $domainDestination)
                    $DestinationUPN
                    If ($query555.userPrincipalName -like "#EXT#") {
                        $uri5555 = 'https://graph.microsoft.com/v1.0/users/?$filter=usertype' + ' eq ' + '''Guest''' + ' and mail eq ' + "$($query555.mail)"
                        $query5555 = Invoke-RestMethod -Method GET -Uri $uri5555 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokendestination" }
                        $DestinationUserID = $query5555.ID
                
                    }
                    Else {
                        $uri5555 = 'https://graph.microsoft.com/v1.0/users/' + "$DestinationUPN"
                        $query5555 = Invoke-RestMethod -Method GET -Uri $uri5555 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokendestination" }
                        $DestinationUserID = $query5555.ID
                    }
        
                    If($DestinationUserID){
                    $AddUser = @"
                "$DestinationUserID": {
                    "@odata.type": "#microsoft.graph.plannerAssignment",
                    "orderHint": " !"
                  },
"@
            
                    $Addusers += $AddUser
                }
                

            
            
                }
                $RequestBody4 = @"
            {
                "planId": "$planDestinationID",
                "bucketId": "$TaskBucketDestinationID",
                "title": "$tasktitle",
                "percentComplete": "$taskpercentcomplete",
                $TaskstartDateTime
                $TaskdueDateTime
                $AppliedCategoriesBody
                "assignments": {
                  $addusers
                },
              }
"@

            }
            Else {
                $RequestBody4 = @"
                {
                    "planId": "$planDestinationID",
                    "bucketId": "$TaskBucketDestinationID",
                    "title": "$tasktitle",
                    "percentComplete": "$taskpercentcomplete",
                    $TaskstartDateTime
                    $TaskdueDateTime
                    $AppliedCategoriesBody
         
                  }
"@


            }




            #Creates task in destination tenant.
            $uriDestination4 = 'https://graph.microsoft.com/v1.0/planner/tasks/'
            $queryDestination4 = Invoke-RestMethod -Method POST -Uri $uriDestination4 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokendestination" } -Body $RequestBody4
            $TaskIDDestination = $queryDestination4.ID
            $RequestBody4

            $uriDestination6 = 'https://graph.microsoft.com/v1.0/planner/tasks/' + $TaskIDDestination + '/details'
            $queryDestination6 = Invoke-RestMethod -Method GET -Uri $uriDestination6 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokendestination" }

            $uri4323426 = 'https://graph.microsoft.com/v1.0/planner/tasks/' + $taskID + '/details'
            $query4323426 = Invoke-RestMethod -Method GET -Uri $uri4323426 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
            
            $TaskEtagDestination = $queryDestination6.'@odata.etag'
            $Description = $query4323426.description
            
            If (!$Description) { $Description = '"description" : null,' }
            Else { $Description = '"description" : "' + $Description + '"' }

            $RequestBody23111 = @"
                    {
                        $Description  
                    }
"@

            $headers = @{ }
            $headers.Add("if-match", $TaskEtagDestination)
            $headers.Add("Authorization", "Bearer $tokendestination")

            #Updates task in destination tenant.
            $queryDestination6154 = Invoke-RestMethod -Uri $uriDestination6 -Headers $headers -Method PATCH -Body $RequestBody23111 -ContentType application/json

                       



            $uri123 = 'https://graph.microsoft.com/v1.0/planner/tasks/' + $taskID + '/details'
            $query123 = Invoke-RestMethod -Method GET -Uri $uri123 -ContentType "application/json" -Headers @{Authorization = "Bearer $tokenSource" }
            $TaskDetails = (($query123.checklist).psobject.Properties).value

            

            Foreach ($checklistitem in $TaskDetails) {

                #Destination
                $checklistItemGuid = (New-Guid).Guid
                $IsChecked = $checklistitem.isChecked
                $CheckListItemTitle = $checklistitem.title
	
                $RequestBody5 = @"
                    {
                        "checklist": {
                            "$checklistItemGuid": {
                                "@odata.type": "#microsoft.graph.plannerChecklistItem",
                                "isChecked": "$IsChecked",
                                "title": "$checklistitemtitle"
                            }
                        }
                    }
"@

                $headers = @{ }
                $headers.Add("if-match", $TaskEtagDestination)
                $headers.Add("Authorization", "Bearer $tokendestination")
                
                #Creates checklist for task in destiantino tenant.
                $uriDestination5 = "https://graph.microsoft.com/v1.0/planner/tasks/" + "$TaskIDDestination" + "/Details"
                $queryDestination5 = Invoke-RestMethod -Uri $uriDestination5 -Headers $headers -Method PATCH -Body $RequestBody5 -ContentType application/json
                $RequestBody5
                



            }


        }
  

    }

}