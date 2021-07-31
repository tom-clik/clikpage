# Layouts

Layouts control what content is applied to a page. Content is not _data_, which comes from a site definition. Content is the definition of items such as menus, titles, and photo grids.

All information on a page is defined as a content section, whether that's just a simple text message, or a full menu with sub menus.

Layouts can inherit from other layouts, and key to successful Clik design is creating abstract layouts to contain common elements.

Typically three layers will be defined, a base layout, a page layout that gets reused across sections, and detail layouts, which are used for specific sections.

Often a detail layout can be reused. A layout that defines a single page with a title and some text could be used for a number of sections. Other more complicated layouts can still be reused by defining "data" for a section.

Layouts define "containers" (which are just divs designed solely for HTML layout), and content items, such as menus.

All content items, no matter how simple, should use data for their content. For a simple text item it might be a site field, such as `{{site.title}}`.

For more complicated items like menus, article lists, photo galleries, data has to be used. Typically a content section might define a data set to be used (e.g. a footer menu). Content can also be defined to use a dataset defined in a section. This might be a list of articles or products.










