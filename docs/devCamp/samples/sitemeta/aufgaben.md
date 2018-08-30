# Projekt Aufgabe

## Aufgabe

- Anzeige des Site Collection InfoItem in einem SPFx WebPart
- Ein MockProvider und ein SPListProvider ist vorhande als Datenquelle [spfxdevcamp2018starter](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018starter/browse/src/shared/services)
- Eine Shared Komponente zum anzeigen der Daten wäre vorhanden, jedoch kann auch zuerst eine eigene erstellt werden [spfxdevcamp2018starter](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018starter/browse/src/shared/components/MetaCard)
- Anzeige eines "Load..." Screens, wenn die Daten geladen werden

### Vorgehen für UX

- Erstelle das UX in HTML (z.B einfache Tabelle mit Office Fabric Style). Dies wurde dann in eine React Komponente umgebaut zum wiederverwenden [spfxdevcamp2018starter](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018starter/browse/src/shared/components/MetaCard/MetaCard.tsx)

### Vorgehen für ListMock Provider

Schau dir den Code zum erstellen eines ListenMocks an [spfxdevcamp2018starter](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018starter/browse/src/shared/services/ListMock.ts)

Vorgehen

- Erstelle Daten Model, welche die Datentypen definert (InfoItem.ts)
- Erstelle eine Schnittstelle, welche die Zugriffsfunktionen definiert (IListService.ts)
- Erstelle eine MockService (ListMockService.ts) mit Daten, welche die IListService Schnittstelle implementiert
- Erstelle eine public function getFirstItem() der die Mockdaten zurückliefert

### Vorgehen für SPListService Provider

Schau dir den Code zum erstellen eines ListenMocks an [spfxdevcamp2018starter](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018starter/browse/src/shared/services/SpListService.ts)

Vorgehen

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
