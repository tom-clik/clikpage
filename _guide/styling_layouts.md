# Styling Layouts { #styling-layouts}

The "structure" of a page is defined using a layout. These define the available "containers" on a page and the content items that go into them.

An important distinction between the styling of layouts and the styling of other content items is that layouts can utilise multiple classes for styling and class attributes are left in the HTML.

A layouts can (and should) inherit from another layout, and the body class will be assigned something like

    body class='layout-standard layout-article'

## Defining layouts

Each layout is an HTML file. A title should be supplied to name the template, and meta information can allows be added.

Each `div` tag is a container. They must have an ID tag, and optional title and data tags if required. All tags except id and class are removed from the container before export.

```html
<!DOCTYPE html>
<html>
<head>
    <title>Basic layout</title>
    <meta name="description" content="A test layout">
    <meta name="author" content="Tom peer">
</head>

<body>

    <div id="ubercontainer">

        <div id="header" class="scheme-spanning">
            <content type="title" id="sitetitle">
                {{site.title}}  
            </content>
            <content id="topmenu" type="menu"></content>
        </div>
```
{data-caption="A typical layout"}

### Content items

Content items are added using a `<content>` tag. See [](content.md) for details.

### Container classes

Containers can be assigned classes in the layouts. The styling for these can be added to the styling and will apply in the normal CSS fashion. Typically this would be used to apply a width to a number of containers for a "spanning" site.

### Layout inheritance

Layouts can inherit from other layouts. This is specified with the `data-extends` attribute of the body. This can be relative to site root or a URI.

```html
<body data-extends="layouts/layout1">
```

Containers in the root of the layout will replace containers of the same ID of the base layout.

E.g.

```html
<body data-extends="layouts/layout1">
        
    <div id="maincol">
        ...
    </div>
        
    <div id="footer">
        <content id="copyright">{{site.meta.copyright}}</content>
    </div>
```

will replace the whole `maincol` and `footer` tags in layout1. This mechanism shouldn't be used to update content. It's to change the structure of the page.

Note that by default empty containers are removed from the page, so your "base" containers can have unused containers that are replaced by derived containers.

!!! note
    It's good practice to create abstract layouts just for the purposes of inheritance and ensure all your layouts inherit from this.

## Styling Layouts

In the stylesheet, a section `layouts` contains subkeys for each layout. These should be defined in the order of inheritance.

<!--

Note we hope to make some of the styling a little easier by getting information from the layout pages.

-->

### Styling in the main stylesheet

It's acceptable and common practice to add "soft" styling such as colors to containers in the main stylesheet just like other content sections. This keeps the structure and the soft styling separate and allows for easy template reuse.

## Layouts and media queries

Layouts can contain keys for the media queries defined in the stylesheet.

