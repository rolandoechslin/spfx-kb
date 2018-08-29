# SPFx Konzepte anhand eines Beispiels

Aufzeigen von diversen Spfx WebPart Konzepten und ihre Umsetzungen im Code.

## Mockdaten

Anzeige von Mockdaten wenn der local server gestartet wird.

![Mockdata](../assets/images/mock-data.png)

[Code Switch Enviroment](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/webparts/siteMetaCard/SiteMetaCardWebPart.ts#35)

[Code Service](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/shared/services/ListMock.ts#523)

## Load data icon

Anzeige eines "Load data..." Icons, wenn der Datenzugriff erfolgt, sobald diese geladen sind, sollen die Daten angezeigt werden.

![Load data](../assets/images/load-data.png)

[Code](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/webparts/siteMetaCard/components/SiteMetaCard.tsx#80)

## Lokalisierung des WebParts

Umschalten der Sprache.

![Lokalisierung](../assets/images/localizsation.png)

```bs
gulp serve --locale=de-de
```

[Code](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/shared/components/MetaCard/loc)

## Inline editieren des Titels

Der Titel des Webparts kann editiert werden ohne die WebPart Properties zu öffnen.

![Inline Edit](../assets/images/inline-edit-title.png)

[Code](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/webparts/siteMetaCard/components/SiteMetaCard.tsx#135)

## WebPart Konfiguration

Anzeige von WebPart Properties, wie die Darstellung veränder werden kann zur Laufzeit.

![Konfiguration](../assets/images/webpart-configuration-1.png)

![Konfiguration](../assets/images/webpart-configuration-2.png)

[Code](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/webparts/siteMetaCard/SiteMetaCardWebPart.ts#66)

## Laden von Sharepoint List Daten

Anzeige eines Listitems aus einer Liste mithilfe der Library https://github.com/pnp/pnpjs. Bei komplexen Lookup oder Taxonomie Felder liefert die Funktion renderListDataAsStream() alle Daten zurück.

![SP-List-Provider](../assets/images/splist-data.png)

```bs
gulp serve --nobrowser --locale=de-de
```

[Code](https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018/browse/src/shared/services/SpListService.ts#27)
