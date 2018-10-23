
# Tips and tricks

## Roadmap

- [Microsoft 365 Roadmap](https://www.microsoft.com/en-us/microsoft-365/roadmap?filters=SharePoint%2CIn%20Development)

## Code Guideline

- [Typescriptlang - Handbook](https://www.typescriptlang.org/docs/handbook/basic-types.html)
- [Airbnb React/JSX Style Guide](https://github.com/airbnb/javascript/blob/master/react/README.md)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Office fabric react - Coding Guidelines](https://github.com/OfficeDev/office-ui-fabric-react/wiki/Coding-Style)
- [Office fabric react - React-Guideline](https://github.com/OfficeDev/office-ui-fabric-react/wiki/React-Guidelines)
- [Office fabric react - TypeScript-Guidelines](https://github.com/OfficeDev/office-ui-fabric-react/wiki/TypeScript-Guidelines)
- [react-typescript-cheatsheet](https://github.com/sw-yx/react-typescript-cheatsheet)

## Content Style Guide

- https://docs.microsoft.com/de-ch/style-guide/welcome/

## SharePoint PNP Community
- [SharePoint PnP resources](https://docs.microsoft.com/en-us/sharepoint/dev/community/community)
- [Sharepoint Glossar](https://docs.microsoft.com/en-us/sharepoint/dev/general-development/sharepoint-glossary)

## Create WebPart

- [Scaffold projects by using Yeoman SharePoint generator](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/scaffolding-projects-using-yeoman-sharepoint-generator)

```bs
yo @microsoft/sharepoint
git init
git add -A
git commit -m "init repo"
```

## Development - local workbench

```bs
gulp serve
```

```html
https://localhost:4321/temp/workbench.html
```

## Development - online workbench

```bs
gulp serve --nobrowser
```

```html
/_layouts/15/workbench.aspx
```


## Prepare Deployment Solution

```bs
gulp clean
gulp build
gulp --ship
gulp package-solution --ship
```

## Manuel Upload Solution Deployment

- Upload the solution file "packagename.sppkg" from "/sharepoint/solution" to the App Catalog.
- Go to either a modern Communication or Team Site.
- Go to "Site contents" and add new "App"
- Select "packagename" and wait for it to be installed
- Go to the front page, edit the page and add the webpart

## Logging with sp-core-library

- <https://github.com/SharePoint/sp-dev-docs/wiki/Working-with-the-Logging-API>

Reference the Log class.

```tsx
import { Log } from '@microsoft/sp-core-library';
```

Log your message from your WebPart

```tsx
Log.verbose("HelloWorld", "Here is a verbose log", this.context.serviceScope);

Log.info("HelloWorld", "Here is an informational message.", this.context.serviceScope);

Log.warn("HelloWorld", "Oh Oh, this might be bad", this.context.serviceScope);

Log.error("HelloWorld", new Error("Oh No!  Error!  Ahhhhhh!!!!"), this.context.serviceScope);
Logging with @pnp/logging
```

## Logging with pnp-logging

- <https://github.com/SharePoint/PnP-JS-Core/wiki/Working-With:-Logging>
https://blog.josequinto.com/2017/04/30/how-to-integrate-pnp-js-core-and-sharepoint-framework-logging-systems/#Integrate-Logging

## Logging with AppInsights

- [Add Azure App Insights or Google Analytics to your SharePoint pages with an SPFx Application Customizer](https://www.sharepointnutsandbolts.com/2017/08/SPFx-App-Insights.html)
- [Use Azure App Insights to track events in your app/web part/provisioning code](https://www.sharepointnutsandbolts.com/2017/09/App-Insights-for-SPFx-and-provisioning.html)

## Debug in browser

```bs
gulp serve
```

- add webpart
- start Chrome
- start Dev Extension (F12)
- open Source, Search for ClassName (Ctrl+P)
- add Breakpoint
- refresh page

## Debug in vs.code

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/debug-in-vscode>

Pre Steps
- open vs.code
- got to view extensions
- install "Debugger for chrome"
- create launch.json
- select configuration
    - Hosted workbench configuration

Steps

```bs
gulp serve --nobrowser
```

- add breakpoint in vs.code ts-file
- go debug view
- press F5
- select configuration
- add wepart to workbench

## Checklist SPFx initial

- <https://joelfmrodrigues.wordpress.com/2018/03/02/sharepoint-framework-checklist/>

### Fix version

- edit version in package.json -> same as in package-solution.json
    - to "version": "1.0.0",

### Add importend pnp modules

- <https://pnp.github.io/pnpjs/getting-started.html>
- <https://github.com/SharePoint/PnP-JS-Core/wiki/Developer-Guide>

```bs
npm install @pnp/logging @pnp/common @pnp/odata @pnp/sp @pnp/graph --save
```

- <https://sharepoint.github.io/sp-dev-fx-controls-react/>

```bs
npm install @pnp/spfx-controls-react --save --save-exact
```

- <https://sharepoint.github.io/sp-dev-fx-property-controls/>

```bs
npm install @pnp/spfx-property-controls --save --save-exact
```

## Localizations

- Location files are in JSON format
- They work similar as Resources files (XML) on VS Solution
- The default language is English (en-us)
- Developers can test the locale by:
    - Updating write-manifests.json file

```json
{
    "cdnBasePath": "<!-- PATH TO CDN -->",
    "debugLocale": "de-de"
}
```

Or by using the "locale" command argument

```bs
gulp serve --locale=de-de
```


## Data Service

Very good overview from sebastien levert: [APIs Everywhere](./assets/APIs-Everywhere.pptx)

Sample Folder structur

- src
    - models
        - IHelpDeskItem.ts
    - services
        - IDataService.ts
        - MockDataservice.ts
        - SharepointDataService.ts
    - webparts
        - components
        - loc
        - 'webpartnameWebPart.ts'


### Data Model

Interface to define our Data structure

```tsx
export interface IHelpDeskItem {
  id?: number;
  title?: string;
  description?: string;
  level?: string;
  status?: string;
  assignedTo?: string;
  resolution?: string;
}
```

Interface to define our Data Access services

```tsx
import { IHelpDeskItem } from "./../models/IHelpDeskItem";
import { WebPartContext } from "@microsoft/sp-webpart-base";

export default interface IDataService {
  getTitle(): string;
  isConfigured(): boolean;
  getItems(context: WebPartContext): Promise<IHelpDeskItem[]>;
  addItem(item: IHelpDeskItem): Promise<void>;
  deleteItem(id: number): Promise<void>;
}

```

Mocking Service for testing in local Workbench development

```tsx
import { IHelpDeskItem } from "./../models/IHelpDeskItem";
import IDataService from "./IDataService";
import { IWebPartContext } from "@microsoft/sp-webpart-base";

export default class MockDataService implements IDataService {
...
  private _webPartContext: IWebPartContext;
  private _listId: string;

  constructor(webPartContext: IWebPartContext, listId: string) {
    this._webPartContext = webPartContext;
    this._listId = listId;
  }
...

  public getItems(context: IWebPartContext): Promise<IHelpDeskItem[]> {
    return new Promise<IHelpDeskItem[]>((resolve, reject) => {
      setTimeout(() => resolve([
        {
          id : 1,
          title : "That doesn't work",
          description : "When I do that, it doesn't work",
          level : "Low",
          status: "Open",
          resolution: "Do this and it will work!",
          assignedTo: "Sébastien Levert",
        }
      ]), 300);
    });
  }
}
```

### Get Data with Sharepoint REST

[Source](https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/services/SharePointDataService.ts)

```tsx
public getItems(context: WebPartContext): Promise<IHelpDeskItem[]> {
return new Promise<IHelpDeskItem[]>((resolve, reject) => {
    context.spHttpClient
    .get( `${this._webPartContext.pageContext.web.absoluteUrl}/_api/web/lists/GetById('${this._listId}')/items` +
            `?$select=*,HelpDeskAssignedTo/Title&$expand=HelpDeskAssignedTo`, SPHttpClient.configurations.v1)
    .then(res => res.json())
    .then(res => {
        let helpDeskItems:IHelpDeskItem[] = [];

        for(let helpDeskListItem of res.value) {
        helpDeskItems.push(this.buildHelpDeskItem(helpDeskListItem));
        }

        resolve(helpDeskItems);
    })
    .catch(err => console.log(err));
});
}
```

### Get Data with Pnp-JS-Core

Advantages

- Type safe so you get your errors while you code and not when you execute and test
- Works on all versions of SharePoint (On-Premises, Online, etc.)
- Offers built-in caching mechanisms
- Heavily used in the SharePoint Development Community

Init context in react webpart component
[source](https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/webparts/listContent/ListContentWebPart.ts)

```tsx
public onInit(): Promise<void> {
    return super.onInit().then(_ => {
        pnpSetup({
        spfxContext: this.context
        });
    });
}
```

init service in react webpart component

```tsx
public render(): void {
    const element: React.ReactElement<IListContentProps> = React.createElement(
      ListContent,
      {
        context: this.context,
        dataService: this.getDataService(),
        list: this.properties.list
      }
    );

    ReactDom.render(element, this.domElement);
}
```

Get items from list
[Source](https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/services/PnPJSCoreDataService.ts)

```tsx
public getItems(context: WebPartContext): Promise<IHelpDeskItem[]> {
return new Promise<IHelpDeskItem[]>((resolve, reject) => {

    sp.web.lists.getById(this._listId).items
    .select("*", "HelpDeskAssignedTo/Title")
    .expand("HelpDeskAssignedTo").getAll().then((sessionItems: any[]) => {
    let helpDeskItems:IHelpDeskItem[] = [];

    for(let helpDeskListItem of sessionItems) {
        helpDeskItems.push(this.buildHelpDeskItem(helpDeskListItem));
    }

    resolve(helpDeskItems);
    });

});
}
```

### Get Data from MSGraph

- [Using PnPjs to send requests to MS Graph with SharePoint Framework 1.6](http://spblog.net/post/2018/09/09/Using-PnPjs-to-send-requests-to-MS-Graph-with-SharePoint-Framework-16)
- [Example of wrapper to ease usage of Graph calls in SPFx](https://www.techmikael.com/2018/09/example-of-wrapper-to-ease-usage-of.html)
- [msgraph-helper](https://github.com/olemp/msgraph-helper)

### Start Office Fabric React

Create Sample

- https://github.com/Microsoft/TypeScript-React-Starter
- https://github.com/OfficeDev/office-ui-fabric-react/wiki/Sample-App

```bs
create-react-app demo-office-fabric-react-ts --scripts-version=react-scripts-ts
```

init git

```bs
git init
git add .
git commit -m "Initial commit."
```

add office fabric react

```bs
yarn add office-ui-fabric-react --save
```

## Create SP-App

- <https://github.com/koltyakov/generator-sppp>

## SPFx Version Upgrade

- <https://github.com/pnp/office365-cli>
- <https://blog.mastykarz.nl/upgrade-sharepoint-framework-project-office-365-cli>

Office 365 CLI (next) installieren
```bs
npm i -g @pnp/office365-cli@next
```

Report erstellen
```bs
o365 spfx project upgrade --output md > report.md
```

Code update

- [update-latest-packages](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/update-latest-packages)

## Custom yo spfx generator

- <https://pnp.github.io/generator-spfx/#installation>