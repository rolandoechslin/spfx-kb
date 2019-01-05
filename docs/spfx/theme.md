# Theme

- [BRK3090 - Customizing Modern SharePoint Sites: Branding, Site Scripts and Site Designs](https://myignite.techcommunity.microsoft.com/sessions/65682)
- [How to create a multicolored theme fora modern sharepoint online site](https://laurakokkarinen.com/how-to-create-a-multicolored-theme-for-a-modern-sharepoint-online-site/)
- https://github.com/SharePoint/sp-dev-fx-webparts/tree/master/samples/react-themes
- http://tricky-sharepoint.blogspot.ch/2017/04/using-sharepoint-themes-colors-in-spfx.html
- http://sass-lang.com/guideaspx
- [How to: Use PowerShell to customize the theme of a SharePoint Modern Site](http://www.dotnetmafia.com/blogs/dotnettipoftheday/archive/2017/10/17/how-to-use-powershell-to-customize-the-theme-of-a-sharepoint-modern-site.aspx)
- [How to make your web parts responsive to the parent container](https://n8d.at/blog/how-to-make-your-web-parts-responsive-to-the-parent-container)
- [Brand modern SharePoint Online sites](http://sharepoint.handsontek.net/2018/03/11/brand-modern-sharepoint-online-sites)
- [two approaches to applying modern theme](http://www.techmikael.com/2018/03/two-approaches-to-applying-modern-theme.html)
- [SPFX integration for theme support](https://github.com/StfBauer/spfx-uifabric-themes)

## Office Fabric Tips

- [How to handle table component of Office UI Fabric](https://n8d.at/blog/how-to-handle-table-component-of-office-ui-fabric/)
- [Office UI Fabric Table Example](https://gist.github.com/andrewconnell/18477c10edb7f9a32198)

## CSS Tips

- [CodyHouse is a library of HTML, CSS, JS nuggets](https://codyhouse.co)
- [A Complete Guide to Grid](https://css-tricks.com/snippets/css/complete-guide-grid)
- [CSS Grid — Responsive layouts and components](https://medium.com/deemaze-software/css-grid-responsive-layouts-and-components-eee1badd5a2f)
- [A Complete Guide to Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox)
- [MDN: Use CSS to solve common problems
](https://developer.mozilla.org/en-US/docs/Learn/CSS/Howto)

## Tools

- https://codepen.io/pen/
- https://caniuse.com
- https://jigsaw.w3.org/css-validator/
- https://addons.mozilla.org/en-US/firefox/addon/web-developer/

## Testing

- [How to test SPFx web part theming](https://n8d.at/blog/how-to-test-spfx-web-part-theming)

## Debug

### Output theme variables

- [Source Code](https://laurakokkarinen.com/how-to-create-a-multicolored-theme-for-a-modern-sharepoint-online-site/)

```js
var palette = window.__themeState__.theme;
var containerElement = document.createElement("div");
containerElement.style.padding = "1em";
containerElement.style.fontFamily = "sans-serif";
containerElement.style.columnCount = "3";
document.body.appendChild(containerElement);
var arr = Object.keys(palette).map(k => {
var colorElement =document.createElement("div");
colorElement.style.marginTop = "1ex";
var nameElement =document.createElement("span");
nameElement.style.display = "inline-block";
nameElement.style.minWidth= "150px";
nameElement.innerHTML = k
colorElement.appendChild(nameElement );
var squareElement = document.createElement("span");
squareElement.style.display= "inline-block";
squareElement.style.border= "solid 1px #888";
squareElement.style.width = "12px";
squareElement.style.height = "12px";
squareElement.style.margin = "0 2px 0 1ex";
squareElement.style.backgroundColor = window.__themeState__.theme[k];
colorElement.appendChild(squareElement);
var hexElement =document.createElement("span");
hexElement.innerHTML = window.__themeState__.theme[k];
colorElement.appendChild(hexElement);
containerElement.appendChild(colorElement);
});
```

![Theme-Teamsite-Image](https://i2.wp.com/laurakokkarinen.com/wp-content/uploads/2018/01/rainbow-theme-with-pointers.png?ssl=1)