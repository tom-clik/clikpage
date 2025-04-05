# Grid Layouts

We think of grids as having a "mode". To apply these, ensure "--mode" is set and the javascript is run to apply the mode class or else explicity set the class with e.g. `class="cs-grid mode-cols"`. Explicitly setting classes can't work for different modes in different viewports. Either get the JS running or see the CSS below to do it manually, which beats the point of using this script.

There is only one "varClass[^varclasses]": `mode`. The javascript needed is 

[^varclasses]: See [](varclasses.md)

```
$(".cs-grid").varClass({name:"mode"});
```



### Content fit (mode-fit)

This is default and the mode you want if you don't already know. With a minimum width set for the content items, this will add as many items as possible per row and stretch any items to ensure no gap is left.

The only setting you usually need is `--grid-width` which is the minimum width. Note that for fot and fill the `--grid-max-width` rarely does what you want it to do. It only really works when left to its default value of 1fr.

NB The mode can be omitted as it's the default for `.cs-grid`.

### Content fill (mode-fill)

Sort of like fit but will create empty cells to fill up the space if they would fit. Rarely used.

### Fixed columns (mode-fixed)

The number of columns in the grid is fixed. The columns are all equal. Set the columns with `--grid-columns`.

### Set column widths (mode-columns)

Explicitly set the grid template columns in `--grid-template-columns`. Useful for having one column stretch.

### Set column rows (mode-rows)

Explicitly set the grid template rows in `--grid-template-rows`. Useful for having one row stretch.

### Named positions (mode-named)

Supply template positions in  `--grid-template-areas`.

### Fixed width (mode-fixedwidth)

Little used setting where the cells have a fixed width and as many as possible fit the grid. Use `fill` in preference although honestly you're usually just better off with `fit`.

## Other grid layouts

If you want to set your own you could set `mode` to none or basically you'd just be better off not using this.

## Flex Layouts (mode-flex)

Flex layouts are simpler. Most stretch properties translate with an equalivant var of the same name.

NB flex-grow is a var --flex-stretch (??)
