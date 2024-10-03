# Image heights

Getting images to fit the height of their containers is one of the biggest problems we face. You should be able to do this setting the `height` to `100%` and `object-fit` to `scale-down`.

This needs the container to have a fixed height of some sort, or the images will cause the layout to expand.

You can, if every element from the body down has a height of 100%, get the image to fit using pure CSS and grid row sizing.  You can't use a `min-height:100%` on the ubercontainer to do this, which makes things very difficult.

Instead, we use use JavaScript to fix the height of the image container and only then show the image.

## Examples

A grid layout has fixed height header and footer and variable content. The content expands so the page fills the screen. Adding an image to the Content will "bust" the grid and push the footer off the screen.

```
>Screen top  ===============
|-------------------------|    |-------------------------|    
|    Header               |    |    Header               |    
|-------------------------|    |-------------------------|    
|        |                |    |        |                |    
| subcol |  Content       |    | subcol | |-----------|  |    
|        |                |    |        | |  Image    |  |    
|-------------------------|    |        | |           |  | 
|    Footer               |    |        | |           |  | 
|-------------------------|    |        | |-----------|  |     
>Screen bottom =============== |-------------------------|    
                               |    Footer               |    
                               |-------------------------|
```

## Solution

### Fixed height of CS

The easiest solution is to apply a fixed height to the content section. This will automatically fit the image according to the object fit property.

The problem is we don't always know the height and usually want it to be whatever the height of the container is according to the page size.

### "heightfix" property

Javascript is used to fix the height of the content section. It works well enough but we're getting FOUCs that need fixing.



### Fill available space

More useful is the functionality to fill the available space.

We define a property "heightfix" on the image. This will enable the following:

1. Set position to absolute and visibility to none
2. Work out size of parent
3. Subtract margin (possibly ignore on fitted images)
4. Set height of image container
5. Set position to static and visibility to visible

### Implementation

See `heightfix.js`. This is applied to all image cs in `clik_onready`. If the `--heightfix` property is true, it applies the logic above. It does the calcs and applies a class to the cs to apply height:100%, width:100% to the frame.
