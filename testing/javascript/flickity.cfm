<cfscript>
lorem = ListToArray(
	"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed 
	do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
	Ut enim ad minim veniam, quis nostrud exercitation ullamco 
	laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure 
	dolor in reprehenderit in voluptate velit esse cillum dolore eu 
	fugiat nulla pariatur. Excepteur sint occaecat cupidatat non 
	proident, sunt in culpa qui officia deserunt mollit anim id 
	est laborum."," #chr(13)##chr(10)#"
	);

colors = ['iceblue','aqua','aquamarine','azure','bisque','blanchedalmond','blue','blueviolet','burlywood','cadetblue','chartreuse','chocolate','coral','cornflowerblue','cornsilk','crimson','cyan','darkblue','darkcyan','darkgoldenrod','darkgray','darkgreen','darkgrey','darkkhaki','darkmagenta','darkolivegreen','darkorange','darkorchid','darkred','darksalmon','darkseagreen','darkslateblue','darkviolet','deeppink','deepskyblue','dimgray','dimgrey','dodgerblue','firebrick','floralwhite','forestgreen','fuchsia','gainsboro','ghostwhite','gold','goldenrod'];
</cfscript>

<!DOCTYPE html>
<html>
<head>
	
	<title>Flickity test</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/flickity.css">
	<meta charset="UTF-8">
	<style>
		body {
			--title-font: 'Open Sans';
			--title-font-size: 140%;
			--title-font-weight: 300;
			--border-color:#1B02A3;
			--accent-color:#DC00FE;
		}
		
		.item {
			padding:40px;
			width: 460px; /* full width */
			min-height: 260px; /* height of carousel */
			margin-right: 10px;
		}

		.panel1 {
		}
		.panel2 {
			width: 560px; 
		}
		.panel3 {
			width: 260px;
		}
		.panel4 {
			width: 360px;
		}
		

		.item .imageWrap {
			max-width: 100%;
		}
		img {
			max-width: 100%;
			height:auto;
		}
		.is-selected {
		  background: #ED2;
		}
		.title {
			font-size: 240%;
			font-weight: bold;
		}

		.flickity-button, .flickity-button:hover {
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

		.flickity-button:hover .flickity-button-icon {
		  fill: pink;
		}

		/* hide disabled button */
		.flickity-button:disabled {
		  display: none;
		}
	</style>
</head>
<body>

	<div class="main-carousel">
		<cfloop index="i" from="1" to="10">
			<cfoutput>
			<cfset width = 200+ (20 * randrange(1,22))>
			<div class="item panel#i#" id="panel#i#" style="background-color:#colors[i]#;width:#width#px">
				<h3 class="title">Item #i#</h3>
				<div class="imageWrap">
					<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
				</div>
				<div class="textWrap">
					<cfset text = ArraySlice( lorem,1, RandRange( 10,lorem.len() ) ).toList(" ")>
					<p>#text#</p>
				</div>
			</div>
			</cfoutput>
		</cfloop>

	</div>

<div id="main-item">
	
</div>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/flickity.pkgd.min.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript">
	$(document).ready(function() {
		$main = $("#main-item");
		$carousel = $('.main-carousel');
		$('.main-carousel').flickity({
		  // options
		  contain: false,
		  freeScroll: false,
		  wrapAround: true
		}).on( 'change.flickity', function( event, index ) {
		  console.log( 'Slide changed to ' + index );
		  var cellElements = $carousel.flickity('getCellElements')
		  $main.html($(cellElements[index]).html()); 
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

