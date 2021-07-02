# Styling {#styling}

The purpose of the styling in Clikpage is to rectify some of the difficulties of working with CSS, and to use the same mechanism to apply options to configurable components like menus and slideshows.

The most important failing of CSS that we correct is that it cascades. To ensure sites are editable and maintainable, we replace cascading with inheritance. 

All styling is applied directly to items at a single level with the same specificity. Items and classes can inherit other styles, but any single behavior or style will have a clear source and can be edited without fear of breaking everything else.

Key to using the styling in Clikpage is correct creation of class hierarchies.





## Creating a style sheet







