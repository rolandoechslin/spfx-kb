# REST

## Reference

- [How the SharePoint REST service works](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service)
- [Determine SharePoint REST service endpoint URIs](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/determine-sharepoint-rest-service-endpoint-uris)
- [Use OData query operations in SharePoint REST requests](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests)
- [SharePoint & Office 365 REST API Resources](https://github.com/andrewconnell/sp-o365-rest)

## Tools

- [postman-and-office-365](https://www.helloitsliam.com/2016/02/04/postman-and-office-365)
- [SharePoint REST API Metadata Explorer](https://s-kainet.github.io/sp-rest-explorer)
- [Announcing Microsoft Graph Postman Collections](https://developer.microsoft.com/en-us/sharepoint/blogs/postman-collections/)

## Testing

Testing in chrome console

```ts
fetch(`/sites/gridworks/_api/web/lists/getbytitle('SiteRequestsQueue')/items?$select=Id,Title,gwRequestSiteAlias&$orderby=Id desc`, {
    headers: {
        Accept: 'application/json;odata=verbose;'
    }
}).then(res => res.json().then(json => {
    json.d.results.forEach(item => {
        console.log(`item: ${item.Title}`);
    });
}));
```
