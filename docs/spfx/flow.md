# Flow

## Connectors

- <https://blog.mastykarz.nl/what-know-building-microsoft-flow-custom-connectors>

## Limits

- <https://docs.microsoft.com/en-us/flow/limits-and-config>
- <https://veenstra.me.uk/2018/07/17/microsoft-flow-connector-limits>
- <https://veenstra.me.uk/2018/03/19/microsoft-flow-the-hidden-gems-are-you-aware-of-all-of-these>

## Samples
- <https://github.com/johnnliu/flow>
- [Demo - Using Microsoft Flow to send monthly emails](https://youtu.be/NsJJYIaRbfw?t=513)
- <http://johnliu.net/blog/2018/4/run-any-pnp-powershell-in-one-azurefunction-from-microsoft-flow>
- [Calling Microsoft Flow from a site script](https://docs.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-trigger-flow-tutorial)
- [Automating New User Account On-boarding Using SharePoint Online, Flow, and PowerApps](https://practical365.com/sharepoint-online/automated-user-creation-flow-powerapps)
- [control office365 group creation](https://www.sharepointnutsandbolts.com/2018/04/control-office-365-group-creation.html)

## Error Messages

- [SharePoint / Microsoft Flow – Common error message when using Send an HTTP request to SharePoint action in Microsoft Flow](https://veenstra.me.uk/2018/08/30/sharepoint-microsoft-flow-common-error-message-when-using-send-an-http-request-to-sharepoint-action-in-microsoft-flow)

## Disable Flow

- <https://www.toddklindt.com/PoshDisableFlowButton>

```Powershell
Connect-PnPOnline -Url https://<teantUrl>/sites/<name>

# disable
Set-PnPSite -DisableFlows:$true

# enable
Set-PnPSite -DisableFlows:$false
```
