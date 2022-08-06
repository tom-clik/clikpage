# Styling {#styling}

Styling in Clikpage allow a single stylesheet to define both standard styles like fonts, colors, or spacing, and also apply options to configurable components like menus and slideshows.

All styling and configuration is applied by stylesheets. Where HTML markup needs to change to apply styling, this is done automatically by the system.

The system ameliorates some of the difficulties of working with CSS, allowing for more intuitive and maintainable stylesheets.

The most important failing of CSS that we correct is that it cascades. To ensure editability, we replace cascading with inheritance, which is how proper stylesheets work.

All styling is applied directly to items at a single level with the same specificity. Items and classes can inherit other styles, but any single behavior or style will have a clear source and can be edited without fear of breaking everything else.

## Inheritance

Key to using the styling in Clikpage is style inheritance. At the actual point any item is styled, there should be only one entry in the CSS that allows us to quickly diagnose where to edit it.

```
.scheme-heading {
	font-style: var(--heading-font);
	font-weight:bold;
}

.scheme-underlined {
	padding-bottom:0.4em;
	margin-bottom:0.4em;
	border-width: 0 0 1px 0;
	border-style: solid;
	border-color: var(--border-color);
}

h1.copy {
	inherit: .scheme-heading;
	inherit: .scheme-underlined;
}
```

A class can inherit from other classes, or a content item can have multiple classes applied to it. The order in which the styles are applied is determined, like CSS, by the order in which they are defined.

## Inheritance in practice

Apply inherited stylesheets to HTML becomes problematic for text markup like headings.

Here we do using more complicated selectors such as `.cs-section .text h1`.

We define the .text as a "panel" and the h1 tag as a class.

## Default schemes

All content items are assigned a class according to their type. Some standard formatting from the static CSS will be applied, and you can also adjust the defaults (but this is rarely done).

In a simple site, the _title_ type of content section could have the same styling applied to it whenever used. It would, though, usually be better to abstract this styling to a class and inherit it. Typically a _title_ scheme would be inherited by two or three title schemes such as _maintitle_ or _subtitle_.








