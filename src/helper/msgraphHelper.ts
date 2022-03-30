//* Helper wrapper for calling Graph
//* based on https://gist.github.com/wobba/37416d3107b85675d896105554b3df28
//* Thank you Mikael Svenson
//* https://gist.github.com/anoopt/af03de17bcd6230f3bfcc66ff5a05305

import { WebPartContext } from '@microsoft/sp-webpart-base';
import { GraphError } from '@microsoft/microsoft-graph-client';
import { MSGraphClientV3 } from '@microsoft/sp-http';

export class msgraph {
    private static _graphClient: MSGraphClientV3;

    public static async Init(context: WebPartContext) {
        this._graphClient = await context.msGraphClientFactory.getClient('3');
    }

    public static async Call(
        method: "get" | "post" | "patch" | "delete",
        apiUrl: string,
        version: "v1.0" | "beta",
        content?: any,
        selectProperties?: string[],
        expandProperties?: string[],
        filter?: string,
        count?: boolean
    ): Promise<any> {
        var p = new Promise<string>(async (resolve, reject) => {
            let query = this._graphClient.api(apiUrl).version(version);
            typeof(content) === "object" && (content = JSON.stringify(content));
            selectProperties && selectProperties.length > 0 && (query = query.select(selectProperties));
            filter && filter.length > 0 && (query = query.filter(filter));
            expandProperties && expandProperties.length > 0 && (query = query.expand(expandProperties));
            count && (query = query.count(count));
            let callback = (error: GraphError, response: any, rawResponse?: any) => error ? reject(error) : resolve(response);
            //* ES2016
            ["post", "patch"].includes(method) ? await query[method](content, callback) : await query[method](callback);
        });
        return p;
    }
}

/* Example to create an item in a SharePoint list */
/*
  
  // do this in the onInit method
  await msgraph.Init(this.context);
  
  // do this where needed
  const item = await msgraph.Call(
        'post',
        "/sites/yourtenantname.sharepoint.com,b9d5fdc2...2bfdb1e6a59e,8e5b0360...687268f18466/lists/515c5b63...ce64567e3676/items",
        "v1.0",
        {
          "fields": {
            "Title": "Test"
          }
        }
   );
   console.log(item);
*/