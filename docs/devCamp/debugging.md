# Debugging
Weiterführende Informationen: [SPFx Debugging](../spfx/debug.md)

## Requirements
[Debugger for Chrome](https://marketplace.visualstudio.com/items?itemName=msjsdiag.debugger-for-chrome)

## Prepare
```
gulp trust-dev-cert
gulp serve
```

## Local
* F5 drücken im VS Code und Local auswählen

## Remote
* /.vscode/launch.json anpassen

**Vorher**
```json
{
      "name": "Hosted workbench",
      "type": "chrome",
      "request": "launch",
      "url": "https://enter-your-SharePoint-site/_layouts/workbench.aspx",
      "webRoot": "${workspaceRoot}",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:///../../../src/*": "${webRoot}/src/*",
        "webpack:///../../../../src/*": "${webRoot}/src/*",
        "webpack:///../../../../../src/*": "${webRoot}/src/*"
      },
      "runtimeArgs": [
        "--remote-debugging-port=9222",
        "-incognito"
      ]
}
```

**Nachher (URL angepasst)**
```json
{
      "name": "Hosted workbench",
      "type": "chrome",
      "request": "launch",
      "url": "https://gw365dev.sharepoint.com/sites/kboapp/_layouts/workbench.aspx",
      "webRoot": "${workspaceRoot}",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:///../../../src/*": "${webRoot}/src/*",
        "webpack:///../../../../src/*": "${webRoot}/src/*",
        "webpack:///../../../../../src/*": "${webRoot}/src/*"
      },
      "runtimeArgs": [
        "--remote-debugging-port=9222",
        "-incognito"
      ]
}
```

* Links im VS Code auf Debug wechseln
* Oben die Configuration "Hosted workbench" auswählen
* Ab jetzt kann auch mit F5 gestartet werden

## Wenns nicht klappt
* Zurück zur alten Version
```powershell
nvm install 6.12.0
nvm use 6.12.0
npm install -g yo gulp @microsoft/generator-sharepoint@1.4.1

gulp trust-dev-cert
gulp serve
```
