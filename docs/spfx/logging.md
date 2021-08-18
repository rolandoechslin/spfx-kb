# Logging

## Logging with sp-core-library

- [Working with the Logging API](https://github.com/SharePoint/sp-dev-docs/wiki/Working-with-the-Logging-API)

Reference the Log class

```tsx
import { Log } from "@microsoft/sp-core-library";
```

Log your message from your WebPart

```tsx
Log.verbose("HelloWorld", "Here is a verbose log", this.context.serviceScope);
Log.info("HelloWorld", "Here is an informational message.", this.context.serviceScope);
Log.warn("HelloWorld", "Oh Oh, this might be bad", this.context.serviceScope);
Log.error("HelloWorld", new Error("Oh No!  Error!  Ahhhhhh!!!!"), this.context.serviceScope);
```

## Logging with pnp-logging

- [Resolve to Log-PnPLogger](https://github.com/juliemturner/Public-Samples/blob/master/PnPLogger)
- [Resolve to Log](https://julieturner.net/2018/12/resolve-to-log/)
- [Working With: Logging](https://github.com/SharePoint/PnP-JS-Core/wiki/Working-With:-Logging)
- [Integrate Logging](https://blog.josequinto.com/2017/04/30/how-to-integrate-pnp-js-core-and-sharepoint-framework-logging-systems/#Integrate-Logging)
- [Flexible and powerful logging using PnP Logging in SPFx](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/flexible-and-powerful-logging-using-pnp-logging-in-spfx/ba-p/2655701)

## Logging with AppInsights

- [Add Azure App Insights or Google Analytics to your SharePoint pages with an SPFx Application Customizer](https://www.sharepointnutsandbolts.com/2017/08/SPFx-App-Insights.html)
- [Use Azure App Insights to track events in your app/web part/provisioning code](https://www.sharepointnutsandbolts.com/2017/09/App-Insights-for-SPFx-and-provisioning.html)
- [Deploy Application Insights globally on modern SharePoint](https://sharepoint.handsontek.net/2019/02/23/deploy-application-insights-globally-on-modern-sharepoint/)
