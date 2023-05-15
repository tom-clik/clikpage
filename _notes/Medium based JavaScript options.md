# Medium based JavaScript options

Many behaviours depend on the current screen size (medium). If these are controlled by JavaScript, we need to ensure the settings can be varied according to the minimum.

## Example

To ensure images fit within a container, we use a script, `image-height-fix.js`. we may want this behaviour in full screen mode, but not in mobile.

We need to ensure not only that the initial state is correct but that resizing also triggers correct rebuilding.

## Use of custom vars

The CSS mechanism can be used to store custom vars according to media. On loading a plugin, properties can be read from the css for the DOM element and these will be vary according to the media.

```css
#slideshow {
	--transition-time:0.5;
}
```

These are read easily with e.g. 

```javascriptXXX
$("#slideshow").css("--transition-time");
```

As this operation actually uses text parsing, it had in the past been too slow. In a modern browser JavaScript are now negligible.

