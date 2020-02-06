// https://joelfmrodrigues.wordpress.com/2020/02/06/easily-convert-pnp-taxonomypicker-selection-to-update-value/
// https://sharepoint.github.io/sp-dev-fx-controls-react/controls/TaxonomyPicker/

const getManagedMetadataFieldValue = (terms: IPickerTerm[]): string => {
    let termValue = "";
    for (const term of terms) {
      termValue += `${term.name}|${term.key};`;
    }
    return termValue;
  };

await list.items.getById(itemId).update({
    // update hidden note fields associated with the managed metadata fields
    'NoteFieldName': selectedTerms ? getManagedMetadataFieldValue(selectedTerms) : null
});