/* File auto generated by saveSettingsData */
clik_settings = {"item":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"htop":{"default":"false","inherit":1,"type":"boolean","description":"Put headline before image"},"image-align":{"default":"center","inherit":1,"type":"halign"},"flow":{"default":false,"inherit":1,"type":"boolean"},"image-gap":{"default":"10px","type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances"},"image-width":{"default":"40%","type":"dimension"},"titletag":{"default":"h3","options":[{"value":"h1"},{"value":"h2"},{"value":"h3"},{"value":"h4"},{"value":"h5"},{"value":"h6"}],"type":"list"},"showtitle":{"default":"block","type":"displayblock"},"showimage":{"default":"block","type":"displayblock"},"showcaption":{"default":"none","type":"displayblock"}},"panels":[{"selector":" .title","panel":"title","name":"title"},{"selector":" .imageWrap","panel":"image","name":"image"},{"selector":" .textWrap","panel":"text","name":"text"}]},"text":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{},"panels":[]},"form":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"field-border-color":{"type":"color"},"form-stripe-background-color":{"type":"color"},"form-label-width":{"type":"dimension"},"form-label-gap":{"type":"dimension"},"form-row-gap":{"type":"dimension"},"field-padding":{"type":"dimensionlist"},"input-padding":{"type":"dimensionlist"},"form-width":{"type":"dimension"},"field-checkbox-width":{"type":"dimension"},"field-border-width":{"type":"dimension"},"field-border-style":{"type":"text"},"field-background-color":{"type":"color"},"form-font":{"type":"text"},"form-color":{"type":"color"}},"panels":[]},"grid":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"grid-mode":{"default":"none","options":[{"name":"None","value":"none","description":"Don't use a grid. Use this setting to turn off a grid in smaller screen sizes."},{"name":"Auto fit","value":"auto","description":"Fit as many items as possible into the grid according to the minimum column size."},{"name":"Fixed width","value":"fixedwidth","description":"A legacy mode in which all columns have the same width"},{"name":"Fixed columns","value":"fixedcols","description":"A grid with a fixed number of columns. Set either a number in 'Columns' or a width definition e.g. 20% auto 30% in 'Template columns'"},{"name":"Named positions","value":"templateareas","description":"An advanced mode in which you specify the specific order of the content items."},{"name":"Flex","value":"flex","description":"The items in the grid will be as wide/high as their content"}],"inherit":1,"name":"Grid mode","type":"list","description":"Select the way your grid is laid out"},"grid-fit":{"default":"auto-fit","options":[{"name":"Fit","value":"auto-fit","description":""},{"name":"Fill","value":"auto-fill","description":""}],"dependson":"grid-mode","dependvalue":"auto","name":"Auto fill mode","type":"list","description":"How an auto grid is filled up. Use `Fit` unless you know you want fill."},"grid-width":{"default":"180px","dependson":"grid-mode","dependvalue":["auto","fixedwidth"],"name":"Item width","type":"dimension","description":"Minimum width of columns for an auto grid or specific width for a fixed width grid."},"grid-max-width":{"default":"1fr","hidden":1,"name":"max width","type":"dimension","description":"","note":"Not sure this should be exposed"},"grid-columns":{"default":"2","inherit":1,"dependson":"grid-mode","dependvalue":"fixedcols","name":"Columns","type":"integer","description":"Number of columns for a fixed column grid (only used if Template columns is not specified"},"grid-gap":{"default":0,"name":"Gap","type":"dimension","description":"Gap between grid items"},"grid-template-columns":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":["templateareas","fixedcols"],"name":"Template columns","type":"text","description":"Column sizes when using fixed columns or named template areas"},"grid-template-rows":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":"templateareas","name":"Template rows","type":"dimensionlist","description":"Row sizes when using a named items mode"},"grid-template-areas":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":"templateareas","name":"Template areas","type":"text","description":""},"justify-content":{"options":[{"name":"Start","value":"flex-start","description":""},{"name":"Center","value":"center","description":""},{"name":"End","value":"flex-end","description":""},{"name":"Space around","value":"space-around","description":""},{"name":"Space evenly","value":"space-evenly","description":""},{"name":"Space betweem","value":"space-between","description":""}],"name":"Alignment","type":"list","description":"Orientation in the same axis to the grid direction. This usually means horiztonal."},"align-items":{"options":[{"name":"Start","value":"flex-start","description":""},{"name":"Center","value":"center","description":""},{"name":"End","value":"flex-end","description":""}],"name":"Cross align","type":"list","description":"Orientation in the opposite axis to the grid direction. This usually means vertical."},"flex-direction":{"default":"row","options":[{"name":"Row","value":"row","description":""},{"name":"Row reverse","value":"row-reverse","description":""},{"name":"Column","value":"column","description":""},{"name":"Column reverse","value":"column-reverse","description":""}],"dependson":"grid-mode","dependvalue":"flex","name":"Flexible grid direction","type":"list","description":"The direction in which a flexible grid is shown"},"flex-stretch":{"default":"0","dependson":"grid-mode","dependvalue":"flex","name":"Flex stretch","type":"boolean","description":"Stretch out the items to fill the available space"},"flex-wrap":{"default":"wrap","options":[{"name":"Wrap","value":"wrap","description":""},{"name":"No Wrap","value":"nowrap","description":""},{"name":"Wrap reverse","value":"wrap-reverse","description":""}],"dependson":"grid-mode","dependvalue":"flex","name":"Flex wrap","type":"list","description":"Wrap items onto multiple lines"}},"panels":[{"selector":" > *","panel":"item","name":"Item"},{"selector":" .caption","panel":"caption","name":"Caption"}]},"menu":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"The hover state for menu items"},{"selector":".hi","name":"Hilighted","state":"hi","description":"The state for the currently selected menu item"}],"styleDefs":{"orientation":{"default":"horizontal","inherit":true,"options":[{"name":"Horizontal","value":"horizontal"},{"name":"Vertical","value":"vertical"}],"name":"Orientation","type":"list","description":"Align the menu horizontally or vertically."},"link-color":{"name":"Link colour","type":"color","description":"Colour of the menu items"},"menu-gap":{"name":"Gap","type":"dimension","description":"Gap between menu items"},"menu-text-align":{"name":"Text align","type":"halign","description":"Alignment of the menu items"},"menu-anim-time":{"default":"0.3s","name":"Menu animation time","type":"dimension","description":""},"menu-label-display":{"default":"block","name":"Display label","type":"displayblock","description":"Show or hide the text part of the menu items"},"menu-icon-display":{"default":"none","name":"Display icon","type":"displayblock","description":"Show or hide the icon in the menu item. You will need to define the icons  (how TBC)"},"border-type":{"default":"none","options":[{"name":"Normal","value":"normal"},{"name":"Dividers","value":"dividers"},{"name":"Boxes","value":"boxes"}],"inherit":true,"name":"Border type","type":"list","description":""},"flex":{"default":false,"inherit":true,"name":"Flex mode","type":"boolean","description":"Flexible grid that adjusts to the size of the items"},"stretch":{"default":false,"inherit":true,"name":"Stretch","type":"boolean","description":"Stretch out the menu in flex mode. Equal padding will be added to the items"},"flex-wrap":{"default":"wrap","options":[{"name":"Wrap","value":"wrap","description":""},{"name":"No Wrap","value":"nowrap","description":""},{"name":"Wrap reverse","value":"wrap-reverse","description":""}],"dependson":"flex","dependvalue":true,"name":"Flex wrap","type":"list","description":"Wrap items onto multiple lines"},"align":{"default":"left","inherit":true,"name":"Menu alignment","type":"halign","description":"Which direction to align the menu. Only applies if you have set a width or are using Flex mode without stretch"},"menu-border-color":{"default":"--link-color","name":"Border colour","type":"color","description":""},"menu-background":{"default":"transparent","name":"Background","type":"color","description":""},"menu-item-padding":{"default":"0 8px","name":"","type":"dimensionlist","description":""},"menu-item-border":{"default":"0","name":"Border with","type":"dimensionlist","description":""},"icon-width":{"default":"32px","name":"Width of menu icons","type":"dimension","description":""},"icon-height":{"default":"32px","name":"Height of menu icons","type":"dimension","description":""},"menu-icon-gap":{"default":"8px","name":"Gape between icon and text","type":"dimension","description":""},"menu-openicon-width":{"default":"16px","name":"Open icon width","type":"dimension","description":""},"menu-openicon-height":{"default":"16px","name":"Open icon height","type":"dimension","description":""},"menu-openicon-adjust":{"default":"-4px","name":"Menu open icon adjustment","type":"dimension","description":""}},"panels":[{"selector":" li a","name":"Item","panel":"item"},{"selector":" .submenu li a","name":"Sub menu Item","panel":"subitem"},{"selector":" > li:first-of-type a","name":"First","panel":"first"},{"selector":" > li:last-of-type a","name":"Last","panel":"last"}]},"button":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"The hover state for buttons"}],"styleDefs":{"shape":{"name":"Shape","type":"shape"},"button-direction":{"default":"row","options":[{"display":"Right","value":"row"},{"display":"Left","value":"row-reverse"}],"name":"Label alignment","type":"list","description":"Show the label on the left or right of the button"},"button-align":{"default":"center","options":[{"name":"Label side","value":"flex-end"},{"name":"Center","value":"center"},{"name":"Icon side","value":"flex-start"}],"name":"Button alignment","type":"list","description":"Align button icon and text. Note this is incompatible with Stretch"},"stretch":{"default":0,"name":"Stretch text","type":"flexgrow","description":"Stretch the text label to fill the space"},"label-align":{"default":"0","name":"Align text","type":"halign","description":"In stretch mode, align the text within the space"},"label-display":{"default":"block","options":[{"display":"Yes","value":"block"},{"display":"No","value":"none"}],"name":"Show text label","type":"list"},"icon-display":{"default":"block","options":[{"display":"Yes","value":"block"},{"display":"No","value":"none"}],"name":"Show icon","type":"list"},"label-gap":{"Name":"Label gap","type":"dimension","description":"The gap between the label and the icon"},"link-color":{"name":"Color","type":"color"},"icon-width":{"type":"dimension"},"icon-height":{"type":"dimension"},"auto":{"default":false,"name":"Auto open target","type":"boolean","description":"function WIP. Calls open method on target specified in link."}},"panels":[{"selector":" label","panel":"label","name":"label"},{"selector":" .icon","panel":"icon","name":"icon"}]},"image":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"object-fit":{"default":"scale-down","options":[{"display":"Scale down","value":"scale-down","description":"Reduce the image to fit while preserving its ratio"},{"display":"Cover","value":"cover","description":"Fit as much of the image as possible while preserving its ratio. This may result in cropping."},{"display":"Stretch","value":"fill","description":"Stretch the image to fit the available space"},{"display":"None","value":"none","description":"The image is not resized"}],"name":"Image fit","type":"list","description":"How to fit the image to the available space"},"object-position-x":{"default":"center","type":"halign"},"object-position-y":{"default":"center","type":"valign"},"heightfix":{"default":false,"name":"Fit to height","type":"boolean","description":"Ensure the image fits into the height available. Without this, the container will expand"}},"panels":[{"selector":" img","panel":"image","name":"image"},{"selector":" figure","panel":"frame","name":"frame"},{"selector":" figcaption","panel":"caption","name":"Caption"}]},"panel":{"styleDefs":{"padding":{"name":"Padding","type":"dimensionlist","description":"Space between the edge of the container and the contents"},"margin":{"name":"Margin","type":"dimensionlist","description":"Space around a container. Use Passing in preference."},"border":{"name":"Border","type":"border","description":"The style, width, and color of the border."},"color":{"name":"Text color","type":"color"},"show":{"name":"Show","type":"boolean"},"link-color":{"name":"Link color","type":"color"},"position":{"name":"position","type":"position","description":""},"float":{"name":"float","type":"float","description":""},"float-margin":{"name":"Float margin","type":"dimension","description":"A simple single value to apply margin to the outside of a float"},"background":{"name":"Background","type":"background","description":""},"width":{"name":"Width","type":"dimension","description":""},"min-width":{"name":"Min Width","type":"dimension","description":""},"max-width":{"name":"Max Width","type":"dimension","description":""},"height":{"name":"Height","type":"dimension","description":""},"min-height":{"name":"Min height","type":"dimension","description":""},"max-height":{"name":"Max height","type":"dimension","description":""},"opacity":{"name":"Opacity","type":"percent","description":""},"z-index":{"name":"Z-Index","type":"numeric","description":""},"overflow":{"name":"Overflow","type":"overflow","description":""},"overflow-x":{"name":"Overflow (horizontal)","type":"overflow","description":""},"overflow-y":{"name":"Overflow (Vertical)","type":"overflow","description":""},"box-shadow":{"name":"Shadow","type":"text","description":""},"transform":{"name":"Transform","type":"text","description":"CSS transform"},"transition":{"name":"Transition","type":"text","description":"CSS transition"},"align":{"name":"Align","type":"halign","description":"Align can only be used when a width is set on a container. A better way to align items is to put them into a flexible grid and set the grid align contents property"}}},"imagegrid":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"grid-mode":{"default":"none","options":[{"name":"None","value":"none","description":"Don't use a grid. Use this setting to turn off a grid in smaller screen sizes."},{"name":"Auto fit","value":"auto","description":"Fit as many items as possible into the grid according to the minimum column size."},{"name":"Fixed width","value":"fixedwidth","description":"A legacy mode in which all columns have the same width"},{"name":"Fixed columns","value":"fixedcols","description":"A grid with a fixed number of columns. Set either a number in 'Columns' or a width definition e.g. 20% auto 30% in 'Template columns'"}],"inherit":1,"name":"Grid mode","type":"list","description":"Select the way your grid is laid out"},"grid-fit":{"default":"auto-fit","options":[{"name":"Fit","value":"auto-fit","description":""},{"name":"Fill","value":"auto-fill","description":""}],"dependson":"grid-mode","dependvalue":"auto","name":"Auto fill mode","type":"list","description":"How an auto grid is filled up. Use `Fit` unless you know you want fill."},"grid-width":{"default":"180px","dependson":"grid-mode","dependvalue":["auto","fixedwidth"],"name":"Item width","type":"dimension","description":"Minimum width of columns for an auto grid or specific width for a fixed width grid."},"grid-max-width":{"default":"1fr","hidden":1,"name":"max width","type":"dimension","description":"","note":"Not sure this should be exposed"},"grid-columns":{"default":"2","inherit":1,"dependson":"grid-mode","dependvalue":"fixedcols","name":"Columns","type":"integer","description":"Number of columns for a fixed column grid (only used if Template columns is not specified"},"grid-gap":{"default":0,"name":"Gap","type":"dimension","description":"Gap between grid items"},"grid-template-columns":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":["templateareas","fixedcols"],"name":"Template columns","type":"text","description":"Column sizes when using fixed columns or named template areas"},"grid-template-rows":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":"templateareas","name":"Template rows","type":"dimensionlist","description":"Row sizes when using a named items mode"},"grid-template-areas":{"default":"","inherit":1,"dependson":"grid-mode","dependvalue":"templateareas","name":"Template areas","type":"text","description":""},"flex-direction":{"default":"row","options":[{"name":"Row","value":"row","description":""},{"name":"Row reverse","value":"row-reverse","description":""},{"name":"Column","value":"column","description":""},{"name":"Column reverse","value":"column-reverse","description":""}],"dependson":"grid-mode","dependvalue":"flex","name":"Flexible grid direction","type":"list","description":"The direction in which a flexible grid is shown"},"flex-stretch":{"default":"0","dependson":"grid-mode","dependvalue":"flex","name":"Flex stretch","type":"boolean","description":"Stretch out the items to fill the available space"},"flex-wrap":{"default":"wrap","options":[{"name":"Wrap","value":"wrap","description":""},{"name":"No Wrap","value":"nowrap","description":""},{"name":"Wrap reverse","value":"wrap-reverse","description":""}],"dependson":"grid-mode","dependvalue":"flex","name":"Flex wrap","type":"list","description":"Wrap items onto multiple lines"},"layout":{"default":"standard","inherit":1,"options":[{"name":"Standard","value":"standard","description":"Standard grid"},{"name":"Masonry","value":"masonry","description":"Arrange images in a best fit alignment according to their height"},{"name":"Carousel","value":"carousel","description":"A horizontal scrolling panel"},{"name":"Justified Gallery","value":"justifiedGallery","description":"Justify images horizontally"}],"name":"Layout type","type":"list","description":""},"popup":{"default":0,"inherit":1,"name":"Popup","type":"boolean","description":"Link to pop up image"},"grid-max-height":{"name":"Max image height","type":"dimension","description":""},"caption-position":{"default":"bottom","inherit":1,"options":[{"name":"Top","value":"top","description":""},{"name":"Bottom","value":"bottom","description":""},{"name":"Above","value":"above","description":""},{"name":"Under","value":"under","description":""},{"name":"Overlay","value":"overlay","description":""}],"name":"Caption position","type":"list","description":""},"align-frame":{"default":"middle","options":[{"name":"Left","value":"start","description":""},{"name":"Center","value":"center","description":""},{"name":"Right","value":"end","description":""}],"name":"Image Align (horzontal)","type":"list","description":""},"justify-frame":{"default":"start","inherit":1,"options":[{"name":"Top","value":"start","description":""},{"name":"Center","value":"center","description":""},{"name":"Bottom","value":"end","description":""}],"name":"Image Align (vertical)","type":"list","description":""},"object-fit":{"default":"scale-down","options":[{"name":"Crop","value":"cover","description":""},{"name":"Shrink","value":"scale-down","description":""},{"name":"Stretch","value":"fill","description":""}],"name":"Image fit","type":"list","description":""},"subcaptions":{"default":0,"inherit":1,"name":"Subcaption","type":"boolean","description":"Add sub caption to html. This will be deprecated in favour of a caption template system"},"contain":{"default":false,"dependson":"layout","dependvalue":"carousel","name":"Contain","type":"boolean"},"freeScroll":{"default":true,"dependson":"layout","dependvalue":"carousel","name":"Free Scroll","type":"boolean"},"wrapAround":{"default":true,"dependson":"layout","dependvalue":"carousel","name":"Wrap Around","type":"boolean"},"pageDots":{"default":false,"dependson":"layout","dependvalue":"carousel","name":"Page Dots","type":"boolean"},"prevNextButtons":{"default":true,"dependson":"layout","dependvalue":"carousel","name":"Previous Next Buttons","type":"boolean"},"rowHeight":{"name":"Row height","type":"dimension","description":"Only for justified gallery layout mode"}},"panels":[{"selector":" .frame","panel":"item","name":"Item"},{"selector":" .caption","panel":"caption","name":"Caption"},{"selector":" .image","panel":"image","name":"image"},{"selector":" .subcaption","panel":"subcaption","name":"subcaption"}]},"articlelist":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"htop":{"default":"false","inherit":1,"type":"boolean","description":"Put headline before image"},"image-align":{"default":"center","inherit":1,"type":"halign"},"flow":{"default":false,"inherit":1,"type":"boolean"},"image-gap":{"default":"10px","type":"dimension","description":"Gap between image and text when aligned left or right. Use margins on the panels for other instances"},"image-width":{"default":"40%","type":"dimension"},"titletag":{"default":"h3","options":[{"value":"h1"},{"value":"h2"},{"value":"h3"},{"value":"h4"},{"value":"h5"},{"value":"h6"}],"type":"list"},"showtitle":{"default":"block","type":"displayblock"},"showimage":{"default":"block","type":"displayblock"},"showcaption":{"default":"none","type":"displayblock"},"carousel":{"default":false,"inherit":1,"type":"boolean","description":"use carousel for list"}},"panels":[{"selector":" .item","panel":"item","name":"Item"},{"selector":" .title","panel":"title","name":"title"},{"selector":" .imageWrap","panel":"image","name":"image"},{"selector":" .textWrap","panel":"text","name":"text"}]},"title":{"states":[{"selector":"","name":"Main","state":"main","description":"The main state"},{"selector":":hover","name":"Hover","state":"hover","description":"Hover state"}],"styleDefs":{"tag":{"options":[{"value":"h1"},{"value":"h2"},{"value":"h3"},{"value":"h4"},{"value":"h5"},{"value":"h6"}],"name":"Tag","type":"list","description":"HTML tag to enclose text in"}},"panels":[]}};
settingsOptions = {"flexgrow":[{"name":"Yes","value":"1","description":"Item will expand to fit width (if set)"},{"name":"No","value":"0","description":"Item will not expand."}],"position":[{"name":"Normal","value":"static","description":""},{"name":"Fixed to screen","value":"fixed","description":""},{"name":"Relative to container","value":"absolute","description":""},{"name":"Sticky","value":"sticky","description":""},{"name":"Normal with adjustment","value":"relative","description":""}],"valign":[{"name":"Top","value":"top","description":""},{"name":"Middle","value":"middle","description":""},{"name":"Bottom","value":"bottom","description":""}],"float":[{"name":"None","value":"none","description":""},{"name":"Left","value":"left","description":""},{"name":"Right","value":"right","description":""}],"shapes":[{"name":"Left chevron","value":"chevron-left"},{"name":"Open full","value":"open_in_full"},{"name":"Instagram","value":"instagram"},{"name":"Bars","value":"bars"},{"name":"Shopping cart","value":"cart"},{"name":"Right arrow","value":"right_arrow"},{"name":"Left arrow","value":"left_arrow"},{"name":"Menu","value":"menu"},{"name":"Close","value":"close"},{"name":"Whatsapp","value":"whatspp"},{"name":"Pop up","value":"popup"},{"name":"Thumbnails","value":"thumbnails"},{"name":"Arrow down","value":"arrow_down"},{"name":"Right chevron","value":"chevron-right"},{"name":"Twitter","value":"twitter"},{"name":"Facebook","value":"facebook"}],"displayblock":[{"name":"Hide","value":"none","description":""},{"name":"Show","value":"block","description":""}],"overflow":[{"name":"Hidden","value":"hidden","description":""},{"name":"show","value":"show","description":""}],"halign":[{"name":"Left","value":"left","description":""},{"name":"Centre","value":"center","description":""},{"name":"Right","value":"right","description":""}]};