<!--

# Image popup Demo Page

## Synopsis

Working of a fashion

-->

<cfscript>
photoDef = ExpandPath("../images/photos.xml");
photos = loadPhotoDef(photoDef);
photosJS = serializeJSON(photos);
</cfscript>

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<style>
	body {
		padding:20px;
		background-color: #ccc;
	}

	#ubercontainer {
		background-color: #fff;
		border: 1px solid #000;
		padding:20px;
		margin: 0 auto;
		max-width: 660px;
	}

	.section {
		margin:20px;
		border: 1px solid #000;
		padding:20px;
	}

	#images {
	    --frame-flex-direction: column;
	    --image-grow: 1;
	    grid-gap: 20px;
	    --grid-max-height: auto;
	    display: grid;
	    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
	}

	#popuptest {
		position: fixed;
		padding:20px;
		top:0;
		left:0;
		background-color: rgba(255,255,255,1);
		width: 100vw;
		height: 100vh;
		display: none;
		overflow: hidden;
		align-items: center;
		justify-content: center;
	}

	#popuptest .button {
		position: fixed;
		top:6px;
		right:6px;
		--icon-width:12px;
		--icon-height:12px;
	}

	#popuptest img {
		margin:0 auto;
		box-shadow: 10px 10px 15px -4px rgba(0,0,0,0.72);
	}

	#popuptest .button:hover {
		stroke:#ff00ff;
		fill:#ff00ff;
		color:#ff00ff;
	}

	#closeButton.button {
		--label-display:none;
	}

	#nextButton.button{
		top:40%;
		--button-align:flex-start; 
		--button-direction: row-reverse;
		right:60x;
		
	}
	#previousButton.button{
		right:unset;
		top:40%;
		left:60x;
	}

	#popup_image {
		width: 100%;
		height: 100%;
	}
	</style>
</head>

<body>

	<div id="ubercontainer">
		<div id="images" class="grid cs-imagegrid ">
			<cfset count = 0>
			<cfloop index="image" array="#photos#">
				<cfoutput>
					<a data-index='#count#' class='frame' href="##">
						<div class='image'><img src="../images/#image.image_thumbnail#"> 
						</div>
						<div class='caption'>
						#image.caption#
						</div>
					</a>
				</cfoutput>
				<cfset count++>
			</cfloop>
		</div>
		
		<!--- <div id="openButton" class="button auto">
			<a href="#popuptest.open">
				<svg  class="icon"  viewBox="0 0 24 24"><use xlink:href="/_assets/images/open_in_full.svg#open_in_full"></svg>
				<label>Open Popup</label>
			</a>
		</div> --->
	</div>

	<div id="popuptest">
		<div class="popup_inner">
		</div>
		<div id="closeButton" class="button auto">
			<a href="#popuptest.close">
				<svg  class="icon"  viewBox="0 0 357 357"><use xlink:href="/_assets/images/close47.svg#close"></svg>
				<label>Close</label>
			</a>
		</div>
		<div id="nextButton" class="button auto">
			<a href="#popuptest.next">
				<svg  class="icon" preserveAspectRatio="none" viewBox="0 0 16 16"><use xlink:href="/_assets/images/chevron-right.svg#chevron-right"></svg>
				<label>Next</label>
			</a>
		</div>
		<div id="previousButton" class="button auto">
			<a href="#popuptest.previous">
				<svg  class="icon" preserveAspectRatio="none" viewBox="0 0 16 16" viewBox="0 0 16 16"><use xlink:href="/_assets/images/chevron-left.svg#chevron-left"></svg>
				<label>Previous</label>
			</a>
		</div>
	</div>
</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.autoButton.js"></script>
<script src="/_assets/js/swipeDetector.js"></script>
<script src="/_assets/js/popup.js"></script>
<script>

	$(document).ready(function() {
		$("#popuptest").popup({
			imagepath : "/images/",
			data:<cfoutput>#photosJS#</cfoutput>,
			onGoTo:function() {'Going to '}
		});
		$popup = $("#popuptest").data('popup');
		$(".button.auto").button();

		$("#images a").on("click",function(e) {
			e.preventDefault();
			e.stopPropagation();
			$popup.goTo($(this).data("index"));
			$popup.open();
		});
	});

</script>

</html>

<cfscript>
array function loadPhotoDef(required string filename) {
	var myXML = application.utils.fnReadXML(arguments.filename);	
	var myData = application.XMLutils.xml2Data(myXML);
	for (local.photo in myData) {
		local.photo["description"] = local.photo.caption;
	}
	return myData;
}
</cfscript>