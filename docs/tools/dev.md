# Dev Tools

- [Ultimate Developer Tool List for SPFx](https://tahoeninjas.blog/2019/03/14/ultimate-developer-tool-list-for-spfx/)

## TweetDeck (Twitter)

- [How to filter for SharePoint Framework #SPFx related tweets in TweetDeck](https://github.com/andikrueger/TweetDeckSPFxFilter)

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

- <https://pixabay.com>
- [20 Websites To Find Free High-Quality Images](https://www.hongkiat.com/blog/free-stock-photo-websites/)
- <http://mazwai.com/#/>
- https://dummyimage.com

## Password generators

- [Random password generator](https://www.msdservices.com/apg/index.php)
- [password-generators](https://www.hongkiat.com/blog/password-generators)

## Guid

- [GUID Generator](https://www.guidgen.com)

## Json

- [Online Json viewer](http://jsonviewer.stack.hu)
- [Fake Json Generator](https://jsonplaceholder.typicode.com)
- <https://json-csv.com>

## REST

- [postman-and-office-365](https://www.helloitsliam.com/2016/02/04/postman-and-office-365)
- [SharePoint REST API Metadata Explorer](https://s-kainet.github.io/sp-rest-explorer)

Testing in chrome console

```ts
fetch(`/sites/gridworks/_api/web/lists/getbytitle('SiteRequestsQueue')/items?$select=Id,Title,gwRequestSiteAlias&$orderby=Id desc`, {
    headers: {
        Accept: 'application/json;odata=verbose;'
    }
}).then(res => res.json().then(json => {
    json.d.results.forEach(item => {
        console.log(`item: ${item.Title}`);
    });
}));
```

## Change Log

- [keepachangelog](http://keepachangelog.com/en/1.0.0)

## Email

- <https://foundation.zurb.com/emails.html>
- <https://mailchimp.com/>

## Ressourcen Files

- <https://poeditor.com/>
- <https://github.com/ypcode/spfx-dev-tools> (Ressourcen Files mit Excel editieren)
- [Excel and PowerShell to maintain your SPFx localized resources](https://ypcode.wordpress.com/2018/06/08/excel-and-powershell-to-maintain-your-spfx-localized-resources)
- [JavaScript Internationalization Framework](https://github.com/facebookincubator/fbt)

## ULS

- [sharepointring](https://sharepointring.com)

## VS.Code

### VS.Code Extensions

- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [Introducing SharePoint Typed Item](https://spblog.net/post/2019/02/28/introducing-sharepoint-typed-item-visual-studio-code-extension)

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

## Favicons

- [favicon-generator](https://www.favicon-generator.org/)