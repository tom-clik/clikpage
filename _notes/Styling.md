# Styling

Split into container styles and content styles. Container styles use CSS inheritance via the name of the template applied to the body class. Content styles are all applied individually to the content section via a single `#id` qualifier.

## Container styles

Container styles are applied to a template. Some bugs with this -- doesn't inherit.

Can also be assigned via classes. Attach a class to container div and it will apply.

### Implementation

A class `template-templatename` is applied to the body for a layout. If the layout inherits, then all that template name is also applied, e.g. for a template `homepage` that inherits from `main`

```
class="template-main template-homepage"
```

This means any styling applied via main will apply to the homepage as well.

To generate the template styling, we loop over each layout in a site, and call a function `settings.layoutCss()`. This loops over all the containers and calls `containerCss()`.

## Content styles


### Implementation

A method, settings is used to calculate generate the full settings for a content section and save it in cs.settings.

To do this, it has to get all the styling applied via classes and also work out which settings inherit across media.

As many settings as possible are applied via CSS vars and can be applied very simply. Settings that don't translate to CSS vars have to inherit according to the media queries. 







