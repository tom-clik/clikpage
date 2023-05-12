# Image heights

Getting images to fit the height of their containers is one of the biggest problems we face.

Unless at some point a container has a fixed height, the images will cause the layout to expand.

You can, if every element from the body down has a height of 100%, get the image to fit using pure CSS. You can set the height to 100% and object fit to "scale-down". You can't use a min-height:100% on the ubercontainer to do this, which makes things very difficult.

Without the image "busting" the grid, use can use grids with an expandable ubercontainer to create a cell of the correct size. We can then use JavaScript to fix the height of the image element. The frame and the image then both need height 100% and this will work.

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

We define a property "fixheight" on the image. This will enable the following:

1. Set position to absolute and visibility to none
2. Work out size of parent
3. Subtract margin (possibly ignore on fitted images)
4. Set height of image
5. Set position to static and visibility to visible

We will need to add a resize method to the page's on throttled resize handler.
