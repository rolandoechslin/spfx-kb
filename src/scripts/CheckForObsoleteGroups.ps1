# A script to check for Office 365 Groups that might be potentially obsolete and therefore candidates to be removed.
# We check the group mailbox to see what the last time a conversation item was added to the Inbox folder.
# Another check sees whether a low number of items exist in the mailbox, which would show that it's not being used.
# We also check the group document library in SharePoint Online to see whether it exists or has been used in the last 90 days.

# Created 29-July-2016  Tony Redmond
# V2.0 5-Jan-2018

# Check that we are connected to Exchange Online

Try {
  $OrgName = (Get-OrganizationConfig).Name
   }
  Catch
    {
     Write-Host "Your PowerShell session is not connected to Exchange Online."
     Write-Host "Please connect to Exchange Online using an administrative account and retry."
     Break
     }

# And check that we're connected to SharePoint Online as well
Try {
  $SPOCheck = (Get-SPOSite).StorageQuota
   }
  Catch
    {
     Write-Host "Your PowerShell session is not connected to SharePoint Online."
     Write-Host "Please connect to SharePoint Online using an administrative account and retry."
     Break
    }

# OK, we seem to be fully connected to both Exchange Online and SharePoint Online...
Write-Host "Checking for Obsolete Office 365 Groups in the tenant:" $OrgName

