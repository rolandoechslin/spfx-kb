# Wichtiges
* In SPFx 1.5.1 ist ein neuer Graph-Client nutzbar, der auf PROD-Tenants noch nicht nutzbar ist
* Am Besten verwendet man bis der Graph-Client aus 1.5.1 live ist den graphHttpClient und die SPFx-Version 1.4.1

# Bespiele

## Alle SharePoint Sites, wo ich dazugehört mit Site Logo
Wir holen alle Gruppen.
```javascript
// query for all groups on the tenant using Microsoft Graph.
return this.context.graphHttpClient
    .get(`v1.0/me/memberOf`, GraphHttpClient.configurations.v1)
    .then((response: HttpClientResponse) => {
    if (response.ok) {
        return response.json();
    } else {
        console.warn(response.statusText);
    }
    }).then((result: any) => {
    // transfer result values to the group variable
    let groups: IOffice365Group[];
    groups = result.value;
    console.log("received groups: " + JSON.stringify(groups));
    return groups;
    });
```

Wir filtern noch nach "unified" Groups.
```javascript
public getAllUnifiedGroups(): Promise<Array<IOffice365Group>> {
return this.getAll().then((groups: IOffice365Group[]) => {
    return groups.filter((group: IOffice365Group) => {
    if (group.groupTypes && group.groupTypes.indexOf("Unified") > -1) {
        return true;
    }
    });
});
}
```

In den Gruppen ist dann gespeichert, welche dazugehörende SharePoint Site URL ist.
```javascript
public getGroupSiteUrl(id: string): Promise<string> {
// query for all groups on the tenant using Microsoft Graph.
return this.context.graphHttpClient
    .get(`v1.0/groups/${id}/sites/root?$select=webUrl`, GraphHttpClient.configurations.v1)
    .then((response: HttpClientResponse) => {
    if (response.ok) {
        return response.json();
    } else {
        console.warn(response.statusText);
    }
    });
}
```

Das Bild können wir uns auch noch holen.
```javascript
public getGroupPictureUrlWithGraph(id: string): Promise<any> {
return this.context.graphHttpClient
    .get(`v1.0/groups/${id}/photos/48x48/$value`, GraphHttpClient.configurations.v1)
    .then((response: HttpClientResponse) => {
    if (response.ok) {
        return response.blob();
    } else {
        console.warn(response.statusText);
    }
    });
}
```

