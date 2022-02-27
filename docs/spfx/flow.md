# Power Automate (aka. Flow)

## Support

- [Troubleshooting a flow](https://docs.microsoft.com/en-us/power-automate/fix-flow-failures)
- [Microsoft Power Automate Community](https://powerusers.microsoft.com/t5/Microsoft-Power-Automate/ct-p/MPACommunity)

## Video

- [Microsoft Flow Conference](https://www.youtube.com/playlist?list=PLwh1E-0OEEGI7sGTXzoy98RFFqsIoUAUw)

## Connectors

- [What you should know about building Microsoft Flow connectors](https://blog.mastykarz.nl/what-know-building-microsoft-flow-custom-connectors)
- [Working with Custom Connectors in Power Platform for beginners](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/working-with-custom-connectors-in-power-platform-for-beginners/ba-p/3062538)

## Limits

- [Limits and configuration in Power Automate](https://docs.microsoft.com/en-us/power-automate/limits-and-config)
- [Power Automate and Flow Connector limits](https://veenstra.me.uk/2018/07/17/microsoft-flow-connector-limits)
- [Microsoft Flow – The hidden gems, are you aware of all of these](https://veenstra.me.uk/2018/03/19/microsoft-flow-the-hidden-gems-are-you-aware-of-all-of-these)
- [Microsoft Flow – This is the limit!](https://sharepains.com/2018/04/30/microsoft-flow-this-is-the-limit/)

## Admin Security

- [Management of Flows](https://rencore.com/blog/inconvenient-management-flows/)
- [Power Automate Security](https://helloitsliam.com/2022/01/19/power-automate-security/)

## Export / Import Flows

- [Export and import your flows across environments with packaging](https://flow.microsoft.com/en-us/blog/import-export-bap-packages/)
- [Flow & Power Apps Migrator](https://github.com/Zerg00s/FlowPowerAppsMigrator)

## Samples

- [Power Automate Cookbook](https://powerusers.microsoft.com/t5/Power-Automate-Cookbook/bd-p/MPA_Cookbook)
- <https://github.com/johnnliu/flow>
- [Demo - Using Microsoft Flow to send monthly emails](https://youtu.be/NsJJYIaRbfw?t=513)
- <http://johnliu.net/blog/2018/4/run-any-pnp-powershell-in-one-azurefunction-from-microsoft-flow>
- [Calling Microsoft Flow from a site script](https://docs.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-trigger-flow-tutorial)
- [Automating New User Account On-boarding Using SharePoint Online, Flow, and PowerApps](https://practical365.com/sharepoint-online/automated-user-creation-flow-powerapps)
- [control office365 group creation](https://www.sharepointnutsandbolts.com/2018/04/control-office-365-group-creation.html)
- [Building interactive feedback analysis system with MS Forms, MS Flow, Power BI and SharePoint Online](https://spblog.net/post/2019/01/29/building-interactive-feedback-analysis-system-with-ms-forms-ms-flow-power-bi-and-sharepoint-online)
- [RUN A FLOW AS PART OF A SHAREPOINT SITE DESIGN](https://wonderlaura.com/2019/03/14/run-a-flow-as-part-of-a-sharepoint-site-design/)
- [Creating a Formatted Identifier in Flow](https://mikehatheway.com/2019/05/03/creating-a-formatted-identifier-in-flow/)
- [Disable event firing when flow updates](https://www.techmikael.com/2019/04/disable-event-firing-when-flow-updates.html)
- [How to add text to any part of a SharePoint Page using Power Automate](https://collab365.community/how-to-add-text-to-any-part-of-a-sharepoint-page-using-power-automate/ )
- [Send email reminders from Microsoft Lists using Power Automate](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/send-email-reminders-from-microsoft-lists-using-power-automate/ba-p/2136723)

## Copy / Move Documents

- [A modern “transfer to another location” in office 365](https://joannecklein.com/2018/01/02/a-modern-transfer-to-another-location-in-office-365/)
- [Generate Word documents from a template using Power Automate](https://tahoeninjas.blog/2020/03/13/generate-word-documents-from-a-template-using-power-automate/)

## Error Messages

- [SharePoint / Microsoft Flow – Common error message when using Send an HTTP request to SharePoint action in Microsoft Flow](https://veenstra.me.uk/2018/08/30/sharepoint-microsoft-flow-common-error-message-when-using-send-an-http-request-to-sharepoint-action-in-microsoft-flow)

## Handling JSON in Flow

- [Handling JSON in Microsoft Flow](https://spmaestro.com/handling-json-in-microsoft-flow/)

## Disable Flow

- <https://www.toddklindt.com/PoshDisableFlowButton>

```Powershell
Connect-PnPOnline -Url https://<teantUrl>/sites/<name>

# disable
Set-PnPSite -DisableFlows:$true

# enable
Set-PnPSite -DisableFlows:$false
```

## Azure Logic App

- [Azure Logic Apps vs Microsoft Flow, Why Not Both?](https://www.serverless360.com/blog/azure-logic-apps-vs-microsoft-flow)
- [Integrate Azure Logic Apps with SharePoint Site Designs](http://www.devjhorst.com/2019/10/integrate-azure-logic-apps-with-sharepoint-site-designs.html)
