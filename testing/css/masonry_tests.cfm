<!--

# Basic Masonry Testing

## Styling notes

The width of the images is picked up from the original CSS.

Apply "fixed" class to body to view fixed column styling.

When using percentage styling, some adjustment has to be made for the gutter setting

## Options notes

1. We are using the imagesLoaded script here to call the layout method of the masonry grid once they are loaded. Ensure initLayout is off

-->

<cfscript>
myXML = application.utils.fnReadXML(ExpandPath("../images/photos.xml"));
myData = application.XMLutils.xml2Data(myXML);

// fixed sets the image widths a set size (see .fixed #imagegrid figure)
// gutter-sizer uses a CSS element to set the gutter size (see .gutter-sizer )
// if gutter-sizer is false, uses the gutter-size value
// percentPosition is like a grid auto fit. You probably want this
// initLayout - delay layout and use imagesLoaded to 
//      NB the effect you see on changing this is combination of the initLayout param and the imagesLoaded script.
request.prc.config = {
	"fixed"=0,
	"gutter-sizer":true,
	"gutter-size": "10",
	"initLayout": false,
	"percentPosition": true
};
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
	<title>Masonry tests</title>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<style>
		.gutter-sizer {
			width:1%;
		}
		#imagegrid figure {
			width:19%;
			margin-bottom: 12px;
		}

		#imagegrid figure.wide {
			width:39%;
		}

		@media screen and (max-width: 1000px) {
			#imagegrid figure {
				width:24%;
			}
			#imagegrid figure.wide {
				width:49%;
			}
		}

		@media screen and (max-width: 800px) {
			#imagegrid figure {
				width:32%;
			}
			#imagegrid figure.wide {
				width:65%;
			}
		}

		figure img {
			max-width: 100%;
			height:auto;
		}

		.fixed #imagegrid figure {
			width:260px;
		}
		
		#uberContainer {
			max-width: 1000px;
			margin: 0 auto;
		}

		#imagegrid.hidden .grid {
			display:none;
		}
	</style>
</head>

<cfset local.class = request.prc.config.fixed ? " class='fixed'" : "">

<cfoutput>
<body #local.class#id='body'>
</cfoutput>

	<div id="uberContainer"> 
		<cfset local.class = request.prc.config.initLayout ? "" : "class='hidden'">
		<cfoutput>
		<div id="imagegrid" #local.class# data-notes="Notes here" type="imagegrid"> 
		</cfoutput>
	   		<div class="grid">
	   			<cfif request.prc.config["gutter-sizer"]>
	   				<div class='gutter-sizer'></div>
	   			</cfif>
				<cfloop index="image" array="#myData#">
					<figure>
						<cfoutput>
							<a href="../images/#image.image#"><img src="../images/#image.image_thumbnail#"> 
							<figcaption>
							#image.caption#
							</figcaption></a>
						</cfoutput>
					</figure>					
				</cfloop>
	   		</div> 
	  	</div> 
	 
	</div>

	<script src="/_assets/js/jquery-3.4.1.js"></script>
	<script src="/_assets/js/imagesloaded.pkgd.js"></script>
	<script src="/_assets/js/masonry.pkgd.js"></script>
	<cfset gutter = request.prc.config["gutter-sizer"] ? "'.gutter-sizer'" : Val( request.prc.config["gutter-size"] )>
	<cfoutput>
	<script>	
	$( document ).ready( function() {
		$imagegridGrid = $('##imagegrid .grid').masonry( {
			itemSelector: 'figure', 
			columnWidth: '##imagegrid figure',
			initLayout: #(request.prc.config.initLayout ? 'true' : 'false')#,
			percentPosition: #(request.prc.config.percentPosition ? 'true' : 'false')#, 
			gutter: #gutter#
		} );
		<cfif NOT request.prc.config.initLayout>
		$imagegridGrid.imagesLoaded().progress( function() {
			$imagegridGrid.masonry('layout');
			$imagegridGrid.show();
		} );
		</cfif>
	});
	</script>
	</cfoutput>
</body>
</html>








