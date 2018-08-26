# Upgrade

## Office 365 CLI

- https://blog.mastykarz.nl/upgrade-sharepoint-framework-project-office-365-cli/
- https://tahoeninjas.blog/2018/06/12/upgrade-your-spfx-solution-to-sharepoint-framework-package-v1-5/

## Update Framework

- <http://www.sharepointnutsandbolts.com/2018/05/Update-SPFx-version.html>
- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/update-latest-packages>
- <http://sharepoint.handsontek.net/2017/12/11/asset-packaging-and-the-goodies-from-sharepoint-framework-1-4>

- <https://joelfmrodrigues.wordpress.com/2018/03/02/sharepoint-framework-checklist/>
- <https://www.sharepointnutsandbolts.com/2018/05/Update-SPFx-version.html>


go into solution folder

```bs
npm outdated
```

search für "@micorosoft/sp-"
update all

```bs
npm install package-name@version --save
```
or

```bs
npm install package-name@latest --save
```

```bs
gulp clean
gulp build
```