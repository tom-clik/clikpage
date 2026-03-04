# Grid Layouts

We think of grids as having a "mode". This is set by a var `--grid-mode` and determines the behaviour. 

## Modes

The grid mode is applied with `--grid-mode`. To turn off a grid use `none`. 

### Content fit (fit)

This is default and the mode you want if you don't already know. With a minimum width set for the content items, this will add as many items as possible per row and stretch any items to ensure no gap is left.

The only setting you usually need is `--grid-width` which is the minimum width. Note that for fit and fill the `--grid-max-width` rarely does what you want it to do. It only really works when left to its default value of 1fr.

NB The mode can be omitted as it's the default for `.cs-grid`.

### Content fill (fill)

Sort of like fit but will create empty cells to fill up the space if the grid is on one line. Use if you don't want the cells stretched to crazy lengths.

### Fixed columns (fixed)

The number of columns in the grid is fixed. The columns are all equal. Set the number of columns with `--grid-columns`.

### Set column widths (columns)

Explicitly set the grid template columns in `--grid-template-columns`. Useful for having one column stretch. YOu can also set `grid-template-rows` if you like. 

### Set column rows (rows)

A shortcut to having just one column, essentially functions like columns.

### Named positions (named)

Supply template positions in  `--grid-template-areas`. Column and row sizes can be set in `--grid-template-columns` and 
`--grid-template-rows`.

### Fixed width (fixedwidth)

Little used setting where the cells have a fixed width and as many as possible fit the grid. Use `fill` or `fit` in preference. Set the width with `--grid-width`.

### Flex Layouts (flex)

Uses flex box in preference to grid modes. Set direction with `--flex-direction` (` 'row | row-reverse | column | column-reverse'`) and whether to expand with  `--flex-stretch`. Alignment uses the normal flex properties which need not a little explanation.

