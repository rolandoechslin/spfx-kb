// https://valerasnarbutas.github.io/posts/tip-day-handlebar-helper-groupby/

  ReactContentQuery.ExternalScripts.handlebarsGroupBy = {
    onPreRender: function (wpContext, handlebarsContext) {
      handlebarsContext.registerHelper('groupBy', function (array, options) {
        const prop = options.hash && options.hash.by;
        const sortBy = options.hash && options.hash.sortBy;
        const sortOrder = (options.hash && options.hash.sortOrder) || 'asc';
        if (!prop || !array || !array.length) return options.inverse(this);

        const groups = array.reduce((acc, item) => {
          const key = item[prop].rawValue;
          if (!acc[key]) acc[key] = { groupName: key, groupItems: [] };
          acc[key].groupItems.push(item);
          return acc;
        }, {});

        const sortedKeys = Object.keys(groups).sort((a, b) => {
          if (sortBy) {
            const aValue = groups[a].groupItems[0][sortBy].rawValue;
            const bValue = groups[b].groupItems[0][sortBy].rawValue;

            if (aValue < bValue) return sortOrder === 'asc' ? -1 : 1;
            if (aValue > bValue) return sortOrder === 'asc' ? 1 : -1;
          }
          
          if (a < b) return -1;
          if (a > b) return 1;
          return 0;
        });
        
        return sortedKeys.map((key) => options.fn(groups[key])).join('');
      });
    },
  };
