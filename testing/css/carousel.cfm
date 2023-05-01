<!---

# Carousel testing page



## Notes

1. Cell sizing
All sizing and styling of the cells are handled by your own CSS. The height of the carousel is set to the maximum height of the cells.

note: need to apply this height if you want to contain it.

2. Selected cell
.flickity-cell.is-selected

3. Buttons

/* no circle */
.flickity-button {
  background: transparent;
}
/* big previous & next buttons */
.flickity-prev-next-button {
  width: 100px;
  height: 100px;
}
/* icon color */
.flickity-button-icon {
  fill: white;
}
/* hide disabled button */
.flickity-button:disabled {
  display: none;
}
/* position outside */
.flickity-prev-next-button.previous {
  left: -40px;
}
.flickity-prev-next-button.next {
  right: -40px;
}


## Status

Mess - copied form somewhere else.

## History

2023-05-01  THP   sort of started.

--->

<cfscript>

request.rc.test = 'auto'; /* fixedwidths | fixedcols */

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
site = {};
options = {
	"contain": "true",
	"wrapAround": "false",
	"freeScroll": "false",
	"pageDots": "false",
	"pageDots": "false",
	"prevNextButtons": "false"
}
image_sets = getImages(site);

styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));

grid_cs = contentObj.new(id="testgrid",type="imagegrid");
grid_cs.data = image_sets;
grid_cs.class = "scheme-#request.rc.test#";

contentObj.settings(content=grid_cs,styles=styles.style,media=styles.media);
css = "";//contentCSS(grid_cs);
pageData = contentObj.display(content=grid_cs,data=site.images);
html = pageData.html;
</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/flickity.css">
		<style>
			body {
				background-color: #f3f3f3;
				padding:20px;
			}
			.scroller {
				height:320px;
			}

			img {
				max-height: 100%;
				width:auto;
			}

			#testgrid img {
				height:320px;
				opacity: 0.6;
			}
			
			#testgrid .flickity-cell.is-selected img {
			  opacity: 1;
			}
			.flickity-button-icon {	
				  fill: white;
			}
			.flickity-button {
			  background: transparent;
			}
			.flickity-button:hover {
			  background: transparent;
			  fill:white;
			}
			.flickity-prev-next-button:hover .flickity-button-icon {
			  fill: #ff00ff;
			}

			.flickity-button:focus {
			  background: transparent;
			  box-shadow: none;
			}
			
    
}

			<cfoutput>#css#</cfoutput>
		</style>
	
	</head>

	<body class="body">
		<div class="scroller">
			<cfoutput>#html#</cfoutput>
		</div>
		<script src="/_assets/js/jquery-3.4.1.js"></script>
		<script src="/_assets/js/flickity.pkgd.min.js"></script>
		<script type="text/javascript"> 
			$(document).ready(function() {
				$carousel = $('#testgrid');
				$carousel.flickity({
				  // options
				  <cfoutput>
				   contain: #options.contain#,
				   freeScroll: #options.freeScroll#,
				   wrapAround: #options.wrapAround#,
				   pageDots: #options.pageDots#,
				   prevNextButtons: #options.prevNextButtons#
				  </cfoutput>
				}).on( 'change.flickity', function( event, index ) {
				  console.log( 'Slide changed to ' + index );
				  var cellElements = $carousel.flickity('getCellElements')
				}).on( 'staticClick.flickity', function( event, pointer, cellElement, cellIndex ) {
				  // dismiss if cell was not clicked
				  if ( !cellElement ) {
				    return;
				  }
				  $carousel.flickity("select", cellIndex,true);
				});;
			});
		</script>

	</body>

	
</html>

<cfscript>
/**
 * To use images in a grid content section we need a record of all images
 * as a look up struct ("Data") and an array of ids ("data set").
 *
 * This function uses the sample data to add the complete data to the struct
 *  supplied by reference and adds the ID to the array.
 * and
 */
array function getImages(required struct site, image_path="/images/") {
	
	local.myXML = application.utils.fnReadXML(ExpandPath("../../sample/_data\data\photos.xml"));
	local.images = application.XMLutils.xml2Data(local.myXML);
	arguments.site.images = [=];
	local.image_set = [];

	for (local.image in local.images) {
		local.image.image = image_path & local.image.image_thumb;
		local.image.image_thumb = image_path & local.image.image_thumb;
		arguments.site.images[local.image.id] = local.image;
		ArrayAppend(local.image_set, local.image.id);
	}

	return local.image_set;

}

function contentCSS(required struct cs) {
	local.site_data = { "#arguments.cs.id#" = arguments.cs};
	local.css = contentObj.contentCSS(styles=styles, content_sections=local.site_data, media=styles.media);
	return local.css;
}

</cfscript>
