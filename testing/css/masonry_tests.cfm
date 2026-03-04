<!--

# Basic Masonry Testing

## Styling notes

The width of the images is picked up from the original CSS.

Guter sizing works with single-szie cells. If, like in the example, you have "wide" images mixed in, you can only use padding.

## Options notes

1. We are using the imagesLoaded script here to call the layout method of the masonry grid once they are loaded. 

-->

<cfscript>
myXML = application.utils.fnReadXML(ExpandPath("../images/photos.xml"));
myData = application.XMLutils.xml2Data(myXML);

</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
	<title>Masonry tests</title>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/grids.css">
	<style>
		#imagegrid {
			--grid-mode: masonry;
			--grid-width:20%;
			--grid-gap:12px;
		}
		
		@media screen and (min-width: 1400px) {
			#imagegrid {
				--grid-mode: fit;
			}
		}

		@media screen and (max-width: 1000px) {
			#imagegrid {
				--grid-width:25%;
			}
		}

		@media screen and (max-width: 800px) {
			#imagegrid  {
				--grid-mode: none;
			}
		}

		.frame img {
			max-width: 100%;
			height:auto;
		}
		
		#uberContainer {
			max-width: 1000px;
			margin: 0 auto;
		}
	</style>
</head>

<cfoutput>
<body id='body'>
</cfoutput>

	<div id="uberContainer"> 
		<div id="imagegrid" data-notes="Notes here" class="grid"> 
			<div  class="gridInner">
	   			<cfset count=1>
				<cfloop index="image" array="#myData#">
					<cfset class = count mod 3 eq 0 ? " wide" : "">
					<cfoutput>
						<a class='frame#class#' href="../images/#image.image#">
							<div class='image'><img src="../images/#image.image#"> 
							</div>
							<div class='caption'>
							#image.caption#
							</div>
						</a>
					</cfoutput>
					<cfset count++>			
				</cfloop>
	   		</div> 
	  	</div> 
	 
	</div>

	<script src="/_assets/js/jquery-3.4.1.js"></script>
	<script src="/_assets/js/imagesloaded.pkgd.js"></script>
	<script src="/_assets/js/masonry.pkgd.min.js"></script>
	<script src="/_assets/js/masonryGrid.js"></script>
	<script src="/_assets/js/clik_common.js"></script>
	<script src="/_assets/js/clik_onready.js"></script>

</body>
</html>








