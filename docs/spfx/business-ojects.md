# Async

- <https://blog.josequinto.com/2017/05/19/why-do-we-should-use-custom-business-objects-models-in-pnp-js-core/>
- <https://github.com/jquintozamora/spfx-react-sp-pnp-js-property-decorators>
- <https://sharepoint.stackexchange.com/questions/221325/how-to-enable-async-wait-in-spfx-typescript-tslint-missing-semicolon-ts1005>
```ts
private async loadScripts(): Promise<void> { 
    return new Promise<void>(async (resolve) => {
        if(this._context) {
            resolve();
        }

        const response = await this.loadScript(layoutsUrl + 'init.js', 'Sod');
        resolve();
    });
  }
  ```