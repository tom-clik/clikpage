<!---

# Image Fixed Heights test page

## Synopsis

Demo of using pure CSS to fit image heights. Every element in the tree has to have a height:100% or have its height set by a grid template row. This is fine if you want the content to fit into the page and maybe have JS scrollbars.

We have decided not to do this in the actual system, and instead fix a height with JavaScript on the element to do the containing. See clikpage\testing\javascript\imageheights_fix.html

--->

<cfscript>
photoDef = ExpandPath("../images/photos.xml");
photos = loadPhotoDef(photoDef);
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
		display: grid;
		grid-template-rows: 20% 50% 1fr;
		grid-gap: 4px;
		height:100%;
	}

	.cs-image {
		border: 1px solid #444;
		display: grid;
		grid-template-rows: minmax(0,1fr) min-content;

	}

	.image img {
		/*position: absolute;
		visibility: hidden;*/
		height:100%;
/*		object-fit: scale-down;*/

	}

	.image.fixed img {
		position: static;
		visibility: visible;
	}

	.caption {
		padding:4px;
		text-align: center;
		background-color: #ccc;
	}

	</style>
</head>

<body>

	<div id="ubercontainer">
		<cfset count = 1>
		<cfloop index="image" array="#photos#">
			<cfoutput>
				<div id="image#count#" class="cs-image">
					<div class="image">
						<img src="../images/#image.image#"> 
					</div>
					<div class='caption'>
					#image.caption#
					</div>
				</div>
			</cfoutput>
			<cfset count++>
			<cfif count gt 3>
				<cfbreak>
			</cfif> 
		</cfloop>
		
		
	</div>

	
</body>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
<script src="/_assets/js/fixheight.js"></script>
<script>

	$(document).ready(function() {
		$(".cs-image").fixedHeight();
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