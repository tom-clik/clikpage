# Defining a Layout

Layouts are defined as HTML pages. They consist of meta information, containers, and content items. You can also add styling to a layout, for containers and content items. This isn't necessarily poor practice as the CSS will end up as external files when compiled, but you may prefer to keep the styling separate.

## Meta information

The Title, description, and any other meta information can be defined in the template `head` section, just as per an HTML page. A typical entry might look like this.

```
	<title>Basic layout</title>
	<meta name="description" content="Basic three column layout">
	<meta name="author" content="Tom peer">
```

## Containers

The layout of your page is defined using containers, which are just `<div>` tags. Some understanding of flow layout is required to effectively define and use them.

## Content items

Within the containers, content items are defined using `<content> tags`. See [](#content_sections) for more information.



