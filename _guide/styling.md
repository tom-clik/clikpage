# Styling {#styling}

Styling in Clikpage allow a single stylesheet to define both standard styles like fonts, colors, or spacing, and also apply options to configurable components like menus and slideshows.

It also rectifies some of the difficulties of working with CSS, allowing for more intuitive and maintainable stylesheets.

The most important failing of CSS that we correct is that it cascades. To ensure editability, we replace cascading with inheritance. 

All styling is applied directly to items at a single level with the same specificity. Items and classes can inherit other styles, but any single behavior or style will have a clear source and can be edited without fear of breaking everything else.

Where possible we try to avoid styling applied by HTML markup, as in systems such a Bootstrap. 

## Inheritance

Key to using the styling in Clikpage is correct creation of "abstract" classes to apply settings to multiple content items or containers.

A class can inherit from other classes, or a content item can have multiple classes applied to it. The order in which the styles are applied is determined, like CSS, by the order in which they are defined.

## Default schemes

All content items are assigned a class according to their type. This is usually to provide some standard formatting from the static CSS, but can also be used to style content.

In a simple site, the _title_ type of content section could have the same styling applied to it whenever used. It would, though, usually be better to abstract this styling to a class and inherit it. Typically a _title_ scheme would be inherited by two or three title schemes such as _maintitle_ or _subtitle_.








