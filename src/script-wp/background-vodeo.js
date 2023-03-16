
// https://sharepoint.handsontek.net/2023/03/15/use-video-background-sharepoint-pages-header/

<script>
    const videoURL = "https://handsonsp.sharepoint.com/sites/Intranet/Shared%20Documents/Videos/Mountains.mp4";

    waitForBackground('[data-automation-id="titleRegionBackgroundImage"]').then((elm) => {    
        elm.insertAdjacentHTML( 'beforeend', `<video loop muted autoplay src="${videoURL}" style="height: 100%; margin: 0px; object-fit: cover; padding: 0px; position: absolute; width: 100%; object-position: center center;"></video>`);
        waitForBackground('[data-automation-id="titleRegionBackgroundImage"] img').then((img) => {
            img.style.display = 'none';
        });
    });

    function waitForBackground(selector) {
        return new Promise(resolve => {
            if (document.querySelector(selector)) {
                return resolve(document.querySelector(selector));
            }

            const observer = new MutationObserver(mutations => {
                if (document.querySelector(selector)) {
                    resolve(document.querySelector(selector));
                    observer.disconnect();
                }
            });

            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        });
    }
</script>