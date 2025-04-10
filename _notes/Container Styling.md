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

The only complication is for grids, where the containers contain other containers. To avoid the CSS values for grids inheriting, we define them as `@property` values with `inherit=false`.

The problem then is that the values CAN'T be defined on the main container. You can't assign stlying to the container itself and have to use an inner container, but the CSS vars HAVE to be applied to that inner container.

E.g. we would like to do this:

```
#header {
	--grid-mode: columns;
	--grid-template-columns: 40% 60&
}
```

But the grid template columns are applied to an inner container (`.grid):

```
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

According ALL css vars for grids apart from the mode have to be applied to the inner container, e.g.

```
#header {
	--grid-mode: columns;
}

#header .grid {
	--grid-template-columns: 40% 60&
}
```
