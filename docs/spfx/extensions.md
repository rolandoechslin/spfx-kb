# Extensions

## Tipps

- [How to properly add an Application Customizer to an existing SPFx Web Part Project](http://www.dotnetmafia.com/blogs/dotnettipoftheday/archive/2019/01/08/how-to-properly-add-an-application-customizer-to-an-existing-spfx-web-part-project.aspx)

## Samples

- [React-application-profile-meter](https://github.com/sprider/spfx-extensions/tree/master/react-application-profile-meter)
- [How to create news ticker, SPFx-extension](https://letslearnoffice365.wordpress.com/2019/03/22/news-ticker-spfx-extension/)

## Full Page

- [SharePoint Full Page Canvas App](https://github.com/aflyen/spfx-extension-fullpagecanvas)
- [spfx-appcust-removeFeeback](https://github.com/StfBauer/spfx-appcust-removeFeeback)
- [React slider field customizer](http://tricky-sharepoint.blogspot.ch/2017/07/sharepoint-framework-extensions-react.html)
- [SharePoint Framework custom header and footer application customizer extension](https://github.com/dannyjessee/SPFxHeaderFooter)
- [Check the page display mode from within your SharePoint Framework extensions](https://www.eliostruyf.com/check-page-mode-from-within-spfx-extensions)

## ListView

- [Showing or hiding SharePoint Framework ListView custom actions based on permissions and selected items](https://www.eliostruyf.com/showing-or-hiding-sharepoint-framework-listview-custom-actions-based-on-permissions-and-selected-items)
- [SPFX ListView Command Set and Panel](https://ypcode.wordpress.com/2019/01/03/spfx-listview-command-set-and-panel/)
- [Let users get a simple link to a document or folder](https://jonasbjerke.wordpress.com/2019/01/06/extending-sharepoint-let-users-get-a-regular-link-to-a-document-or-folder/)
- [Create Modern Page Model with PnP/PnPjs](http://www.federicoporceddu.com/2019/03/16/modern-page-model-with-pnp-pnpjs/)

## Bots

- [Add AtBot to your SharePoint site using SPFx](https://blog.getbizzy.io/add-bizzy-to-your-sharepoint-site-using-spfx-ab7ed97b856c)

## Comments

- [Receive comment notifications by email in Modern SharePoint Pages](http://sharepoint.handsontek.net/2018/08/13/receive-comment-notification-by-email-in-modern-sharepoint-pages)
- [Github: Receive comment notifications on Modern SharePoint pages by email](https://github.com/joaoferreira/Comments-Notifications-On-Modern-SharePoint-Pages)

## Change browser favicon icon

- [Change favicon on Modern SharePoint sites](http://sharepoint.handsontek.net/2018/08/24/change-favicon-on-modern-sharepoint-sites)
- [SPFx-favicon](https://github.com/joaoferreira/SPFx-favicon)

## Google GA

- [Tracking code in Tenant Wide Extensions list](http://www.expiscornovus.com/2019/01/02/tracking-code-in-tenant-wide-extensions-list/)
- [SPFx-Google-Analytics](https://github.com/joaoferreira/SPFx-Google-Analytics/)

## Inject CSS

- [Inject Custom CSS on SharePoint Modern Pages using SPFx Application Extensions](https://tahoeninjas.blog/2018/10/29/update-inject-custom-css-on-sharepoint-modern-pages-using-spfx-application-extensions/)
- [Add Google Analytics to SharePoint modern pages](https://joelfmrodrigues.wordpress.com/2019/01/10/add-google-analytics-to-sharepoint-modern-pages/)
- [Whitespace – Regain distraction-free working in SharePoint](https://n8d.at/blog/whitespace-regain-distraction-free-working-in-sharepoint/?utm_content=bufferd23ab&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer)

## SPA

- [Single Page App In SharePoint Using React](https://www.c-sharpcorner.com/article/single-page-app-in-sharepoint/)

## Navigations

- [Handling navigation in a SharePoint Framework application customizer](https://www.eliostruyf.com/handling-navigation-in-a-sharepoint-framework-application-customizer)

## Placeholders

- [Safely using Placeholders in an extension](https://github.com/SharePoint/sp-dev-docs/wiki/Safely-using-Placeholders-in-an-extension)

```tsx
private _topPlaceholder : PlaceholderContent;
public onInit(void){
    this.context.placeholderProvider.changedEvent.add(this, this._handlePlaceholderChange.bind(this));
}

private _handlePlaceholderChange(){
  if (!this._topPlaceholder)
  {
    // We don't have a placeholder populated yet.  Let's try and get it.
    this._topPlaceholder = this.context.placeholderProvider.tryCreateContent(PlaceholderName.Top);
  } else {
    // We have a placeholder - let's make sure that it still exists.
    let index:number = this.context.placeholderProvider.placeholderNames.indexOf(PlaceholderName.Top);
    if ( index < 0)
    {
        // The placeholder is no longer here.
        this._topPlaceholder.dispose();
        this._topPlaceholder = undefined;
    }
  }
  if ( this._topPlaceholder )
  {
      this._topPlaceholder.innerText = 'Hello World!';
  }
}
```