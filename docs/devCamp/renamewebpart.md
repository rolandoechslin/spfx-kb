# Rename WebPart

## Vorbedinung

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

## Aufgabe

- Replace des erstellten "WebPartName" und Rename aller Folder und Files sowie aller Klassen.

## Test

Prüfe mit gulp build ob erfolgreich renamed wurde

```bs
gulp build
```

Prüfe mit gulp bundle ob erfolgreich renamed wurde

```bs
gulp bundle
```

Starte den local server

```bs
gulp serve
```

Prüfe ob das WebPart in der local workbench funktioniert

```html
https://localhost:4321/temp/workbench.html
```

## Learning aus Rename

> - Fehlermeldung müssen behoben werden, da sonst kein build/bundle möglich
> - Namenskonventionen beibehalten vom yo @microsoft/sharepoint Generator
> - Es sind releativ viele (initial 8 Files) beteiligt an einem WebPart, welche zusammenspielen müssen
> - VS.Code schliessen und wieder starten hilft bei Chaching Problemen
> - Lokales Testing ist möglich und wichtig