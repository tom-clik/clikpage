# Stylesheet Generation

Styling is made up of the standard (static) stylesheets for each content section and the individual styling for each element.

Styling does not cascade, and if you apply styling via multiple schemes they will be written out for each content section. This often isn't a problem, especially if you have designed your templates efficiently.

If it is, you can operate in a "schemes only" mode. This allows for only one scheme per cs, which has to inherit any other schemes you wish to apply. No individual styling is then allowed. The effort of maintaining this is rarely worth it, and you should always look to reduce the number of content sections on your site before adopting its use.

## Static files

You can either use the complete set of static files or else you can obtain the list of files required by iterating over the CS and obtaining the static CSS for each one, which is more trouble than it is worth. See [](#static_files) for details of how the packages are put together.

In preview mode, all static files are included separately, allowing for debugging if necessary.

## Dynamic css

Dynamic css is generated according to the styling for each content section and container. Much of the styling is applied as simple css vars, but some is more complicated, and requires logic contained within the components.

Within the content section definitions, all available style settings are defined in "styldefs". Those that require logic and aren't simple vars are also added to "settings".

Each content section type also defines "panels", which can be styled using standard css styling such as font, border, margin, etc.

Some also define states such as hover, disabled, highlight. 

In a clik stylesheet, the states and panels are easliy applied referring only to the keyword. For instance, for a listing of articles, the stylesheet would look like this[^dream1].

```
.scheme-listing {
	item {
		border-color: light-border;
		link-color: accent;
		hover {
			link-color: linkhilite;
		}
		title {
			font-size:2em;
		}
	}
}
```

[^dream1]: Of course at the minute they are XML. But they will look like this one day.



