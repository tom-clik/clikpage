# Stylesheets

## Colors

Colors like all properties are abstracted and given a name. Colors can only be applied in the system via this name.

You should give them a title to explain more fully what they do.

```
<colors>
	<color name="textcolor" title="Main text color" value="#333333" />
```

### Derived colors

When defining a template you may want to define more colors than you need. These can be given a value of another color.

```
<color name="introtextcolor" title="Color of text in intro paras" value="--textcolor" />
```

### Color schemes

Color schemes will just append to the main stylesheet. In this case the titles can be omitted.

## Font Familes

Colors like all properties are abstracted and given a name. Fonts can only be applied in the system via this name.

The font faces themselves need defining in the static CSS files. The font variables then reference the defined font families.

```
<fonts>
	<bodyfont title="Body font" family="Open Sans" />
	<titlefont  title="Title font" family="Lato" />
	<subtitlefont  title="Sub Title font" family="--titlefont" description="Used by sub titles" />
</fonts>
```

Like colors, it's permissible to defined font families that derive from other fonts.

### Editing options

Lists of availble options for weight, style, variant, and stretch can be supplied. You should only define these if they are specifically available in the font and you have defined them in the font-face definition. If you don't know what this means don't use them.

```
styles=normal,italic,oblique
weights=100,200,300,normal,500,600,bold,800,900
variants=normal,small-caps
stretch=ultra-condensed,extra-condensed,condensed,semi-condensed,normal,semi-expanded,expanded,extra-expanded,ultra-expanded
```

If a weight or style isn't available, typically "bold" for title fonts, you should define your font with just the available options e.g. `styles='normal'`.

Note these values are just for the editing system. If a bold variant is not available, as a failsafe you should define it to be the same font face as the normal weight otherwise the browser might try to render a bold version of your expensive and hand crafted fonts.

## Media Queries

Media queries are defined and referenced by keyword. They can have a minimum with (min), maximum width (max), and specified media.

A default of "main" is always added and applies to all sizes. To apply styles to only the full size screen you would need to specify a medium with an appropriate min and max.

```
<media>
	<medium name="max" min="1200" title="Max" description="Extended screen only" />
	<medium name="mid" max="800" title="Mid"  description="Medium width for tablets"/>
	<medium name="mobile" max="600" title="Mobile" description="mobile" />
	<medium name="print" media="print" title="Print" description="Print only" />
</media>
```

