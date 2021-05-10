# Teams Powershell

- [PowerShell Reference for Office Products](https://github.com/microsoftdocs/office-docs-powershell)

## Check Version

Latest Version

- https://www.powershellgallery.com/packages/MicrosoftTeams/0.9.6

```Powershell
Get-Module MicrosoftTeams* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
```

## Update Module to latest version

```Powershell
Update-Module MicrosoftTeams
```

## Delete old version

```Powershell
Get-InstalledModule -Name "MicrosoftTeams" -RequiredVersion 0.9.0 | Uninstall-Module
```

## Connect

- https://docs.microsoft.com/en-us/powershell/module/teams/connect-microsoftteams?view=teams-ps

## Disconnect

- https://docs.microsoft.com/en-us/powershell/module/teams/disconnect-microsoftteams?view=teams-ps

## Teamsmanagment

- [Managing Teams – Movers and Leavers](https://blog.eardley.org.uk/2021/04/managing-teams-movers-and-leavers/)
- [TeamsManagement Powershell](https://github.com/al-eardley/TeamsManagement/blob/main/TeamsManagement/TeamsManagement.psm1)
- [Replace the membership of a user in a Microsoft Group or Microsoft Team](https://www.nubo.eu/Replace-Membership-In-A-Microsoft-Group-Or-Team/)