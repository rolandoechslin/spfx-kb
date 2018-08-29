# Site Meta Card Beispiel

## Vorbedinungen

### Site Collection Provisionierung

- In einer SiteCollection existiert ein definiertes InfoItem.
- Provisionier der Liste und Daten erfolgt über die PnP Engine Powershell

### Install Menu

- Install Menu aufrufen im Deployment Folder (.\install.ps1)
- Ga-Dev selektieren mit "1"
- Der Script verbindet sich automatisch auf deinen Tenant 
    - siehe [Installer Menu](../../assets/connect-tenant.png)
- Wähle Setup Provisioning > List > Add Information List

> Dieser Script installiert nacheinander die ContentTypes, Liste und Listeneintrag

### Test Installation

Ein Information Item muss erstellt sein unter

<https://gw365dev.sharepoint.com/sites/roapp/Lists/Information/AllItems.aspx>

z.B. für meine Dev SiteCollection

## Code Guidelines

- [Typescriptlang - Handbook](https://www.typescriptlang.org/docs/handbook/basic-types.html)
- [Airbnb React/JSX Style Guide](https://github.com/airbnb/javascript/blob/master/react/README.md)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Office fabric react - Coding Guidelines](https://github.com/OfficeDev/office-ui-fabric-react/wiki/Coding-Style)
- [Office fabric react - React-Guideline](https://github.com/OfficeDev/office-ui-fabric-react/wiki/React-Guidelines)
- [Office fabric react - TypeScript-Guidelines](https://github.com/OfficeDev/office-ui-fabric-react/wiki/TypeScript-Guidelines)

## Erstelle Projekt

Gehe in deine Projekt Folder und erstelle einen Folder

```bs
mkdir SpfxDevCamp2018
cd SpfxDevCamp2018
```

Mit pnpm-Package Manger <https://pnpm.js.org>

```bs
yo @microsoft/sharepoint --package-manager pnpm
```

## Yoman Optionen

- Solution Name: default
- Baseline Package: SharePoint Online only
- Target Location: Use the current folder
- Tenant Admin: Yes [tenant-scoped-deployment](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/tenant-scoped-deployment)
- Project Type: WebPart
- WebPart Name: SiteMetaCard
- WebPart Description: Display the site information from Information Item.
- Framework: React

## Build der Sourcen

```bs
gulp build
```

Es dürfen keine Build Errors vorkommen

## Trust Certification

Beim erstmaligen austesten der Workbench muss ein Zertifikat registriert werden.

[trust cert](../../assets/gulp-trust-cert.png)

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

## Add usefull Pnp Librarys

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

## Aufgabe

- Anzeige des Site Collection InfoItem in einem SPFx WebPart
- Erstelle zuerst einen MockProvider als Datenquelle
- Danach sollen die Daten aus einer Liste "Information" stammen
- Anzeige eines "Load..." Screens, wenn die Daten geladen werden

### Aufbau src Folder

Alle Webparts

```bs
/src/webparts
```

Helper Klassen

```bs
/src/common
```

Gemeinsame Componenten (die unterschiedlich eingesetzt werden könnne)

```bs
/src/shared/components
```

Gemeinsame Datenzugriff Provider (ListMockService, SpListService, SpSearchService usw.)

```bs
/src/shared/services
```

### Vorgehen für UX

- Erstelle das UX in HTML (z.B einfache Tabelle mit Office Fabric Style)

### Vorgehen für ListMock Provider

- Erstelle Daten Model, welche die Datentypen definert (InfoItem.ts)
- Erstelle eine Schnittstelle, welche die Zugriffsfunktionen definiert (IListService.ts)
- Erstelle eine MockService (ListMockService.ts) mit Daten, welche die IListService Schnittstelle implementiert
- Erstelle eine public function getFirstItem() der die Mockdaten zurückliefert

### Vorgehen für SPListService Provider

- Erstelle eine Schnitstelle (SpListService.ts), welche die IListService Schnittstelle implementiert
- Erstelle eine public function getFirstItem() der die SP Listdaten zurückliefert. Verwende dazu [pnpjs](https://pnp.github.io/pnpjs/getting-started.html)

### Zusatz Aufgabe 1

- Verwende das [PnP SPFx React Control WebPartTitle](https://sharepoint.github.io/sp-dev-fx-controls-react/controls/WebPartTitle) zur Anzeige eines editierbaren Titels

### Zusatz Aufgabe 2

- Lokalisierung aller statischen Text/Labels [Localize SharePoint Framework client-side web parts](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/web-parts/guidance/localize-web-parts)

### Zusatz Aufgabe 3

- Studium [Integration Office Fabric React Controls](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/office-ui-fabric-integration)

### Zusatz Aufgabe 4

- Anzeige des Owner in einm Office 365 Persona Format. Verwende dazu das [Office Fabric React Control](https://developer.microsoft.com/en-us/fabric#/components/persona)

### Zusatz Aufgabe 5

- Anzeige des Persona Format konfigurierbar über ein Checkbox WebPart Properties (ShowPersona)
