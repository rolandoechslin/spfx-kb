import { override } from '@microsoft/decorators';
import { Log } from '@microsoft/sp-core-library';
import {
  BaseApplicationCustomizer,
  PlaceholderContent,
  PlaceholderName
} from '@microsoft/sp-application-base';
import styles from './AppCustomizer.module.scss';
import * as strings from 'NewsTickerApplicationCustomizerStrings';
import { SPHttpClientResponse, SPHttpClient } from '@microsoft/sp-http';
const LOG_SOURCE: string = 'NewsTickerApplicationCustomizer';
 
export interface INewsTickerApplicationCustomizerProperties {
  Top: string;
}
 
export default class NewsTickerApplicationCustomizer
  extends BaseApplicationCustomizer<INewsTickerApplicationCustomizerProperties> {
  private _topPlaceholder: PlaceholderContent | undefined;
 
  @override
  public onInit(): Promise<void> {
    Log.info(LOG_SOURCE, `Initialized ${strings.Title}`);
    this.context.placeholderProvider.changedEvent.add(this, this._renderPlaceHolders);
    return Promise.resolve();
  }
  private _renderPlaceHolders(): void {
    if (!this._topPlaceholder) {
      this._topPlaceholder = this.context.placeholderProvider.tryCreateContent(
        PlaceholderName.Top,
      );
 
      if (this.properties) {
        let topString: string = this.properties.Top;
        if (!topString) {
          topString = "(Top property was not defined.)";
        }
        if (this._topPlaceholder.domElement) {
          this.context.spHttpClient.get(`${this.context.pageContext.site.absoluteUrl}/_api/web/lists/SitePages/items?`,
          SPHttpClient.configurations.v1,
          {
            headers: {
              'Accept': 'application/json;odata=nometadata',
              'odata-version': ''
            }
          }).then((response: SPHttpClientResponse): Promise<{ value: any[] }> => {
            return response.json();
          }).then((newses) => {
            let newsContainer = "";
            newses.value.map((news) => {
              if (news.TypePage == "News") {
                newsContainer += news.Title + " - " + news.Description + "&nbsp&nbsp&nbsp¤&nbsp&nbsp&nbsp";
                this._topPlaceholder.domElement.innerHTML = `
                <div class="${styles.app}" >
                    <div class="${styles.top}">
                        <marquee width="100%" direction="left" height="100%" style="font-size:22px;" id="field">
                            ${"&nbsp&nbsp&nbsp¤&nbsp&nbsp&nbsp" + newsContainer} 
                        </marquee>
                    </div>
                </div>`;
              }
            });
          });
        }
      }
    }
  }
}