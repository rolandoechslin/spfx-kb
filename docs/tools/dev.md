# Dev Tools

- [Ultimate Developer Tool List for SPFx](https://tahoeninjas.blog/2019/03/14/ultimate-developer-tool-list-for-spfx/)

## Create shortcut(s)

- [create shortcut(s) for your common SharePoint Framework generator commands](https://spblog.net/post/2019/04/30/sharepoint-framework-development-tips-create-shortcut-s-for-your-common-sharepoint-framework-generator-commands)

## Debug

- [mastykarz: easily debug production version](https://blog.mastykarz.nl/debug-production-version-sharepoint-framework-solution/)
- [sergei-sergeev: easily debug production version](https://spblog.net/post/2019/04/02/sharepoint-framework-development-tips-even-more-easily-debug-production-version-of-your-sharepoint-framework-solution)

## TweetDeck (Twitter)

- [How to filter for SharePoint Framework #SPFx related tweets in TweetDeck](https://github.com/andikrueger/TweetDeckSPFxFilter)

## PowerShell Module Installs

- [Office 365 PowerShell Module Installs](https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=826)
- [O365 PowerShell Module Installs](https://albandrodsmemory.wordpress.com/2019/05/10/o365-powershell-module-installs/)

## Translation

- [deepl translator](https://www.deepl.com/translator)

## Dokumentation Site Generator

- [mkdocs-material](https://squidfunk.github.io/mkdocs-material)
- [docusaurus](https://docusaurus.io)
- [dochameleon](https://dochameleon.io)

## Convert / Format

- [freeformatter.com](https://www.freeformatter.com)

## Content generators

- <http://spaceipsum.com>
- [http://socialgoodipsum.com](http://socialgoodipsum.com/#/)
- [Office Ipsum](http://officeipsum.com/index.php)
- <http://trollemipsum.appspot.com>

## Image Tools

- [unsplash - free images](https://unsplash.com)
- ([pixabay - free images](https://pixabay.com)
- [20 Websites To Find Free High-Quality Images](https://www.hongkiat.com/blog/free-stock-photo-websites/)
- [mazwai - free background images](http://mazwai.com)
- [dummyimage](https://dummyimage.com)

## Password generators

- [Random password generator](https://www.msdservices.com/apg/index.php)
- [password-generators](https://www.hongkiat.com/blog/password-generators)

## Guid

- [GUID Generator](https://www.guidgen.com)

## Json

- [Online Json viewer](http://jsonviewer.stack.hu)
- [Fake Json Generator](https://jsonplaceholder.typicode.com)
- <https://json-csv.com>

## Change Log

- [keepachangelog](http://keepachangelog.com/en/1.0.0)

## Email

- [Responsive Email Foundation Zurb](https://foundation.zurb.com/emails.html)
- [mailchimp - newsletter](https://mailchimp.com)
- [10MinuteMail](https://www.10MinuteMail.com/)

## Ressourcen Files

- <https://poeditor.com/>
- <https://github.com/ypcode/spfx-dev-tools> (Ressourcen Files mit Excel editieren)
- [Excel and PowerShell to maintain your SPFx localized resources](https://ypcode.wordpress.com/2018/06/08/excel-and-powershell-to-maintain-your-spfx-localized-resources)
- [JavaScript Internationalization Framework](https://github.com/facebookincubator/fbt)

## ULS

- [sharepointring](https://sharepointring.com)

## VS.Code

### Command Line

- [Command Line Interface (CLI)](https://code.visualstudio.com/docs/editor/command-line)

open last active window

```ps
code -r .
```

open in new window

```ps
code -n
```

### VS.Code Extensions

- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [Introducing SharePoint Typed Item](https://spblog.net/post/2019/02/28/introducing-sharepoint-typed-item-visual-studio-code-extension)
- [Backup and Synchronize VSCode Settings with a GitHub Gist](https://mikefrobbins.com/2019/03/21/backup-and-synchronize-vscode-settings-with-a-github-gist/)

### Remove git integrations from VSCode

settings.json

```json
// Is git enabled
"git.enabled": false,
```

```json
// Path to the git executable
"git.path": null,
```

```json
// Whether auto fetching is enabled.
"git.autofetch": false,
```

Info: https://stackoverflow.com/questions/30331338/remove-git-integrations-from-vscode

### Exclude Folders from VS.Code

- [How can I exclude a directory from Visual Studio Code 'Explore' tab](https://stackoverflow.com/questions/33258543/how-can-i-exclude-a-directory-from-visual-studio-code-explore-tab)

## CLI App Generator

- [generator-sppp](https://github.com/koltyakov/generator-sppp)
- [SharePoint front-end projects automation and tasks tool-belt](http://blog.arvosys.com/2017/10/04/sharepoint-front-end-projects-automation-and-tasks-tool-belt/index.html)
- https://github.com/facebook/create-react-app
- <https://github.com/StfBauer/generator-simplestyle>

## Fabric Icons

- [Render Office Fabric UI Icons into Canvas](https://codepen.io/joshmcrty/pen/GOBWeV)
- <https://joshmccarty.com/made-tool-generate-images-using-office-ui-fabric-icon>
- <https://developer.microsoft.com/en-us/fabric#/styles/icons>
- http://uifabricicons.azurewebsites.net

## Favicons

- [favicon-generator](https://www.favicon-generator.org/)

## WebSite Builder

- [weebly.com](https://www.weebly.com)

## SP bookmarklets

- [Manage SharePoint using bookmarklets](https://sharepoint.handsontek.net/2019/03/31/manage-sharepoint-using-bookmarklets/)

Open Site Settings

```js
javascript:(function(){var url = document.location.href.split('/Pages')[0].split('/SitePages')[0].split('/_layouts')[0];if(url.endsWith('.aspx')){url = url.replace(new RegExp('\/[a-z A-Z 0-1 \- _]*.aspx'),'')}location.replace(url+"/_layouts/15/settings.aspx")}());
```

Open Page in Maintenance Mode

```js
javascript:(function(){location.replace(window.location.href+"?maintenancemode=true")})();
```

Go to Classic

```js
javascript:(function(){document.cookie="splnu=0;domain="+window.location.hostname+";"; location.href=location.href;})();
```

Go to Modern

```js
javascript:(function(){document.cookie="splnu=1;domain="+window.location.hostname+";"; location.href= location.href})();
```

Open Web Part Manager

```js
javascript:(function(){location.replace(window.location.href+"?contents=1")})();
```