# First Session

Wir zeigen euch, wie ihr euer yo generiertes SPFx Web Part zu einem Web Part erweitern könnte, das folgendes kann:

- Herausfinden, ob ihr lokal oder in SPO entwickelt
- Basierend darauf, kann der Fake oder Real Data Provider genutzt werden
- Mit PNP im Real Data Provider ein List Item auslesen
- Das List Item mit einer Office UI Fabric Komponente darstellen

## Requirements

- Beispiel-Lösung hier abgelegt
  - https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018

## Wo bin ich überhaupt?

```ts
if (Environment.type === EnvironmentType.ClassicSharePoint) {
      // do some stuff on classic page
    } else if (Environment.type === EnvironmentType.SharePoint) {
      // do some stuff on modern page
      this._dataProvider = new MySiteDataProvider(this.context);
    } else if (Environment.type === EnvironmentType.Local) {
      // do some stuff on SharePoint workbench page
      this._dataProvider = new MySiteDataFakeProvider();
    }
}
```

## UI Fabric Komponente verwenden

```ts
import { WebPartTitle } from "@pnp/spfx-controls-react/lib/WebPartTitle";

public render(): React.ReactElement<ISiteOverviewProps> {
    ...
    return (
        ...
        <WebPartTitle displayMode={this.props.displayMode} title={this.props.title} updateProperty={this.props.fUpdateProperty} />
        ...
    );
    ...
}
```

## Renaming Web Part

### Vorbedinung

Einfaches Webpart Solution erstellen

```bs
yo @microsoft/sharepoint --package-manager pnpm
```

Git initialisieren damit changes geprüft werden können

```bs
git init
```

```bs
git add -A
```

```bs
git commit -m "init repo"
```
### Aufgabe

- Replace des erstellten "WebPartName" und Rename aller Folder und Files sowie aller Klassen.

### Test

1) Prüfe mit gulp build ob erfolgreich renamed wurde

```bs
gulp build
```

2) Prüfe mit gulp bundle ob erfolgreich renamed wurde

```bs
gulp bundle
```

3) Prüfe ob das WebPart in der local workbench

Starte den Local Server

```bs
gulp serve
```
Teste das Webpart aus

```html
https://localhost:4321/temp/workbench.html
```
## Learning aus Rename

> - Fehlermeldung müssen behoben werden, da sonst kein build/bundle möglich
> - Namenskonventionen beibehalten vom yo @microsoft/sharepoint Generator 
> - VS.Code schliessen und wieder starten hilft bei Chacheing Problemen
> - Lokales Testing ist möglich und wichtig