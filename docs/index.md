
# Tips and tricks

## Create WebPart

```bs
yo @microsoft/sharepoint
git init
git add -A
git commit -m "init repo"
```

## Development - local workbench

```bs
gulp serve

https://localhost:4321/temp/workbench.html
```

## Development - online workbench

```bs
gulp serve --nobrowser

{spo site}/_layouts/15/workbench.aspx
```

## Logging with sp-core-library

- <https://github.com/SharePoint/sp-dev-docs/wiki/Working-with-the-Logging-API>

Reference the Log class.

```ts
import { Log } from '@microsoft/sp-core-library';
```

Log your message from your WebPart

```ts
Log.verbose("HelloWorld", "Here is a verbose log", this.context.serviceScope);

Log.info("HelloWorld", "Here is an informational message.", this.context.serviceScope);

Log.warn("HelloWorld", "Oh Oh, this might be bad", this.context.serviceScope);

Log.error("HelloWorld", new Error("Oh No!  Error!  Ahhhhhh!!!!"), this.context.serviceScope);
Logging with @pnp/logging
```

## Custom logging (pnp-logging)

- <https://github.com/SharePoint/PnP-JS-Core/wiki/Working-With:-Logging>
https://blog.josequinto.com/2017/04/30/how-to-integrate-pnp-js-core-and-sharepoint-framework-logging-systems/#Integrate-Logging

## Debug in browser

```bs
gulp serve
```
* add webpart
* start Chrome
* start Dev Extension (F12)
* open Source, Search for ClassName (Ctrl+P)
* add Breakpoint
* refresh page

## Debug in vs.code

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/debug-in-vscode>

Pre Steps
* open vs.code / view extensions
* install "Debugger for chrome"
* create launch.json
* select configuration
    * Hosted workbench configuration

Steps
```bs
gulp serve --nobrowser
```

* add breakpoint in vs.code ts-file
* go debug view
* press F5
* select configuration
* add wepart to workbench

## Checklist SPFx initial

- <https://joelfmrodrigues.wordpress.com/2018/03/02/sharepoint-framework-checklist/>

### Fix version

* edit version in package.json -> same as in package-solution.json

    * to "version": "1.0.0",

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

## Data Service

Very good overview from sebastien levert: [APIs Everywhere](./assets/APIs-Everywhere.pptx)

### Get Data with Sharepoint REST

Source
- <https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/services/SharePointDataService.ts>

```ts
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
* Type safe so you get your errors while you code and not when you execute and test
* Works on all versions of SharePoint (On-Premises, Online, etc.)
* Offers built-in caching mechanisms
* Heavily used in the SharePoint Development Community

Source
- https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/webparts/listContent/ListContentWebPart.ts

Init context in react webpart component

```ts
public onInit(): Promise<void> {
    return super.onInit().then(_ => {
        pnpSetup({
        spfxContext: this.context
        });
    });
}
```

init service in react webpart component

```ts
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

Source
- <https://github.com/sebastienlevert/apis-apis-everywhere/blob/master/src/services/PnPJSCoreDataService.ts>

```ts
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
