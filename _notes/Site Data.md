# Site Data

For all JavaScript functionality, we save a copy of the site data to a cached javaScript file.

This is done by `site.saveData()`. It saves a file to `scripts/sitedata.js` which needs adding as a javascript file to the page content. We will improve this to only re-save if the data saves.

This currently has `site.data.images` and `site.data.articles`. This architecture will need revisiting to split the data into chunks (e.g by gallery).

