# CSS parsing

All styling now is done in CSS like format. It can be applied as a stylesheet (recommended for schemes), as layout styling, or inline for the Content sections.

## Parser

The parser works very simply by using tokens to convert the CSS into a struct keyed by element.

Note that the system is agnostic as to whether you are applying to an element or a scheme, e.g.

```
.scheme-test {}
body {}
#mycontent {}
```

Ends up as a struct

```
{
	scheme-test = {},
	body = {},
	mycontent = {}
}
```

Note that all styles in the struct end up in a medium, if none is specified, they will end up in "main".

## General Stylesheet

In a settings defintion file, you can specify stylesheets to parse:

```
<link rel="stylesheet" href="sample_schemes.css" />
```

These can be used for global styles and schemes. You can use them to apply

## Layout styles

Layout styles are applied to the layout file either inline or through a linked stylesheet. Note it's fine to put them inline, they all end up compiled to external files.

## Content styles

Styles can be applied inline where the content is defined in a `<style>` tag. Like layout styles, this is actually recommended unless the content section is a "library" element, in which case they can be defined in a general stylesheet.

### Classes

Classes can applied to a content item and styles applied via that "scheme". When you do this, prefer to use a class like `scheme-schemename`. The actual classes are not used in the end product. These are usually put into external files like the general stylesheet.


