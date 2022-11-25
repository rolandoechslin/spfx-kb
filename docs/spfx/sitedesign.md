# SiteDesign

## Best practise

- [Best Practices on SharePoint Site Design](https://sharepointmaven.com/best-practices-sharepoint-site-design)
- [SharePoint Modern Page Best Practices](https://sharepointmaven.com/sharepoint-modern-page-best-practices)
- [Site Designs for Good Information Architecture](https://sympmarc.com/2019/12/08/dear-microsoft-site-designs-for-good-information-architecture-too-brittle/)
- [Site Design Deployment Made Easy](https://blog.eardley.org.uk/2020/02/site-design-deployment-made-easy/)
- [How to create a Board of Directors Site in SharePoint Online](https://sharepointmaven.com/how-to-create-a-board-of-directors-site-in-sharepoint-online/)

## List templates

- [The broad world of templates when using Microsoft Lists](https://www.youtube.com/watch?v=uTZkkLut3YY)

## Modern Site Provisioning

- [SPSBE18: New era of customizing site provisioning](https://www.slideshare.net/OlliJskelinen/spsbe18-new-era-of-customizing-site-provisioning)
- [SPSBE2018-powershell](https://github.com/ollij/Demos/tree/master/SPSBE2018-powershell)
- [Sample mit Flow und Azure Function](https://github.com/SharePoint/sp-dev-site-scripts/tree/master/samples/site-azure-function)

- [Provisioning complex Modern Sites with Azure Functions and Microsoft Flow – Part 1 – Architecture](https://asishpadhy.com/2018/08/07/provisioning-complex-modern-sites-with-azure-functions-and-microsoft-flow-part-1-architecture)
- [Provisioning complex Modern Sites with Azure Functions and Flow – Part 2 – Create and Apply Template](https://asishpadhy.com/2018/08/13/provisioning-complex-modern-sites-with-azure-functions-and-flow-part-2-create-and-apply-template/)
- [Provisioning complex Modern Sites with Azure Functions and Flow – Part 3 – Post Provisioning Site Configuration](https://asishpadhy.com/2018/10/02/provisioning-complex-modern-sites-with-azure-functions-and-flow-part-3-post-provisioning-site-configuration/)
![modernsitesprovisioningflow](https://asishpadhyblog.files.wordpress.com/2018/08/modernsitesprovisioningflow_provisioningprocess.png?w=1024&h=733&crop=1)
- [Building SharePoint Site Designs with Themes and Azure Functions](https://bob1german.com/2018/07/31/building-sharepoint-site-designs-with-themes-and-azure-functions)
- [Update site design to all of your sites](https://letslearnoffice365.wordpress.com/2019/04/16/update-site-design-to-all-of-your-sites/)

## Deploying

- [Deploying Application Customizers with a Site Design](https://spdcp.com/2019/10/24/deploying-application-customizers-with-a-site-design/)

## Flow / REST

- [Invoking a Site Design Task using REST](https://beaucameron.net/2019/01/10/invoking-a-site-design-task-using-rest/)
- [Invoking unlimited actions with Site Design Tasks and Microsoft Flow](http://rezadorrani.com/index.php/2019/01/14/invoking-unlimited-actions-with-site-design-tasks-and-microsoft-flow/)
- [Create Site Script and Site Template Using Power Automate in SharePoint](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/create-site-script-and-site-template-using-power-automate-in/ba-p/2710696)
- [How to Apply Site template (Site Design) via Power Automate](https://365corner.pl/2021/10/14/how-to-apply-site-template-via-power-automate/)
- [SharePoint PnP Provisioning with Azure Logic Apps and Azure Automation](https://thesharepointfarm.com/2020/12/sharepoint-azure-pnp-provisioning/)
- [Modern SharePoint site creation with site designs and REST](https://simonagren.github.io/sites-sitedesign-rest/)

## Reports

Success runs

```Powershell
Get-SPOSite -Limit All | ForEach-Object {  
  $failedRuns = Get-SPOSiteDesignRun $_.Url | Get-SPOSiteDesignRunStatus | Where-Object {$_.OutcomeCode -ne "Success"};
 
  if($failedRuns) {
    Write-Output $_.Url
    $failedRuns
  }
}
```

Failed runs

```Powershell
Get-SPOSite -Limit All | ForEach-Object {  
  $failedRuns = Get-SPOSiteDesignRun $_.Url | Get-SPOSiteDesignRunStatus | Where-Object {$_.OutcomeCode -eq "Faulure"};
 
  if($failedRuns) {
    Write-Output $_.Url
    $failedRuns
  }
}
```

## Tips

Know how many Site Designs and Site Scripts you have:

```Powershell
(Get-SPOSiteDesign | Measure).Count
```

```Powershell
(Get-SPOSiteScript | Measure).Count
```

Delete a Site Design or a Site Script based on its unique identifier:

```Powershell
Remove-SPOSiteDesign -Identity $siteDesignId
```

```Powershell
Remove-SPOSiteScript -Identity $siteScriptId

Delete all Site Designs or Site Scripts at once:

```Powershell
Get-SPOSiteDesign | foreach { Remove-SPOSiteDesign -Identity $_.Id }
```

```Powershell
Get-SPOSiteScript | foreach { Remove-SPOSiteScript -Identity $_.Id }
```
