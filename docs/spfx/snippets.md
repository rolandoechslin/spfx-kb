# Code Snippets

## QueryString

- [How to get a querystring value](http://www.dotnetmafia.com/blogs/dotnettipoftheday/archive/2018/09/11/spfx-basics-how-to-get-a-query-string-value.aspx)

```ts
import { UrlQueryParameterCollection } from '@microsoft/sp-core-library';

if (queryParameters.getValue('id')) {
    id = parseInt(queryParameters.getValue('id'));
}
```

## PNP JS-Core

### List Permission

```ts
private _checkProductsPermissions(productsList){
    return pnp.sp.web.lists.getByTitle(productsList).getCurrentUserEffectivePermissions()
        .then(perms => {
            let canEdit = pnp.sp.web.lists.getByTitle(productsList).hasPermissions(perms, PermissionKind.EditListItems);
            let canView = pnp.sp.web.lists.getByTitle(productsList).hasPermissions(perms, PermissionKind.ViewListItems);
            if(canEdit){
                return 'Edit';
            } else if(canView){
                return 'View';
            } else {
                return 'None';
            }
        })
        .catch((err) => {
            console.log('error:', err);
            return 'None';
        });
}
```

### Admin User

```ts
// Ensure a user on site collection
sp.web.ensureUser('john.doe@contoso.onmicrosoft.com').then(console.log);

// Get site collection admins
sp.web.siteUsers.filter(`IsSiteAdmin eq true`)
    .get().then(console.log);

// Remove a user from site collection admins
sp.web.siteUsers.getByLoginName('i:0#.f|membership|john.doe@contoso.onmicrosoft.com')
    .update({ IsSiteAdmin: false }).then(console.log);

// Add a user to site collection admins
sp.web.siteUsers.getByLoginName('i:0#.f|membership|john.doe@contoso.onmicrosoft.com')
    .update({ IsSiteAdmin: true }).then(console.log);
```

### All news pages

- <https://blog.hubfly.com/sharepoint/how-to-read-the-sharepoint-news-using-rest-api-in-spfx>

```ts
/_api/search/query?querytext='IsDocument:True AND FileExtension:aspx AND PromotedState:2'
```
