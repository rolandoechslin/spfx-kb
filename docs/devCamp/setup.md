# Maschine vorbereiten

Hier lernt ihr, wie ihr eure Maschine zur SPFx DEV Maschine transformiert.

## COL-TOOLS
* Auf Laptop kopieren
* Zusätzliches installieren
* 
```powershell
# choco installieren
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# git
choco install git.install

# pegeant
choco install putty.install

# git tool
choco install gitkraken
choco install gitextensions
```

# VS Code vorbereiten

**must have**

- [Debugger for Chrome](https://marketplace.visualstudio.com/items?itemName=msjsdiag.debugger-for-chrome)
- [TSLint](https://marketplace.visualstudio.com/items?itemName=eg2.tslint)

**good to have**

- [Auto Import](https://marketplace.visualstudio.com/items?itemName=steoates.autoimport)
- [Import Cost](https://marketplace.visualstudio.com/items?itemName=wix.vscode-import-cost)
- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

# SPFx Requirements installieren und erstes Projekt erstellen

[Hier](https://stash.garaio.com/projects/GPS/repos/col-tools/browse/Scripts/Setup-SPFxDevEnv.ps1) ist das Setup-Skript abgelegt

# PNP cachen

```bs
pnpm install @pnp/logging @pnp/common @pnp/odata @pnp/sp @pnp/graph --save
```

# Chrome Extension

- [SP Editor](https://chrome.google.com/webstore/detail/sp-editor/ecblfcmjnbbgaojblcpmjoamegpbodhd)

# Check

Am Ende werdet ihr folgendes erledigt/installiert haben:

- NVM installiert
- node.js installiert
- Notwendige NPM-Module mit **pnpm** installiert
- Mit yo ein neus SPFx Projekt erstellt
- Notwendige Tools und Extensions installiert