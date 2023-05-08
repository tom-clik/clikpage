# Stylesheet Generation

Styling is made up of the standard (static) stylesheets for each content section and the individual styling for each element.

Styling does not cascade, and all styles will be written out for each content section. This often isn't a problem, especially if you have designed your templates efficiently.

If it is, you can operate in a "schemes only" mode. No individual styling is then allowed. However, if there is an issue you have to do a classic CSS debug exercise to ascertain which stylesheet is causing the issue. To avoid this you can try and keep it to one stylesheet per content section where you can. Remember they can inherit.

## Static files

You can either use the complete set of static files or else you can obtain the list of files required by iterating over the CS and obtaining the static CSS for each one, which is more trouble than it is worth. See [](#static_files) for details of how the packages are put together.

In preview mode, all static files are included separately, allowing for debugging if necessary.

## Dynamic css

Dynamic css is generated according to the styling for each content section and container. Much of the styling is applied as simple css vars, but some is more complicated, and requires logic contained within the components.

Within the content section definitions, all available style settings are defined in "styledefs". Those that require logic and aren't simple vars are also added to "settings".

Each content section type also defines "panels", which can be styled using standard css styling such as font, border, margin, etc.

Some also define states such as hover, disabled, highlight. 

In a clik stylesheet, the states and panels are easliy applied referring only to the keyword. For instance, for a listing of articles, the stylesheet would look like this.

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





