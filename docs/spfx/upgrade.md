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
- [Commands to upgrade an SPFx project to version 1.6](https://gist.github.com/chrisobriensp/980ee65911203a80050e9ce3edf2a34a)


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

## Support Issues

### Azure Permission

- http://spblog.net/post/2018/09/19/You-might-experience-errors-when-first-trying-new-SPFx-16-features
- <https://github.com/SharePoint/sp-dev-docs/issues/2473#issuecomment-419111117>

```bs
- Go to the "API Management"-section in the SharePoint Preview Admin Center (https://TENANT-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx#/webApiPermissionManagement)
  - Ensure that no permissions are there anymore 
  - Head over to the App Registrations Page in the Azure Portal.
  - Click "View all applications"
  - Click "SharePoint Online Client Extensibility Web Application Principal"
  - Choose "Settings" > "Required Permissions"
  - Click "Add"
    - "Select an API" and choose "Windows Azure Active Directory", press "Select"
    - "Select Permissions" and choose "Sign in and read user profile", press "Select"
  - Click "Done"
  - Click "Grant permissions" and "Yes"
  - Update the app package in the app catalog
  - Head back to the "API Managment"-section:
    - Ensure that "Windows Azure Active Directory" is already listed in the approved permissions (this permission should be here because of the previously executed steps).
    - Approve all permission requests one by one. Once this is done, reload the page to ensure that all permissions are actually approved as the SharePoint UI doesn't always behave as expected.
  - Wait a couple of minutes
  - Log out of SharePoint, close all browser windows and log in again
  - Access your intranet and everything should be fine
  ```
