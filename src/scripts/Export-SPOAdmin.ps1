# https://github.com/AlanPS1/PowerShell-Scripts/blob/main/Export-SPOAdmin.ps1

New-Module {

    Function Invoke-Prerequisites {

        [OutputType()]
        [CmdletBinding()]
        Param (
            [Parameter(Position = 1)]
            [string] $Tenant,
            [Parameter(Position = 2)]
            [string] $ClientID,
            [Parameter(Position = 3)]
            [string] $CertPath,
            [Parameter(Position = 4)]
            [string] $CertPass
        )

        $Script:Stopwatch = [system.diagnostics.stopwatch]::StartNew()

        If ((Get-Culture).LCID -eq "1033") {

            $Script:Date = (Get-Date).tostring("MM-dd-yy")

        }
        Else {

            $Script:Date = (Get-Date).tostring("dd-MM-yy")

        }

        $Script:Tenant = $Tenant

        $Script:TenantUrl = "https://$($Tenant).sharepoint.com"
        $Script:AadDomain = "$($Tenant).onmicrosoft.com"
        $Script:ClientID = $ClientID
        $Script:CertPass = $CertPass
        $Script:CertPath = $CertPath

    }

    Function Get-Administrators {

        $Admins = Get-PnPSiteCollectionAdmin

        <# Below gets users who have full control - set as administrator via admin portal #>
        ForEach ($Admin in $Admins | Where-Object { $_ -ne "System Account" }) {

            $Datum = New-Object -TypeName PSObject

            $Datum | Add-Member -MemberType NoteProperty -Name Tenant -Value $Tenant
            $Datum | Add-Member -MemberType NoteProperty -Name Site -Value $SiteUrl
            $Datum | Add-Member -MemberType NoteProperty -Name Group -Value "Aministrators"

            Switch ($Admin.PrincipalType) {

                "User" { 
                    $Datum | Add-Member -MemberType NoteProperty -Name Member -Value $Admin.Title 
                }
                "SecurityGroup" {
                    If ($Admin.Title -ne "Company Administrator") {
                        $Datum | Add-Member -MemberType NoteProperty -Name Member -Value "$($Admin.Title) - AD Group" 
                    }
                    ElseIf ($Admin.Title -eq "SharePoint Service Administrator") {
                        $Datum | Add-Member -MemberType NoteProperty -Name Member -Value $($Admin.Title)
                    }
                    Else {
                        $Datum | Add-Member -MemberType NoteProperty -Name Member -Value "Global Admins" 
                    }
                }

            }

            $Datum | Add-Member -MemberType NoteProperty -Name Subsite -Value "No"
            $Datum | Add-Member -MemberType NoteProperty -Name Permissions -Value "Unique"

            $Script:Data += $Datum

        }

    }

    Function Get-OwnerNoGroup {

        Param(
            [Parameter(Mandatory = $true, Position = 0)]
            [string]$Subsite
        )

        $Web = Get-PnPWeb -Includes RoleAssignments

        ForEach ($RA in $Web.RoleAssignments) {

            $RoleBindings = Get-PnPProperty -ClientObject $RA -Property RoleDefinitionBindings
            $PrincipalType = Get-PnPProperty -ClientObject $($RA.Member) -Property PrincipalType

            $RoleTypeKind = ($RoleBindings.RoleTypeKind).ToString()
            $PType = $PrincipalType.ToString()

            If ($PType -eq "User" -and $RoleTypeKind -eq "Administrator") {

                $Title = Get-PnPProperty -ClientObject $($RA.Member) -Property Title

                $Datum = New-Object -TypeName PSObject

                $Datum | Add-Member -MemberType NoteProperty -Name Tenant -Value $Tenant
                If ($Subsite -eq "No") { 
                    $Datum | Add-Member -MemberType NoteProperty -Name Site -Value $SiteUrl 
                } 
                Else { 
                    $Datum | Add-Member -MemberType NoteProperty -Name Site -Value $SubsiteUrl 
                }
                $Datum | Add-Member -MemberType NoteProperty -Name Group -Value "N/A"
                $Datum | Add-Member -MemberType NoteProperty -Name Member -Value $Title
                $Datum | Add-Member -MemberType NoteProperty -Name Subsite -Value $Subsite
                $Datum | Add-Member -MemberType NoteProperty -Name Permissions -Value "Unique"

                $Script:Data += $Datum

            }

        }

    }

    Function Get-OwnerFromGroup {

        Param(
            [Parameter(Mandatory = $true, Position = 0)]
            [string]$Subsite,
            [Parameter(Position = 1)]
            [string]$SiteUrl,
            [Parameter(Position = 1)]
            [string]$SubsiteUrl
        )

        # HasUniqueRoleAssignments
        $Groups = Get-PnPGroup | 
            Where-Object { $_.Title -notlike "SharingLinks.*" -and $_.Title -notlike "Limited Access*" } | 
            Select-Object Title, Users, PrincipalType, Id

        If ($Subsite -eq "No") { 
            Write-Host "Auditing: $($SiteUrl)" -ForegroundColor Cyan
        } 
        Else { 
            Write-Host "Auditing: $($SubsiteUrl)" -ForegroundColor Cyan
        }

        ForEach ($Group in $Groups | Where-Object { $_.PrincipalType -eq "SharePointGroup" }) {

            $GroupPermission = Get-PnPGroupPermissions -Identity $Group.Title -ErrorAction SilentlyContinue | 
                Where-Object { $_.Hidden -like "False" } 

            If ($GroupPermission.RoleTypeKind -eq "Administrator") {
                
                ForEach ($G in $Group | Where-Object { $_.Users.Title -ne "System Account" }) {

                    $Members = Get-PnPGroupMembers -Identity $G.Id | Select-Object LoginName, Title, PrincipalType
                    $Members = $Members | Where-Object { $_.Title -ne "System Account" -and $_.PrincipalType -eq "User" } 

                    If ($Members) {

                        ForEach ($Member in $Members) {

                            If ($Site.HasUniqueRoleAssignments -eq $null -or $Site.HasUniqueRoleAssignments -eq $true) { 
                                $InheritsPermissions = "Unique" 
                            }
                            Else { 
                                $InheritsPermissions = "Inherited"
                            }

                            $Datum = New-Object -TypeName PSObject

                            $Datum | Add-Member -MemberType NoteProperty -Name Tenant -Value $Tenant
                            If ($Subsite -eq "No") { 
                                $Datum | Add-Member -MemberType NoteProperty -Name Site -Value $SiteUrl 
                            } 
                            Else { 
                                $Datum | Add-Member -MemberType NoteProperty -Name Site -Value $SubsiteUrl 
                            }
                            $Datum | Add-Member -MemberType NoteProperty -Name Group -Value $Group.Title
                            $Datum | Add-Member -MemberType NoteProperty -Name Member -Value $Member.Title
                            $Datum | Add-Member -MemberType NoteProperty -Name Subsite -Value $Subsite
                            $Datum | Add-Member -MemberType NoteProperty -Name Permissions -Value $InheritsPermissions

                            $Script:Data += $Datum

                        }

                    }

                }

            }

        }

    }

    Function Invoke-FilePicker {

        Write-Host "Select your certificate .pfx file"

        Add-Type -AssemblyName System.Windows.Forms

        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $Dialog.InitialDirectory = "$InitialDirectory"
        $Dialog.Title = "Select your certificate .pfx file"
        $Dialog.Filter = "Certificate file|*.pfx"  
        $Dialog.Multiselect = $false
        $Result = $Dialog.ShowDialog()

        If ($Result -eq 'OK') {

            Try {

                $Script:CertPath = $Dialog.FileNames
            }

            Catch {

                $Script:CertPath = $null
                Break
            }
        }

        Else {

            Write-Host "Notice: No file selected." -ForegroundColor Yellow
            Break

        }
        
    }

    Function Export-SPOAdmin {

        [OutputType()]
        [CmdletBinding()]
        Param (
            [Parameter(
                Mandatory = $true, 
                Position = 1, 
                HelpMessage = "Enter your O365 tenant name, like 'contoso'"
            )]
            [ValidateNotNullorEmpty()]
            [string] $Tenant,
            [Parameter(
                Mandatory = $true, 
                Position = 2, 
                HelpMessage = "Enter your Az App Client ID"
            )]
            [ValidateNotNullorEmpty()]
            [string] $ClientID
        )

        #ToDo: Exclude SubSites Switch

        BEGIN {

            Invoke-FilePicker

            $Script:CertPass = Read-Host "Enter your certificate password"

            $Params = @{
                Tenant   = $Tenant
                ClientID = $ClientID
                CertPath = "$CertPath"
                CertPass = $CertPass
            }

            Invoke-Prerequisites @Params

            $Params = @{
                ClientId            = $ClientID
                CertificatePath     = $CertPath
                CertificatePassword = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
                Url                 = $TenantUrl
                Tenant              = $AadDomain
            }

        }
        PROCESS {

            Connect-PnPOnline @Params -WarningAction SilentlyContinue
            
            $Script:Sites = Get-PnPTenantSite -Filter "Url -notlike '*/portals/*'" | Where-Object -Property Template -NotIn (
                "SRCHCEN#0", 
                "SPSMSITEHOST#0", 
                "APPCATALOG#0", 
                "POINTPUBLISHINGHUB#0", 
                "EDISC#0", 
                "STS#-1"
            )

            $Sites = $Sites.Url

            <# For Testing: Add - "$Sites = $Sites | Select -First 5 -Skip 5" or similar below this comment #>

            Disconnect-PnPOnline

            $Script:Data = @()

            ForEach ($SiteUrl in $Sites) {

                $Subsite = "No"

                $Params = @{
                    ClientId            = $ClientID
                    CertificatePath     = $CertPath
                    CertificatePassword = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
                    Url                 = $SiteUrl
                    Tenant              = $AadDomain
                }

                Connect-PnPOnline @Params -WarningAction SilentlyContinue

                <# Below gets users who have full control - directly applied at the root #>
                Get-OwnerNoGroup -Subsite $Subsite

                <# Below gets users who have full control - inherited from a group #>
                Get-OwnerFromGroup -Subsite $Subsite -SiteUrl $SiteUrl

                <# Below gets users who have full control - set as administrator via admin portal #>
                Get-Administrators

                $SubSites = Get-PnpSubwebs -Recurse -Includes HasUniqueRoleAssignments # need to do more with this
                # $SubSites = Get-PnPSubWebs -Recurse

                Disconnect-PnPOnline

                If ($SubSites) {

                    ForEach ($Site in $SubSites) {

                        $Subsite = "Yes"
                        $SubsiteUrl = $Site.Url

                        $Params = @{
                            ClientId            = $ClientID
                            CertificatePath     = $CertPath
                            CertificatePassword = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
                            Url                 = $SubsiteUrl
                            Tenant              = $AadDomain
                        }

                        Connect-PnPOnline @Params -WarningAction SilentlyContinue

                        <# Below gets users who have full control - directly applied at the root #>
                        Get-OwnerNoGroup -Subsite $Subsite

                        <# Below gets users who have full control - inherited from a group #>
                        Get-OwnerFromGroup -Subsite $Subsite -SubsiteUrl $SubsiteUrl

                        Write-Host "Subsite processed: " -ForegroundColor White -NoNewline
                        Write-Host "$($SubsiteUrl)" -ForegroundColor DarkGreen

                        Disconnect-PnPOnline

                    }

                }

                Write-Host "Site processed: " -ForegroundColor White -NoNewline
                Write-Host "$($SiteUrl)" -ForegroundColor Green

            }

        }
        END {
            
            If ($Data) {

                $Path = ".\"
                $FileName = "$Tenant-SPOAdmins-$Date.csv"
                $Data | Export-Csv -Path "$Path$FileName" -NoTypeInformation
                $Location = Get-Location

                Write-Host
                Write-Host "File called " -NoNewline
                Write-Host "'$FileName' " -ForegroundColor Green -NoNewline
                Write-Host "exported to " -NoNewline
                Write-Host "$Location" -ForegroundColor Green
                Write-Host
                
            }
            Else {

                Write-Host "No Data to Export"

            }

            $TotalSecs = [math]::Round($StopWatch.Elapsed.TotalSeconds, 0)
            $StopWatch.Stop()

            If ($TotalSecs -lt 60) { 

                Write-Host "Job Took " -NoNewline
                Write-Host "$TotalSecs Seconds " -NoNewline -ForegroundColor Cyan
                Write-Host "to Complete"


            }
            ElseIf ($TotalSecs -ge 60 -and $TotalSecs -lt 3600) {

                $Count = New-TimeSpan -Seconds $TotalSecs

                Write-Host "Job Took " -NoNewline
                Write-Host "$($Count.Minutes) Minutes " -NoNewline -ForegroundColor Cyan
                Write-Host "and $($Count.Seconds) Seconds " -NoNewline -ForegroundColor Cyan
                Write-Host "to Complete"
            }
            Else {

                $Count = New-TimeSpan -Seconds $TotalSecs

                Write-Host "Job Took " -NoNewline
                Write-Host "$($Count.Hours) Hours, " -NoNewline -ForegroundColor Cyan
                Write-Host "$($Count.Minutes) Minutes and " -NoNewline -ForegroundColor Cyan
                Write-Host "$($Count.Seconds) Seconds " -NoNewline -ForegroundColor Cyan
                Write-Host "to Complete"

            }

        }

    }

    Export-ModuleMember Export-SPOAdmin

} | Out-Null