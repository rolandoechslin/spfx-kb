# First Session
* Herausfinden, ob ihr lokal oder in SPO entwickelt
* Basierend darauf, kann der Fake oder Real Data Provider genutzt werden
* Mit PNP im Real Data Provider ein List Item auslesen
* Das List Item mit einer Office UI Fabric Komponente darstellen

## Requirements
* Beispiel-Lösung hier abgelegt: ???Link zum Repo???


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