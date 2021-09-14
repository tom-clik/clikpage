# Fonts

Like colors, fonts are never applied directly. We reference only the variable name, allowing for easy editing.

    <fonts>
        <font name="titlefont" value="Lato" />
        <font name="bodyfont" value="Open Sans" />
    </fonts>

Like colors, these are now exported to the css as variables, e.g.

    var(--titlefont);









