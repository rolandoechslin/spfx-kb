// Source: https://gist.github.com/estruyf/c308dc012fcf2d802c98247f6c38d605

const layoutContent = data.LayoutWebpartsContent;
const el = document.createElement('div');
el.innerHTML = layoutContent;
const divElm = el.querySelectorAll("[data-sp-canvascontrol]");
if (divElm && divElm.length > 0) {
  const cntlData = divElm[0].getAttribute("data-sp-controldata");
  if (cntlData) {
    const pCtrlData = JSON.parse(cntlData);
    if (pCtrlData && pCtrlData.properties) {
      const focalData = {
        translateX: pCtrlData.properties.translateX || null,
        translateY: pCtrlData.properties.translateY || null
      };
      
      // Now you can add the focal data to your images
    }
  }
}