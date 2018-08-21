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

## Install Pnp Librarys

### Pnp Js Core

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

Zusatz 1: 
Anzeige des Owner in einm Office 365 Persona Format https://developer.microsoft.com/en-us/fabric#/components/persona

Zusatz 2:
Anzeige des Persona Format konfigurierbar über ein Checkbox WebPart Properties (ShowPersona)