// Info: https://simonagren.github.io/pnpjs-update-managed-metadata/

// import { sp } from "@pnp/sp";
// import { taxonomy, ITerm, ITermData } from "@pnp/sp-taxonomy";

// public async doStuff(): Promise<void> {

//     // Using taxonomy to get term set
//     const store = await taxonomy.getDefaultSiteCollectionTermStore();
//     const termset = await store.getTermSetById("10e3b8d1-edef-48ce-82f4-d184c5cd49b2");
    
//     // get a single term
//     const term = await termset.terms.getByName("Term2").get();

//     // get all terms in termset
//     const terms = await termset.terms.get();

//     // Update single valued taxonomy field and log updated item
//     console.log(await this.updateMeta(term, 'ListName', 'Meta', 1));
    
//     // Update multi valued taxonomy field and log updated item
//     console.log(await this.updateMultiMeta(terms, 'ListName', 'MultiMeta', 1));

//   }

// public cleanGuid(guid: string): string {
//     if (guid !== undefined) {
//         return guid.replace('/Guid(', '').replace('/', '').replace(')', '');
//     } else {
//         return '';
//     }
// }

// public async updateMeta(term: (ITerm & ITermData), list: string, field: string, itemId: number): Promise<any> {
//     const data = {};
//     data[field] = {
//       "__metadata": { "type": "SP.Taxonomy.TaxonomyFieldValue" },
//       "Label": term.Name,
//       'TermGuid': this.cleanGuid(term.Id),
//       'WssId': '-1'
//     };

//     return await sp.web.lists.getByTitle(list).items.getById(itemId).update(data);

//   }

//   public async updateMultiMeta(terms: (ITerm & ITermData)[], listName: string, fieldName: string, itemId: number): Promise<any> {
//     const data = {};

//     const list = await sp.web.lists.getByTitle(listName);
//     const field = await list.fields.getByTitle(`${fieldName}_0`).get();

//     let termsString: string = '';
//     terms.forEach(term => {
//       termsString += `-1;#${term.Name}|${this.cleanGuid(term.Id)};#`;
//     })

//     data[field.InternalName] = termsString;

//     return await list.items.getById(itemId).update(data);

//   }