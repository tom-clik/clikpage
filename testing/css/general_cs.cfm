<!---

# General content section test

A general content section is just a panel with a title, image and text wrap. 
Adjust layout of general cs using template positions.

If you just want a simple item, use a text, title, or image content section.


## Synopsis 

HTML is 

```html
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

```
htop
image-width
image-align
item-gridgap
```

## Status

Working really well. 

## TODO:

The image space functionality is missing. This is for when we have a listing of items
and the styling applies to all of them. Those without an image can show the image space or 
not. This will require a class appended to the individual item t indicate it doesn't
have an image.

--->

<cfscript>
csObj = new general();

styles = csObj.newStyles();

tests = [
	{id="test1",title="No formatting"},
	{id="test2",title="Headline before image except in mobile"},
	{id="test3",title="Larger image"},
	{id="test4",title="Larger image left"},
	{id="test5",title="No image with space still showing",image=0},
	{id="test6",title="No image with no space",image=0},
	{id="test7",title="Headline is inline"},
	{id="test8",title="Headline is inline left"}
];

styles = {
	"default" = {
		"main" = {
			"margin":"12px 0",
			"border-width": "1px",
			"title" : {
				"font-weight": "bold",
				"padding":"12px",
			},
			"text" : {
				"padding":"8px",
			}


		}
	},
	"test2" = {
		"main" = {
			"htop"=true,
			"image-align":"left",
			"border-width": "0px",
			"title" : {
				"font-weight": "bold",
				"padding":"12px",
				"background-color": "black",
				"color":"white"
			},
			"image": {
				"border-width": "1px",
				"border-color": "teal",
				"padding":"2px"
			}
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
	"test5" = {
		"main" = {
			"image-width":"40%",
			"image-align":"left"			
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
	/* styling for this page only */
	.itemlist {
	  min-width:260px;
	  max-width: 800px;
	  margin:20px auto;
	}

	</style>

<body>

<div class="itemlist">

	<cfloop item="test" array="#tests#">

		<cfset StructAppend(test,{"image"=1},false)>

		<cfoutput>
			
			<cfset local.noimage = test.image>
			
			<div class="item" id="#test.id#">
	
				<h3 class="title">#test.id# #test.title#</h3>

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
		if (NOT StructKeyExists( arguments.styles,local.test.id)) {
			arguments.styles[local.test.id] = {};
		}
		application.utils.fnDeepStructAppend(arguments.styles[local.test.id],arguments.styles.default,false);
		css &= csObj.css(selector="###local.test.id#",styles=arguments.styles[local.test.id],debug=true);
		
	}
	return css;
}

</cfscript>
