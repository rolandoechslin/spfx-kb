# Business-Objects

## Async

- <https://blog.josequinto.com/2017/05/19/why-do-we-should-use-custom-business-objects-models-in-pnp-js-core/>
- <https://github.com/jquintozamora/spfx-react-sp-pnp-js-property-decorators>
- <https://sharepoint.stackexchange.com/questions/221325/how-to-enable-async-wait-in-spfx-typescript-tslint-missing-semicolon-ts1005>

```ts
private async loadScripts(): Promise<void> { 
    return new Promise<void>(async (resolve) => {
        if(this._context) {
            resolve();
        }

        const response =  this.loadScript(layoutsUrl + 'init.js', 'Sod');
        resolve();
    });
  }
  ```

Load Data from SP-List [Code](https://github.com/SharePoint/sp-dev-fx-webparts/blob/master/samples/react-webhooks-realtime/src/webparts/realTimeList/components/RealTimeList.tsx)

```ts
private async _loadList(): Promise<void> {
    this.setState({
        loading: true
    });
    let items = await pnp.sp.web.lists.getByTitle("Events").items.select("Id", "Title", "SPFxDescription", "SPFxThumbnail")
        .orderBy("Modified", false).get();
    _items = items.map((item: IList, index: number) => {
        return {
        thumbnail: item.SPFxThumbnail != null ? item.SPFxThumbnail.Url : "",
        key: item.Id,
        name: item.Title,
        description: item.SPFxDescription
        }
    });
    this.setState({
        sortedItems: _items,
        columns: _buildColumns(),
        loading: false,
        newsFeedVisible: false
    });
    _lastQueryDate = moment();
}
 ```
 