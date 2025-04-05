# Var Classes

To ensure that all styling can be applied only through setting simple css variables, we use a mechanism which we call `Var Classes`. As an example, css grids have a property "mode".

This can be set in a style sheet so

```
#mygrid {
	--mode: fixed;
	--grid-columns: 4
}
```

This creates a grid with 4 equal columns. The CSS for this requires the mode class to be applied to the div, e.g.

```
.cs-grid.mode-fixed {
	grid-template-columns: repeat(var(--grid-columns), 1fr);
}
```

As the mode is very likely to change with a viewport, we need to update the class according to the mode setting.

There is a JavaScript library called "varClass" that takes a list of css properties and adds them as classes. The format is ` {varname}-{varvalue}`.

An event is bound to the page resize so the classes will be applied as the viewport changes.

Each type of content section has a set of var classes to apply, and they should be applied by the unique class for the cs, e.g.

```
$(".cs-grid").varClass({name:"mode"});
```

The "name" argument in production will come from the [](saved_settings.md), e.g. `clik.settings.varclasses["grid"]`.

