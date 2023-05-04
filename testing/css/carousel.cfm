<!---

# Carousel testing page

NB This is mainly deprecated by using layout=carousel in the imagegrid testing page. 

We just need to sort out the styling for the carousel nav buttons. These are done manually
here. Need to work to them into the component in panels and states etc.

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


<cfinclude template="images_include.cfm">

<cfscript>

request.rc.test = 'overlay'; 

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
site = {};
options = {
	"contain": "true",
	"wrapAround": "true",
	"freeScroll": "false",
	"pageDots": "false",
	"prevNextButtons": "true"
}
image_sets = getImages(site);

styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));

grid_cs = contentObj.new(id="testgrid",type="imagegrid");
grid_cs.data = image_sets;
grid_cs.class = "scheme-grid scheme-#request.rc.test#";

contentObj.settings(content=grid_cs,styles=styles.style,media=styles.media);
css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");
css &= contentCSS(grid_cs);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

pageData = contentObj.display(content=grid_cs,data=site.images);
html = pageData.html;
</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
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
				});

				$("#nextbutton").on("click",function() {
					$carousel
				})
			});
		</script>

	</body>

	
</html>
