# Save static version

To save a static version of a site, we loop over every section and page and save a page.

Pages are always saved with the name `{section}(_{action}]|_{id}).html`. We need another site mode, SEO, where the pages links will be SEO friendly, but the filenames will still be the same.

Links are automatically converted to static links when the site mode is `static`.

Debug versions of the scripts are used. We also try to use the defined packages. Where a script is specified in a content section, if it is already in a package, it will use the package.

NB at this time the CS caching isn't really working. The speed will improve when this is done.

## Setting site mode

`site.mode='static'` will configure the pages to point to a static site.

## Saving stylesheets

The styles are generated and saved to `{outputDir}/styles.css`

## Looping over sections

NB At this time we haven't decided how to gallery sub indexes e.g. gallery index page.

A page is saved for the default action (currently index).

If there is a dataset, we get that and then save a page for each item in the data set (action=view).

NB There is an issue with sub sections using dataset for their menus. This causes a complete set of pages to be saved out for each submenu. See Issue #45. We need a "parent" dataset. This should incorporate work for galleries.

### Request Content

For the request content, we need to add the site stylesheet to the page and use the packages for the static files.

This is done something like this:

```
content.static_js["main"] = 1;
content.static_css["content"] = 1;
pageObj.addCss(content,"styles.css");
```

