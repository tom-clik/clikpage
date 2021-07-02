# Layouts

Styling can be applied to a layout as a whole. These are applied via a class attached to the body, e.g.

    body class='layout-standard'

All entries in the styling are exported as CSS variables. Layout styling is all static and only the variables will change.

The variables are exported so

    body.layout-standard {
        --sitewidth: 1060px;
    }

Any more advanced styling would required using the standard styling applied to the elements themselves.

The purpose of this is that layout CSS files are usually developed outside of the Clikpage framework and CSS variables offer the quickest way to achieve modularity and integration.

## Layouts and media queries

There remains a killer weakness in CSS in that you can't use CSS variables to define media queries. Every media query has to include the break point value, contrary to the DRY principle. 

This leaves two main alternatives, hardwire every media query, which rather defeats the purpose of Clikpage, or use separate files for your styling.

When developing your CSS, use the media query in the link tag:

    <link rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-width: 800px)">

There is a third alternative which is to use a Clikpage script to process CSS files, allowing you to simulate the way media queries should have worked, e.g.

    @media mobile {
        ...
    }

    @media mid {
        ...
    }

The utility will then replace "mobile" and "mid" with the media query defined in your XML stylesheet. For details see `scriptViewer.cfm` in the sample app.


















