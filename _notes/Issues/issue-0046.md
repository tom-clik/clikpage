# Image Grid Pop-ups

Image grid pop-ups required the image data to navigate previous and next records. The plug in itself requires the full data array, but we want to use our photogrid wrapper to generate this on the fly from an image set and the complete site data.

This required the save data functionality that had previously been missing. There is now a function `savedata` in `site.cfc` that saves all the data to JavaScript objects in `site.data.images` and `site.data.articles`.

We then pass the data set as an option to the photogrid plug in and this generates a full array using `clik.getImages()` in the clik utility functions.



