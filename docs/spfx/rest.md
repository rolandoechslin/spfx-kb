# REST

## Reference

- [How the SharePoint REST service works](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service)
- [Determine SharePoint REST service endpoint URIs](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/determine-sharepoint-rest-service-endpoint-uris)
- [Use OData query operations in SharePoint REST requests](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests)
- [SharePoint & Office 365 REST API Resources](https://github.com/andrewconnell/sp-o365-rest)
- [Using REST API For Selecting, Filtering, Sorting And Pagination in SharePoint List](https://social.technet.microsoft.com/wiki/contents/articles/35796.sharepoint-2013-using-rest-api-for-selecting-filtering-sorting-and-pagination-in-sharepoint-list.aspx)

## Tools

- [postman-and-office-365](https://www.helloitsliam.com/2016/02/04/postman-and-office-365)
- [SharePoint REST API Metadata Explorer](https://s-kainet.github.io/sp-rest-explorer)
- [Announcing Microsoft Graph Postman Collections](https://developer.microsoft.com/en-us/sharepoint/blogs/postman-collections/)
- [Using Postman with the Microsoft Graph](https://www.youtube.com/watch?v=7Sx2pFY21YQ)
- [Powerful HTTP and GraphQL tool belt](https://insomnia.rest/)
- [Explore SharePoint REST API with Chrome F12 cURL (bash) to Postman](https://www.spjeff.com/2020/06/16/explore-sharepoint-rest-api-with-chrome-f12-curl-bash-to-postman/)

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
