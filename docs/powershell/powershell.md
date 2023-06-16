# Links

## Profile

```ps
code $PROFILE
```

```ps
Import-Module -Name CLI.Microsoft365.PowerShell.Predictor
Import-Module posh-git
Import-Module -Name Terminal-Icons
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression
```

- [My Ultimate PowerShell prompt with Oh My Posh and the Windows Terminal](https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal)
- [Sanselman - PowerShell_profile](https://gist.github.com/shanselman/25f5550ad186189e0e68916c6d7f44c3?WT.mc_id=-blog-scottha)

## Resources

- [Windows PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/developer/windows-powershell?view=powershell-7.1)
- [The PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-7.1)
- [janikvonrotz-awesome-powershell](https://github.com/janikvonrotz/awesome-powershell)
- [How to: SnipScripts](https://github.com/TechSnips/SnipScripts)
- [Andres Bohren - PowerShellScripts](https://github.com/BohrenAn/GitHub_PowerShellScripts)
- [Report on Microsoft 365](https://github.com/michevnew/PowerShell)
- [Office 365 for IT Pros PowerShell examples](https://github.com/12Knocksinna/Office365itpros)
- [admindroid-community](https://github.com/admindroid-community/powershell-scripts)

## Syntax

- [Powershell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/best-practices/introduction)
- [About Preference Variables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.1)
- [powershell basic cheat sheet](http://ramblingcookiemonster.github.io/images/Cheat-Sheets/powershell-basic-cheat-sheet2.pdf)
- [powershell-ref](http://ligman.me/1n3mAUZ)
- [PowerShell Cheat Sheet](https://www.sharepointeurope.com/powershell-cheat-sheet/)
- [awesome-powershell](https://github.com/janikvonrotz/awesome-powershell)
- [Highway to PowerShell - Ep 1](https://www.youtube.com/watch?v=nFyhmBIw8jc)
- [PowerShellGeek Quickreference](https://github.com/damianscoles/PowerShellGeek/blob/master/PowerShellQuickReferences/PowerShellQuickReference-PowerShell7.0-v1.04.pdf)

```ps
Get-Command -Name Get-PnPSite -Syntax
```

## Hashtable

- [Everything you wanted to know about hashtables](https://kevinmarquette.github.io/2016-11-06-powershell-hashtable-everything-you-wanted-to-know-about)

## Coding Tips

- [Backticks vs. Splatting vs. Class Objects](https://helloitsliam.com/2021/10/22/microsoft-graph-powershell-backticks-vs-splatting-vs-class-objects/)
- [10 suggestions to improve your next PowerShell script](https://tech.nicolonsky.ch/10-suggestions-to-improve-your-next-PowerShell-script/)
- [PowerShell Tips & Tricks / jdhitsolutions](https://jdhitsolutions.com/blog/powershell-tips-tricks-and-advice/)

## Testing Tips

- [Performing Static Code Analysis on PowerShell Module and Scripts](https://helloitsliam.com/2021/11/19/performing-static-code-analysis-on-powershell-module-and-scripts/)

## Performance Tips

- [PowerShell performance tips](https://www.blimped.nl/blogs/powershell-performance-tips/)

## VS.Code Settings

- [How To Make Visual Studio Code Look And Behave Like The PowerShell ISE](https://blog.techsnips.io/how-to-make-visual-studio-code-look-and-behave-like-the-powershell-ise/)

## Blogs

- [mikefrobbins](http://mikefrobbins.com)

## Office 365 Groups

- [Adding a New Office 365 Group to an Existing (Classic) SharePoint Online Site](https://www.petri.com/adding-new-office-365-group-existing-classic-sharepoint-online-site)
- [Useful PowerShell cmdlets to administer Office 365 Groups](https://www.sharepointeurope.com/useful-powershell-cmdlets-administer-office-365-groups/)
- [MY MOST USED POWERSHELL SCRIPTS FOR MANAGING SHAREPOINT ONLINE](https://laurakokkarinen.com/my-most-used-powershell-scripts-for-managing-sharepoint-online/)
- [Undocumented Features](https://www.undocumented-features.com/2019/01/31/getting-around-the-basics-of-azure-automation-for-office-365/)

## SharePoint 2016

- <https://github.com/harbars/PnP-Tools/tree/master/Scripts>
- <https://github.com/harbars/SPAT16>

## Modules

- <http://bobmixon.com/2018/06/powershell-and-sharepoint-modules-part-1/>
- <https://github.com/mikefrobbins/Plaster/tree/master/Template>

```Powershell
$env:PSModulePath
(Get-Module -ListAvailable Pnp.*).path

Get-InstalledModule | select name, version
```

## Slides

- [Code & Slides from my Presentations](https://github.com/mikefrobbins/Presentations)

## AzureAD

- [The PowerShell Gallery- Overview](https://docs.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-7.1)
- [Powershellgallery - Module - AzureAD](https://www.powershellgallery.com/packages/AzureAD/)
- [Get Azure AD audit and sign-in Logs using PowerShell and AzureADPreview module](https://mosshowto.blogspot.com/2019/08/azure-ad-logs-powershell-azureadpreview.html)
- [How to Upgrade Office 365 PowerShell Scripts to Use the Graph API](https://office365itpros.com/2021/07/26/how-upgrade-powershell-scripts-graph-api/?utm_source=rss&utm_medium=rss&utm_campaign=how-upgrade-powershell-scripts-graph-api)

```Powershell
Install-Module -Name AzureAD
```

## Loaded Modules

- [How to list all of the assemblies loaded in a PowerShell session?](https://www.koskila.net/how-to-list-all-of-the-assemblies-loaded-in-a-powershell-session/)

```Powershell
[System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location | Sort-Object -Property FullName | Select-Object -Property FullName, Location, GlobalAssemblyCache, IsFullyTrusted | Out-GridView
```