# Setup some stuff we use
$WarningDate = (Get-Date).AddDays(-90)
$WarningEmailDate = (Get-Date).AddDays(-365)
$Today = (Get-Date)
$Date = $Today.ToShortDateString()
$ObsoleteSPOGroups = 0
$ObsoleteEmailGroups = 0
$Report = @()
$ReportFile = "c:\temp\ListOfObsoleteGroups.html"
$htmlhead="<html>
    <style>
    BODY{font-family: Arial; font-size: 8pt;}
    H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
    H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
    H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
    TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
    TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
    TD{border: 1px solid #969595; padding: 5px; }
    td.pass{background: #B7EB83;}
    td.warn{background: #FFF275;}
    td.fail{background: #FF2626; color: #ffffff;}
    td.info{background: #85D4FF;}
    </style>
    <body>
          <div align=center>
          <p><h1>Report of Potentially Obsolete Office 365 Groups</h1></p>
          <p><h3>Generated: " + $date + "</h3></p></div>"

# Get a list of all Office 365 Groups in the tenant
Write-Host "Extracting list of Office 365 Groups to be checked..."
$TeamsFalse = 0
$TeamsEnabled = $False
$Groups = Get-UnifiedGroup | Sort-Object WhenCreated
Write-Host "Processing" $Groups.Count "groups"

# Main loop
ForEach ($G in $Groups) {
  Write-Host "Checking Group:" $G.DisplayName
  $ObsoleteReportLine = $G.DisplayName
  $SPOStatus = "Normal"
  $SPOActivity = "Document library in use"
  $NumberWarnings = 0
  $NumberofChats = 0
  $TeamChatData = $Null
  $LastItemAddedtoTeams = "No chats"
  $MailboxStatus = $Null

# Fetch information about activity in the Inbox folder of the group mailbox
  $Data = (Get-MailboxFolderStatistics -Identity $G.Alias -IncludeOldestAndNewestITems -FolderScope Inbox)
  $LastConversation = $Data.NewestItemReceivedDate
  $NumberConversations = $Data.ItemsInFolder
  $MailboxStatus = "Normal"

  If ($Data.NewestItemReceivedDate -le $WarningEmailDate)
     {
     #Write-Host "Last conversation item created in" $G.DisplayName "was" $Data.NewestItemReceivedDate "-> Could be Obsolete?"
     $ObsoleteEmailGroups = $ObsoleteEMailGroups + 1
     $ObsoleteReportLine = $ObsoleteReportLine + " Last conversation dated: " + $Data.NewestItemReceivedDate + "."
     $NumberWarnings++
     }
  Else
     { # Some conversations exist - but if there are fewer than 20, we should flag this...
     If ($Data.ItemsInFolder -lt 20)
        {
          $ObsoleteReportLine = $ObsoleteReportLine + " Only " + $Data.ItemsInFolder + " conversation items found."
          $MailboxStatus = "Low number of conversations found"
          $NumberWarnings++
        }
     Else
        {
        # Write-Host $G.DisplayName "has" $Data.ItemsInFolder "size of conversation items: " $Data.FolderSize
     }
  }

# Loop to check SharePoint document library
  If ($G.SharePointDocumentsUrl -ne $Null)
     {
     $SPOSite = (Get-SPOSite -Identity $G.SharePointDocumentsUrl.replace("/Shared Documents", ""))
     $AuditCheck = $G.SharePointDocumentsUrl + "/*"
     $AuditRecs = 0
     $AuditRecs = (Search-UnifiedAuditLog -RecordType SharePointFileOperation -StartDate $WarningDate -EndDate $Today -ObjectId $AuditCheck -SessionCommand ReturnNextPreviewPage)
     If ($AuditRecs -eq $null)
        {
        #Write-Host "No audit records found for" $SPOSite.Title "-> It is potentially obsolete!"
        $ObsoleteSPOGroups++
        $ObsoleteReportLine = $ObsoleteReportLine + " No SPO activity detected in the last 90 days."
        }
     Else
        {
        #Write-Host $AuditRecs.Count "audit records found for " $SPOSite.Title "the last is dated" $AuditRecs.CreationDate[0]
      }}
  Else
        {
# The SharePoint document library URL is blank, so the document library was never created for this group
        #Write-Host "SharePoint has never been used for the group" $G.DisplayName
        $ObsoleteSPOGroups++
        $ObsoleteReportLine = $ObsoleteReportLine + " SPO document library never created."
        }
# Report to the screen what we found - but only if something was found...
 If ($ObsoleteReportLine -ne $G.DisplayName)
    {
    Write-Host $ObsoleteReportLine
    }
# Generate the number of warnings to decide how obsolete the group might be...
 If ($AuditRecs -eq $Null)
     {
      $SPOActivity = "No SPO activity detected in the last 90 days"
      $NumberWarnings++
     }
  If ($G.SharePointDocumentsUrl -eq $Null)
     {
      $SPOStatus = "Document library never created"
      $NumberWarnings++
     }

   $Status = "Pass"
   If ($NumberWarnings -eq 1)
      {
      $Status = "Warning"
   }
   If ($NumberWarnings -gt 1)
      {
      $Status = "Fail"
   }

# Check whether the group is enabled for Teams

 Try {
        $teamschannels = Get-TeamChannel -GroupId $G.ExternalDirectoryObjectId
        $TeamsEnabled = $True
        } catch {
            $ErrorCode = $_.Exception.ErrorCode
            Switch ($ErrorCode) {
              "404" {
                  $TeamsEnabled = $False
                  $TeamsFalse++
                  break;
              }
              "403" {
                  $TeamsEnabled = $True
                  break;
              }
               default {
              # Write-Error ("Unknown ErrorCode trying to 'Get-TeamChannel -GroupId {0}' :: {1}" -f $G, $ErrorCode)
               $TeamEnabled = $False
              }
      }
}

# If Team-Enabled, we can find the date of the last chat compliance record
   If ($TeamsEnabled -eq $True)
     {
     $TeamChatData = (Get-MailboxFolderStatistics -Identity $G.Alias -IncludeOldestAndNewestItems -FolderScope ConversationHistory)
     If ($TeamChatData.ItemsInFolder[1] -ne 0) {
         $LastItemAddedtoTeams = $TeamChatData.NewestItemReceivedDate[1]
         $NumberofChats = $TeamChatData.ItemsInFolder[1]
         }
     }

# Generate a line for this group for our report
   $ReportLine = [PSCustomObject][Ordered]@{
         GroupName           = $G.DisplayName
         ManagedBy           = (Get-Mailbox -Identity $G.ManagedBy[0]).DisplayName
         Members             = $G.GroupMemberCount
         ExternalGuests      = $G.GroupExternalMemberCount
         Description         = $G.Notes
         MailboxStatus       = $MailboxStatus
         TeamEnabled         = $TeamsEnabled
         LastChat            = $LastItemAddedtoTeams
         NumberChats         = $NumberofChats
         LastConversation    = $LastConversation
         NumberConversations = $NumberConversations
         SPOActivity         = $SPOActivity
         SPOStatus           = $SPOStatus
         NumberWarnings      = $NumberWarnings
         Status              = $Status
   }
# And store the line in the report object
  $Report += $ReportLine

}

# Create the HTML report
$GoodTeams = $Groups.Count - $TeamsFalse
$htmlbody = $Report | ConvertTo-Html -Fragment
$htmltail = "<p>Report created for: " + $OrgName + "
            </p>
            <p>Number of groups scanned: " + $Groups.Count + "</p>" +
            "<p>Number of potentially obsolete groups (based on document library activity): " + $ObsoleteSPOGroups + "</p>" +
            "<p>Number of potentially obsolete groups (based on conversation activity): " + $ObsoleteEmailGroups +
            "<p>Number of Teams-enabled groups    : " + $GoodTeams + "</p>" +
            "<p>Percentage of Teams-enabled groups: " + ($GoodTeams/$Groups.Count).tostring("P") + "</body></html>"
$htmlreport = $htmlhead + $htmlbody + $htmltail
$htmlreport | Out-File $ReportFile  -Encoding UTF8

# Summary note
Write-Host $ObsoleteSPOGroups "obsolete group document libraries and" $ObsoleteEmailGroups "obsolete email groups found out of" $Groups.Count "checked"
Write-Host "Summary report available in" $ReportFile
