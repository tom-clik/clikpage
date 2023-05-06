# Image heights

## Note -- seems to have been solved. See testing/css/imageHeights.cfm

Getting images to fit the height of their containers is one of the biggest problems we face.

Unless at some point a container has a fixed height, the images will cause the layout to expand. There is no way around this in pure CSS.

If we want to use Grid layouts to size the page (best) we therefore have to use JavaScript to fix the height of the image's container to ensure it fits.

## Examples

A grid layout has fixed header and footer and variable content. The content expands so the page fills the screen. Adding an image to the Content will force the content to expand even if the height is set to 100%.

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

To solve this, we have to use JavaScript to get the height of the content and fix the height of a container around the image.

## Solution

If the object-fit property is set on an image, we will need to set the size of the container.

1. Set position to absolute and visibility to none
2. Work out size of parent
3. Subtract margin (possibly ignore on fitted images)
4. Set height of image
5. Set position to static and visibility to visible

We will need to add a resize method to the page's on throttled resize handler.
