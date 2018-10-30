# Extensions

## Full Page

- https://github.com/aflyen/spfx-extension-fullpagecanvas
- https://github.com/StfBauer/spfx-appcust-removeFeeback
- http://tricky-sharepoint.blogspot.ch/2017/07/sharepoint-framework-extensions-react.html (React slider field customizer)
- https://github.com/dannyjessee/SPFxHeaderFooter
- https://www.eliostruyf.com/check-page-mode-from-within-spfx-extensions

## ListView

- [Showing or hiding SharePoint Framework ListView custom actions based on permissions and selected items](https://www.eliostruyf.com/showing-or-hiding-sharepoint-framework-listview-custom-actions-based-on-permissions-and-selected-items)

## Comments

- [Receive comment notifications by email in Modern SharePoint Pages](http://sharepoint.handsontek.net/2018/08/13/receive-comment-notification-by-email-in-modern-sharepoint-pages)
- [Github: Receive comment notifications on Modern SharePoint pages by email](https://github.com/joaoferreira/Comments-Notifications-On-Modern-SharePoint-Pages)

## Change browser favicon icon

- [Change favicon on Modern SharePoint sites](http://sharepoint.handsontek.net/2018/08/24/change-favicon-on-modern-sharepoint-sites)
- [SPFx-favicon](https://github.com/joaoferreira/SPFx-favicon)

## Inject CSS

- [Inject Custom CSS on SharePoint Modern Pages using SPFx Application Extensions](https://tahoeninjas.blog/2018/10/29/update-inject-custom-css-on-sharepoint-modern-pages-using-spfx-application-extensions/)

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