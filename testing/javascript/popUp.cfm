<!--

# Animate Auto Demo Page

## Synopsis

WIP not yet working

-->

<cfscript>
myXML = application.utils.fnReadXML(ExpandPath("../images/photos.xml"));
myData = application.XMLutils.xml2Data(myXML);
photosJS = serializeJSON(myData);
</cfscript>

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
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

	img {
		max-width: 100%;
		max-height: 100%;
		margin:0 auto;
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
		<div id="image" class="cs-image">
			<img src="/images/matt-moloney-OAzh2bBN110-unsplash_thumb.jpg">
		</div>
		<div id="openButton" class="button auto">
			<a href="#popuptest.open">
				<svg  class="icon"  viewBox="0 0 24 24"><use xlink:href="/_assets/images/open_in_full.svg#open_in_full"></svg>
				<label>Open Popup</label>
			</a>
		</div>
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
		});
		$(".button.auto").button();
	});

</script>

</html>

<!--- - 
<cffunction name="loadPhotos" output="false">

	<cfdirectory directory="D:/unsplash" name="photos">

	<cfset retVal = "photos = {};">
	<cfset i = 1>
	<cfloop query="photos">
		<cfset retVal &= "photos[#i#] = {""photo"":""#photos.name#"",""caption"":""#photos.name#""};"> 
		<cfset i++>
	</cfloop>

	<cfreturn retVal>

</cffunction>
 --->