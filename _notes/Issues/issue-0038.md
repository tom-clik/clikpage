# Save static version

To save a static version of a site, we loop over every section and page and save a page.

Pages are always saved with the name `{section}[_{action}]_[{id}].html`. The web server takes care of more SEO friendly names.

Links are automatically converted to static links when the site mode is [tbc].

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

### Request Content

For the request content, we need to add the site stylesheet to the page () and use the packages for the static files.

```
content.static_js["menus"] = 1;
content.static_css["content"] = 1;
pageObj.addCss(content,"adhocstyle.css");
```

