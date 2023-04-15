# Layouts

Layouts control what _content_ is applied to a page. The most important thing to understand about the Clik system is that _content_ is not _data_. _Content_ defines the position and styling of items such as menus, titles, and photo grids. A _style_ will define _content_ and can be re-used across different sites which will define different _data_.

All information on a layout is defined as a content section, whether that's just a simple text item, or a menu with sub menus.

Layouts can inherit from other layouts, and key to successful Clik design is creating abstract layouts to contain common elements.

Typically three layers will be defined, a base layout, a page layout that gets reused across sections, and detail layouts, which are used for specific sections.

Often a detail layout can be reused. A layout that defines a single page with a title and some text could be used for a number of sections. Other more complicated layouts can still be reused by defining "data" for a section.

Layouts define "containers" (which are just divs designed solely for HTML layout), and content items, such as menus.

All content items should use data for their content. For a simple text item it might be a site field, such as `{{site.title}}`. Any item that gets reused across pages should certainly use data. A site that uses only data, even for simple text strings, can be easily localised or used as a template.

For more complicated items like menus, article lists, photo galleries, data _has_ to be used. Data sets can be global, or they can be defined in a section, allowing layouts to be easily reused.

A typical global data set would be a list of sections for the main menu. This would usually be all sections tagged "main menu".

A section dataset might be a list of articles or products. Content sections that show "detail" of content require a dataset to be defined and to contain the record being shown. Navigation buttons can then be linked to the content section to show next and previous buttons.