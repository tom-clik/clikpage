# Grid styling

Currently grids are styles using a specific function in the settings object. This is all a bit strange. The function in this object seems to use some legacy hard wired values and some vars from `grids.css`.

Need to fix it all so it only uses vars BUT we will still need to write out the values every time as we don't want any inheritance. 

We can't turn off inheritance using properties because that breaks out pattern of applying them to the main div.

E.g. say we set a var of `--flex-stretch:1`. We want to apply this to the main grid, e.g.

```
#photogrid {
	--flex-stretch:1
}
```

BUT this is applied in the CSS as 

```
.cs-grid > * {
	height: var(--grid-max-height);
	flex-grow: var(--flex-stretch);
}
```

turning off inheritance will break this.

With inheritance, unlike content sections, where there is no nested structure to inherit, grids can be inside other grids and this plays havoc.

Accordingly, we have to write out every grid property every time we do a grid.





