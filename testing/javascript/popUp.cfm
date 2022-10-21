<!--

# Animate Auto Demo Page

## Synopsis


-->

<!DOCTYPE html>
<html>

<head>
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
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


	#image {
		width:480px;
	}

	img {
		max-width: 100%;
		max-height: 100%;
		object-fit: scale-down;
	}

	#popup {
		position: fixed;
		padding:20px;
		top:0;
		left:0;
		background-color: rgba(199,199,199,0.8);
		width: 100vw;
		height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	#popup_image {
		width: 100%;
		height: 100%;	
	}

	#popup_caption {
		position: fixed;
	}

	</style>
</head>

<body>

	<div id="ubercontainer">
		<div id="image" class="cs-image">
			<img src="/images/matt-moloney-OAzh2bBN110-unsplash_thumb.jpg">
		</div>
	</div>

	<div id="popup">
		<div id="popup_image">
			<img src="/images/matt-moloney-OAzh2bBN110-unsplash.jpg">
		</div>
		<div id="popup_caption">
			My caption
		</div>
	</div>
</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/jquery.autoButton.js"></script>

<script>


	$(document).ready(function() {

	
	
	});

</script>

</html>

<!--- 
<cffunction name="loadPhotos" output="false">

	<cfdirectory directory="D:/unsplash" name="photos">

	<cfset retVal = "photos = {};">
	<cfset i = 1>
	<cfloop query="photos">
		<cfset retVal &= "photos[#i#] = {""photo"":""#photos.name#"",""caption"":""#photos.name#""};"> 
		<cfset i++>
	</cfloop>

	<cfreturn retVal>

</cffunction> --->
