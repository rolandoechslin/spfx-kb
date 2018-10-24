# Theme

- https://laurakokkarinen.com/how-to-create-a-multicolored-theme-for-a-modern-sharepoint-online-site/

## Theme-Support

- https://github.com/StfBauer/spfx-uifabric-themes

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