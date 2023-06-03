# Data Sets
 
To generate the data for menus, lists, and other content with multiple values, "data sets" define the type of data and the search criteria.

Usually the criteria is a just a tag, but it can be more complicated.


## Using in JavaScript

When we come to apply data to content sections, we only use the array of IDs from the data set, and then use the site data to generate the required data.

For an example, for an image grid with a photo popup, the dataset would be something like `[1,2,3,4]`. This is passed as an option to the `photogrid` plug in.

```JavaScript
$imagegrid.photoGrid({dataset:[1,2,3,4]});
```

The photogrid wrapper plug in will then create a full data array to pass to the popup plug in, e.g.

```JavaScript
data: clik.getImages(plugin.options.dataset),
```

There are utility functions for `getImages` and `getArticles` in the clik utils.

