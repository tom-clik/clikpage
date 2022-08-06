<!---

Adjsut layout of general cs using template positions.


HTML is 

<div class="item">

	<h3 class="title">Headline before image</h3>

	<div class="imageWrap">

		<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
		 <div class="caption">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod 
			tempor incididunt ut </div>
	</div>

	<div class="textWrap">
		<p>
			Headline set to show before. Image set to show on left, column width is default 40%</p>
			
	</div>

</div>

NB The HTML order is apparently an SEO thing. Unless specified with htop the headline will be placed under the image in desktop mode (No, me neither). So basically, htop should be on for everything.

In mobile it will appear above. This apparently is good UX. I put munder on every item to put it under.

The following options are available:

position    left|right       Display image on the left
htop        Display heading before image
image-width  Width of image (css length)
imagespace  Show image space evern when you don't have one
image-gap     Gap ebtween image and text


NB converting them to CSS vars is a little complex and depends on what medium you are in. See the getCSS() stuff.

NB "image" is an instruction to this page to shown an image file. Not a CSS thing

## Status

Working really well. Bugs in the imagespace thing but apart from that it's great.

--->

<cfscript>
csObj = new general();

styles = csObj.newStyles();

tests = [
	{id="test1",title="No formatting"},
	{id="test2",title="Headline before image except in mobile"},
	{id="test3",title="Larger image",htop=true, position="right",imagewidth="66%"},
	{id="test4",title="Larger image left",htop=true, position="left",imagewidth="66%"},
	{id="test5",title="No image with space still showing",htop=true,position="left", imagespace=1,image=0},
	{id="test6",title="No image with no space",htop=true, position="left", image=0},
	{id="test7",title="Headline is inline",position="right"},
	{id="test8",title="Headline is inline left",position="left",gridgap="50px"}
];

styles = {
	"test2" = {
		"main" = {
			"htop"=true,
			"image-align":"left"
		},
		"mobile"= {
			"htop"=false,
			"image-align":"center"
		}
	},
	"test3" = {
		"main" = {
			"htop"=true,
			"image-align":"right",
			"image-width":"66%"
		},
		"mobile"= {
			"image-align":"center"
		}
	},
	"test4" = {
		"main" = {
			"htop"=true,
			"image-width":"66%",
			"image-align":"left",
			"image-gap": "40px"
		},
		"mobile"= {
			"image-align":"center"
		}
	},
	"test7" = {
		"main" = {
			"image-align":"left"
		},
		"mobile"= {
			"htop"=false,
			"image-align":"center"
		}
	},
	"test8" = {
		"main" = {
			"image-align":"right"
		},
		"mobile"= {
			"htop"=false,
			"image-align":"center"
		}
	},
}

</cfscript>

<html>

	<title>General cs with grid positions</title>

		<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">
	 	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="_styles/standard.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/panels.css">
		
<style>


<cfoutput>#css(tests,styles)#</cfoutput>



/* styling for this page -- ignore or set width */
.itemlist {
  min-width:260px;
  max-width: 800px;
  margin:20px auto;
}

h3.title {
	margin:0 0 1em 0;
}

.item {
	background-color: #dcdcdc;
	padding:12px;
	margin:12px 0;
}
</style>

<body>

<div class="itemlist">

	<cfloop item="test" array="#tests#">
		<cfset StructAppend(test,{"image"=1},false)>
		<cfoutput>
			<div class="item" id="#test.id#">

			
				<h3 class="title">#test.title#</h3>

				<div class="imageWrap">
					<cfif test.image>
						<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
					</cfif>
				</div>
				

				<div class="textWrap">
					<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
					tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
					quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
					consequat. </p>
					<!--- <table>
						<cfloop item="field" list="position,htop,imagewidth,imagespace,image,gridgap">
							<tr><td>#field#</td><td>#test[field]#</td></tr>
						</cfloop>
					</table> --->
						
				</div>
			
			</div>
		</cfoutput>

	</cfloop>


</div>


</body>


</html>


<cfscript>
/**
 * @hint Loop over every test and generate css
 *
*/
string function css(required array tests, required struct styles) {
	var css = "";
	for (local.test in arguments.tests) {
		if (StructKeyExists(styles,local.test.id)) {
			css &= csObj.css(selector="###local.test.id#",styles=styles[local.test.id],debug=true);
		}
	}
	return css;
}

</cfscript>

<!---

	StructAppend(arguments.styles,{imagespace=0,position=left},false);	
	if (StructKeyExists(arguments.styles,"htop") AND arguments.styles.htop) {
		css &= "\t--item-grid-template-areas: ""title"" ""imageWrap"" ""textWrap"";\n";
	}
	if (StructKeyExists(arguments.styles,"gridgap") AND arguments.styles.gridgap != "") {
		css &= "\t--item-gridgap: #arguments.styles.gridgap#;\n";
	}
	if (StructKeyExists(arguments.styles,"imagewidth") AND arguments.styles.imagewidth != "") {
		css &= "\t\t--item-image-width: #arguments.styles.imagewidth#;\n";
	}
	
	if ((!arguments.styles.imagespace) && (!arguments.image)) {
		css &= "\t\t/* no image nospace */\n";
		css &= "\t\t--item-grid-template-areas: ""title"" ""textWrap"";\n";
		css &= "\t\t--item-grid-template-columns:  1fr;\n";
		css &= "\t\t--item-grid-template-columns: unset;\n";
	}
	local.showImage = arguments.styles.imagespace or arguments.image;
	if (arguments.position == "left" && local.showImage) {
		css &= "\t\t--item-grid-template-areas: ""imageWrap title"" ""imageWrap textWrap"";\n";
		css &= "\t\t--item-grid-template-columns: var(--item-image-width) auto;\n";
	}
	else if (arguments.styles.position == "right" && local.showImage) {
		css &= "\t\t--item-grid-template-areas: ""title imageWrap"" ""textWrap imageWrap"";\n";
		css &= "\t\t--item-grid-template-columns: auto var(--item-image-width);\n";
		if (arguments.styles.htop) {
			css &= "\t\t--item-grid-template-areas: ""title title"" ""textWrap imageWrap"";\n";
		}
	}
	if (arguments.styles.htop AND arguments.styles.position != "right" && local.showImage) {
		css &= "\t\t--item-grid-template-areas: ""title title"" ""imageWrap textWrap"";\n";
	}

	return css; 

--->