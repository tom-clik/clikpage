# Images

File name of image is unique key for site. Can use pseudo paths if you need to e.g. `directory/myimage.jpg`

Available sizes of image depend on the "image settings". These are stored with suffixes that are then reserved and can't be used as part of the file name, e.g. `_thumb`, `_crop`, and `_full`. 

The settings can be set for a site as a whole or for a data type.

## Image settings

Settings consist of an array of different size options. Each option will generate a separate image that is referenced by the "suffix"[^image_suffix].

[^image_suffix]: as there is no suffix for the main image, the variable to use for substitution is `image_<suffix>` e.g `image_thumb`.

| Property     | Description
|--------------|------------------------
| name*        | Name of the size setting.     
| description  | A description of the size setting.              
| suffix       | Suffix for this size setting. Only one per set can be blank.        
| max_width    | Maximum width of image           
| max_height   | Maximum height of image            
| crop         | Crop the image to fit the sizes      
| fill         | Fill space left by cropping with a color      
| fill_color   | Color for fill            

### Cropping

By default the image will be resized so it all fits within the sizes. This means that the image will retain its original aspect ratio.

An alternative is to crop the image so all images are the same size. Some of the image will be lost. To best preserve the content of the image, cropping rectangles can be stored with the image to let the system know how best to crop the image.

### Filling

To create images of the same size while preserving their content, you can fill the space with a color. This is usually done when producing images for fast viewing in large galleries or admin suites. Having images all of the same size allows certain page layouts to render much faster.

