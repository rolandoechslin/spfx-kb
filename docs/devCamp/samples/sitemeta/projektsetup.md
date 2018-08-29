# Projekt Setup

## Site Collection Provisionierung

- In einer SiteCollection existiert ein definiertes InfoItem.
- Provisionier der Liste und Daten erfolgt über die PnP Engine Powershell

### Install Menu

- Install Menu aufrufen im Deployment Folder (.\install.ps1)
- Ga-Dev selektieren mit "1"
- Der Script verbindet sich automatisch auf deinen Tenant

![Installer Menu](../../../assets/images/connect-tenant.png)

- Wähle Setup Provisioning > List > Add Information List

> Dieser Script installiert nacheinander die ContentTypes, Liste und Listeneintrag

### Test Installation

Ein Information Item muss erstellt sein unter

<https://gw365dev.sharepoint.com/sites/roapp/Lists/Information/AllItems.aspx>

z.B. für meine Dev SiteCollection

## Code Guidelines

siehe [code-guidline](../../code-guidline.md)

## Pnp Librarys

Folgene Librarys wurden beim Projektsetup installiert.

### PnpJs

- <https://pnp.github.io/pnpjs/getting-started.html>
- <https://github.com/SharePoint/PnP-JS-Core/wiki/Developer-Guide>

```bs
pnpm install @pnp/logging @pnp/common @pnp/odata @pnp/sp @pnp/graph --save
```

### Pnp React Controls

- <https://sharepoint.github.io/sp-dev-fx-controls-react/>

```bs
pnpm install @pnp/spfx-controls-react --save --save-exact
```

### Pnp Property Controls

- <https://sharepoint.github.io/sp-dev-fx-property-controls/>

```bs
pnpm install @pnp/spfx-property-controls --save --save-exact
```

### Office Fabric react Controls

- <https://developer.microsoft.com/en-us/fabric#/get-started#react>

```bs
pnpm install office-ui-fabric-react@lts --save
```

Info: [gotcha-when-adding-office-ui-fabric](https://www.techmikael.com/2018/08/gotcha-when-adding-office-ui-fabric.html)

## Reference Librarys

Sample

```tsx
import { sp } from "@pnp/sp";
import { WebPartTitle } from "@pnp/spfx-controls-react/lib/WebPartTitle";
import { PropertyFieldListPicker, PropertyFieldListPickerOrderBy } from '@pnp/spfx-property-controls/lib/PropertyFieldListPicker';
```
