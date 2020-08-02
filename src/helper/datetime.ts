// Source: https://blog.meenavalli.in/post/spfx-webpart-convert-datatime-value-time-zone-with-pnpjs

import { sp } from '@pnp/sp';
import '@pnp/sp/webs';
import '@pnp/sp/lists';
import '@pnp/sp/items';
 
const listName = "Events";
let items = await sp.web.lists.getByTitle(listName)
.items
.select("Title","Description","StartDate","EndDate","FieldValuesAsText/StartDate","FieldValuesAsText/EndDate")
.expand("FieldValuesAsText")
.get();
 
console.dir(items);