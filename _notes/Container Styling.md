# Container Styling

The Clik component system uses container queries for most of its CSS queries.

This allows us to apply styling based on a CSS var rather than classes in the HTML. For example, grids use a property called `grid-mode`.

By setting the container name to `grid` when can than apply styling so:

```
@container grid ( style(--grid-mode:none) ) {
	.grid {
		display: block;
	}
}
```

Using this mechanism we are able to apply all our styling without CSS classes which might need to change according to media queries. E.g. to turn off a grid in mobile, we just do

```
@media ...  {
	#footer {
		--grid-mode: none;
	}
}
```

Where a single setting needs to update other settings, we can now set them using the same mechanism

```
@container widget ( style(--setting:fancy) ) {
	.inner {
		--subsetting:value;
		--othersetting:value;
	}
}
```

Once complication is that the styling CAN'T be defined on the main container. All content sections have a "container" div to which the styling is applied and an inner div which uses the set values. E.g., a grid looks like


```html
<div class='cs-grid' id='mygrid'>
	<div class='grid'>...</div>
</div>
```

While the user stylesheet would like this:

```css
#mygrid {
	--grid-mode: columns;
	--grid-template-columns: 40% 60%
}
```

The static css applies the styling using the inner container. 

```css
.cs-grid {
	container-name:grid;
}

.grid {
	display:grid;
	grid-gap:var(--grid-gap);
	flex-direction: var(--flex-direction);
	align-content: var(--align-content);
	align-items: var(--align-items);
	justify-content: var(--justify-content);
	flex-wrap: var(--flex-wrap);
	grid-template-columns: var(--grid-template-columns);
	grid-template-rows: var(--grid-template-rows);
}
```

Note this can cause problems for grids, which can be nested, causing the values to inherti when we don't want them to. We can't turn off inhertiance because then we couldn't define the vars on the "container" div. For any grids that are nested, we therefore need to set the value explicitly even when they're the default.
