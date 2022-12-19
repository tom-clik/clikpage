<cfscript>
/*
Using one carousel to control another.

There is a setting asNavFor but I couldn't get this working

Instead I have used the events to do this manually

The main carousel uses the fade option with some hard wired CSS to simlaute a slideshow. This seems to suffer a weird slowdown bug whic may or may not be a thing.

Note here we have wrapped the figures in another div. This is to use absolute positioning for the captions which requires the figures to have position:relative.
*/

myXML = application.utils.fnReadXML(ExpandPath("../images/photos.xml"));
myData = application.XMLutils.xml2Data(myXML);

request.prc.config = {
	
};

</cfscript>

<!DOCTYPE html>
<html>
<head>
	
	<title>Flickity test</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/flickity.css">
	<link rel="stylesheet" href="/_assets/css/flickity-fade.css">
	

	<meta charset="UTF-8">
	<style>
		body {
			--title-font: 'Open Sans';
			--title-font-size: 140%;
			--title-font-weight: 300;
			--border-color:#1B02A3;
			--accent-color:#DC00FE;
		}

		.main-carousel {
			height:70vh;
			width:100%;
		}
		
		.main-carousel .item {
			padding:20px;
			opacity: 0;
			transition: opacity 0.4s ease-in-out;
		    z-index: 0;
		}
		.main-carousel .item.is-selected {	
			opacity: 1;
		}
		figure {
			position: relative;
		}
		
		.main-carousel figcaption {
			position: absolute;
			width:100%;
			padding:8px;
			background-color: rgba(0,0,0,0.4);
			color:white;
			opacity: 0;
			top:0;
			transition: opacity 0.4s ease-in-out;
		}

		.main-carousel figure:hover figcaption {
			opacity: 1;
		}


		figure img {
			max-width: 100%;
			height:auto;
		}

		.main-carousel .item, .main-carousel figure {
			height: 100%;
		}

		
		.nav-carousel .item {
			padding:4px;
			min-width: 80px;
			height:120px;
			opacity:0.8;
		}

		.main-carousel figure, .nav-carousel figure, .main-carousel figure img, .nav-carousel figure img {
			height: 100%;
			width:auto;
		}

		.nav-carousel .item:hover {
			opacity:1;	
		}

		.nav-carousel .figure.is-nav-selected {
		  background: #ED2;
		  opacity:1;	
		}

		

	</style>
</head>
<body>

	<div class="main-carousel">
		<cfloop array="#myData#" index="image">
			<cfoutput>
			<div class="item">
				<figure>
					<cfoutput>
						<img src="../images/#image.image_thumbnail#" data-flickity-lazyload="../images/#image.image#"> 
						<figcaption>
						#image.caption#
						</figcaption></a>
					</cfoutput>
				</figure>
			</div>
			</cfoutput>
		</cfloop>

	</div>
	
	<div class="nav-carousel">
		<cfloop array="#myData#" index="image">
			<cfoutput>
			<div class="item">
				<figure>
					<cfoutput>
						<img src="../images/#image.image_thumbnail#"> 
					</cfoutput>
				</figure>
			</div>
			</cfoutput>
		</cfloop>

	</div>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/flickity.pkgd.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/flickity-fade.js"></script>


<script type="text/javascript">
	$(document).ready(function() {
		$nav = $('.nav-carousel');
		$main = $('.main-carousel').flickity({
		  // options
		  contain: true,
		  freeScroll: false,
		  wrapAround: true,
		  lazyLoad: 2,
		  pageDots: false,
		  adaptiveHeight: false,
		  fade:true
		}).on( 'change.flickity', function( event, index ) {
		  console.log( 'Slide changed to ' + index );
		  var cellElements = $(this).flickity('getCellElements')
		  $nav.flickity("select", index,true);
		});

		$nav.flickity({
		  // options
		  contain: false,
		  freeScroll: false,
		  wrapAround: true,
		  asNavFor: '.main-carousel'
		}).on( 'change.flickity', function( event, index ) {
		  console.log( 'Slide changed to ' + index );
		  var cellElements = $(this).flickity('getCellElements')
		  
		}).on( 'staticClick.flickity', function( event, pointer, cellElement, cellIndex ) {
		  // dismiss if cell was not clicked
		  if ( !cellElement ) {
		    return;
		  }
		  $(this).flickity("select", cellIndex,true);
		  $main.flickity("select", cellIndex,true);
		});

		


	});
</script>


</body>
</html>

