# Laptop

## prereq

VS Code

https://code.visualstudio.com/download

Debugger for Chrome Extension

https://marketplace.visualstudio.com/items?itemName=msjsdiag.debugger-for-chrome

Skript

https://stash.garaio.com/projects/GPS/repos/col-tools/browse/Scripts/Setup-SPFxDevEnv.ps1

## step 1: run those two commands and restart

```Powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

```Powershell
C:\ProgramData\chocolatey\choco.exe install nvm -y
```

RESTART CONSOLE

## step 2: install nvm and specific node version

node version manager (nvm) is used to manage different node versions. SPFx uses an older version of node
Read-Host -Prompt "you need to restart the console in order to get nvm to work. please do that now if not already done. press ctrl + c, restart console and continue script from this point forward"

```Powershell
nvm install 8.11.3
```

## change to installed SPFx node version

```Powershell
nvm use 8.11.3
```

Add check if correct node version is selected. if not, maybe already installed node is the problem. can we add that one to nwm?!

## disable experimental http2 feature in node v8

```Powershell
[Environment]::SetEnvironmentVariable("NODE_NO_HTTP2", "1", "Machine")
```

RESTART CONSOLE

install global dependencies

```Powershell
npm install -g yo gulp @microsoft/generator-sharepoint pnpm
```

## step 3: create your firs spfx project

create projekt dir and cd into it (you can chose whatever folder you like)

```Powershell
mkdir d:\projects
cd d:\projects
```

follow the yeoman wizard

```Powershell
Yo @microsoft/sharepoint --package-manager pnpm
```

change into project dir

```Powershell
Write-Host "change to project directory first"
```

open vscode

```Powershell
code .
```

## step 4: fine tuning

trust localhost dev cert

```Powershell
Gulp trust-dev-cert
```

start dev server

```Powershell
Gulp serve
```
