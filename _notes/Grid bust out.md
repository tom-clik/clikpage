# Grid bust out

By default a grid cell can't be smaller than its content. This normally doesn't matter but when we want to contain images within a cell and "fit" them, it becomes almost unworkable.

Some touted solutions on the web have us setting the minimum sizes to zero. Overflow "hidden" is also supposed to do it.

```
.cs-image {
	...
	overflow: hidden;
	min-width: 0;
	min-height: 0;
}
```

Togther with setting column/row definitions with `minmax(0,1fr)` we can get close to the expected behaviour, but the end rendering is buggy in the main Webkit render engine.

To contain an image to a height, currently the image content section has to have the height set on it. See [](Image heights.md)

