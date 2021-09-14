# Colors

Another big failing of CSS before variables was that values like colors had to be repeated where used. Color values should never be applied directly, only defined colors names should be used.

Sample color definition:

    <colors>
        <color name="textcolor" title="Main text color" value="#333333">
            <description></description>
        </color>
    </colors>

Whenever this color is applied elsewhere in the stylesheet, it is referenced as `textcolor`.

In the CSS, it appears as `var(--textcolor);`.

## Color Abstractions

When preparing Clikpage templates for re-use or sale, colors can be abstracted even when they are the same as another color. This is typically done to create color schemes, e.g.

    <colors>
        <color name="headercolor" title="Header text color" value="#ffffff">
            <description>The color of text in the header</description>
        </color>
        <color name="topmenucolor" title="Header menu color" inherit="headercolor">
            <description>The color of the menu in the header</description>
        </color>
    </colors>

