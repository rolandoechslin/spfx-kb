# Rename WebPart


## Ablage einer Hello World Solution

- Beispiel-Lösung hier abgelegt
  - https://stash.garaio.com/projects/SPFX/repos/spfxdevcamp2018

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
``

## Learning aus Rename

> - Fehlermeldung müssen behoben werden, da sonst kein build/bundle möglich
> - Namenskonventionen beibehalten vom yo @microsoft/sharepoint Generator
> - Es sind releativ viele (initial 15 Files) beteiligt an einem WebPart, welche zusammenspielen müssen
> - VS.Code schliessen und wieder starten hilft bei Chacheing Problemen
> - Lokales Testing ist möglich und wichtig