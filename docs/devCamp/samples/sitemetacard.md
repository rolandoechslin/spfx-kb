# Site Meta Card Beispiel

## Vorbedinungen
In einer SiteCollection existiert ein definiertes InfoItem.

TODO: Provisionierund der Liste und ein Item über PS-Script

## Erstelle Projekt

```bs
mkdir SpfxDevCamp2018
cd SpfxDevCamp2018
yo @microsoft/sharepoint
```

## Yoman Optionen

- Solution Name: default
- Baseline Package: SharePoint Online only
- Target Location: Use the current folder
- Tenant Admin: No
- Project Type: WebPart
- Project Name: SiteMetaCard
- Project Description: Display the site information from Information Item.
- Framework: React

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
{spo site}/_layouts/15/workbench.aspx
```


## Install Pnp Librarys

### PnpJs

- <https://pnp.github.io/pnpjs/getting-started.html>
- <https://github.com/SharePoint/PnP-JS-Core/wiki/Developer-Guide>

```bs
npm install @pnp/logging @pnp/common @pnp/odata @pnp/sp @pnp/graph --save
```

### Pnp React Controls

- <https://sharepoint.github.io/sp-dev-fx-controls-react/>

```bs
npm install @pnp/spfx-controls-react --save --save-exact
```

### Pnp Property Controls

- <https://sharepoint.github.io/sp-dev-fx-property-controls/>

```bs
npm install @pnp/spfx-property-controls --save --save-exact
```

## Reference Librarys

```tsx
Import...
```

## Funktion
Darstellen der Meta SiteCollection Informationen (gespeichert in einem Listitem) in einem SPFx Webpart. Anzeige eines Load... Screens, wenn die Daten geladen werden.

## File Struktur im src Folder

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

Gemeinsame Datenzugriff Provider (ListMockService, SPListService, SPSearchService usw.)

```bs
/src/shared/services
```

### Vorgehen für ListMock Provider

- Erstelle das UX in HTML (z.B einfache Tabelle mit Office Fabric Style)
- Erstelle Daten Model, welche die Datentypen definert (InfoItem.ts)
- Erstelle eine Schnittstelle, welche die Zugriffsfunktionen definiert in IListService.ts
- Erstelle eine ListMockService (mit Daten), welche die IListService.ts Schnittstelle implementiert
- Erstelle eine public Function getFirstItem() der die Mockdaten zurückliefert

### Vorgehen für SPListService Provider

- Erstelle eine SpListService.ts, welche die IListService.ts Schnittstelle implementiert
- Erstelle eine public Function getFirstItem() der die SP Listdaten zurückliefert. Verwende dazu pnpjs https://pnp.github.io/pnpjs/getting-started.html

### Zusatz Aufgabe 1

Anzeige des Owner in einm Office 365 Persona Format https://developer.microsoft.com/en-us/fabric#/components/persona

### Zusatz Aufgabe 2

Anzeige des Persona Format konfigurierbar über ein Checkbox WebPart Properties (ShowPersona)