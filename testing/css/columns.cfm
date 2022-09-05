<!--- 

# Columns Test

Column layout with purely CSS vars. Working really well. Can change column layout for each scope

Also a little experiment with editing overlay on the same page. Not sure this is necessary. Looking
at other people's IFrame solutions there's lots we could do better, e.g. drag and drop, resizing etc. without the need
for this.

## Notes

The content columns are set with a shorthand of SMX. Add dashed to divide columns. Default is S-M-X main, S-MX mid and SMX mobile. All combos should work. If they don't it's a bug.

The uber rows are set with a shorthand of H(F)-T(F|P)-C-B-F(F) where the optional F means fixed. You can optionally place the topnav in the same row as the content, TC. This is the only option for varying the actual grid layout. All bar C can be omitted. 

TP is a pop-up top nav. This functionality is still embryonic. For an expanding topnav in mobile, use the normal value (T) with a state of "closed" (see the documentation (which has't been done yet)). 

## Details


## History

2022-04-05  THP   Now formalised shorthand for uber rows.
2022-03-05  THP   Created

--->

<cfscript>
param name="url.style" default="simple";
param name="url.media" default="main";

styles = sampleStyles(url.style);

settingsObj = new clikpage.settings.settingsObj(debug=1);
contentObj = new clikpage.content.contentObj(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
contentObj.debug = 1;

// columnsObj = new clikpage.content.columns();

// for (setting in columnsObj.settings) {
// 	if (structKeyExists(url, setting)) {
// 		styles[url.media][setting] = url[setting];	
// 	}
// }


</cfscript>

<html>
	<head>
		<title>Columns Test</title>

		<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">

		<link rel="stylesheet" type="text/css" href="reset.css">
		<!--- <link rel="stylesheet" type="text/css" href="/_assets/css/grids.css"> --->
		<link rel="stylesheet" type="text/css" href="/_assets/css/columns.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/schemes/menus-schemes.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/menus.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/forms.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/title.css">
		
		<style type="text/css">
			
			
			
			.form {
				--form-width:80%;
				--form-row-gap:1px;
				--field-padding: 1px;
				
			}
	
			#topnav > .inner > div.sticky {
				position: sticky;
				top:calc((var(--header-fixed-height) * var(--header-fixed)) + var(--body-margin-top));
			}

			#columns > div > .inner > div.sticky {
				position: sticky;
				top:calc((var(--header-fixed-height) * var(--header-fixed)) + var(--body-margin-top));
			}

			div:not(.inner) {
				border:1px solid teal;
				background-color: white;
				padding:4px;
			}


		</style>

		<style id="columns_css">
			<cfoutput>#columnsObj.css(styles=styles)#</cfoutput>
		</style>

	</head>

<body>

	<!--- <cfdump var="#styles#">
	<cfabort>
	 --->

	<div id="ubercontainer">
		
		<div id="header">
			<div class="inner">
				<h1 class="title">Header element</h1>
			</div>
		</div>

		<div id="topnav">
			<div class="inner">
				<div class="sticky">
					topnavthis this supposed to be sticky in some layouts.

					Shouldn't hae a class like this can't test properly.
				</div>
			</div>
		</div>

		<div id="content" class="clear">
			<div class="inner">
				<div id="content_top">
					<div class="inner">
						Content top element
					</div>
				</div>

				<div id="columns">
					<div id="subcol">
						<div class="inner">
							<div class="sticky">	
								
								<h1>Sub col</h1>	
								<p>Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. </p>
								<p>Loads of random text. Loads of random text. LLoads of random text. Loads of random text. Loads of random text. </p>

							</div>

						</div>
					</div>

				
					<div id="maincol">
						<div id="maincol_top">
							<h2>Main col top</h2>
							<cfoutput>#settingsForm()#</cfoutput>
						</div>
						
						<!--- <div id="maincol_grid" class="scheme-grid">
							
						</div>
						<div id="maincol_right">
							<h2>Maincol right</h2>
							<p>Any odd text. Any odd text. Any odd text. Any odd text. Any odd text. Any odd text.</p>
						</div>
						<div id="maincol_left">
							<h2>Maincol left</h2>
							<p>Any odd text. Any odd text. Any odd text.</p>
							<p>Any odd text. Any odd text. Any odd text.</p>
						</div> --->

						<div id="maincol_bottom">
							<h2>Maincol bottom</h2>
							<p>Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. </p>
						</div>
						
					</div>

					<div id="xcol">
						<div class="inner">
							<div id="content-test" class="sticky">
								<h1>X col</h1>
								<p>Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. </p>
							</div>
						</div>	
					</div>
				</div>

				<div id="content_bottom">
					<div class="inner">
						<h1>Content bottom element</h1>
					</div>
				</div>
			</div>	
		</div>

		<div id="bottomnav">
			Bottom navigation
		</div>

		<div id="footer">
			<div class="inner">
				<div id="footer_left">
					<p>This is the footer_left</p>
				</div>
				<div id="footer_middle">
					<p>This is the footer_middle</p>
				</div>
				<div id="footer_right">
					<p>This is the footer_right</p>
				</div>
			</div>
		</div>

	</div>

	<script src="/_common/_scripts/_min/jquery-3.6.0.min.js" type="text/javascript" charset="utf-8"></script>
	<script src="/_common/_scripts/jquery.throttledresize.js"></script>
	<script>
		
		$(document).ready(function() {
			
			var $body = $("body");
			var overlay = false;
			var size = "default";
			var $window = $(window);

			resizeSite($window.width());

			function resizeSite(width) {

				var newSize = "main";

				if (width < 630) {
					newSize = "mobile";
				}
				else if (width < 800) {
					newSize = "mid";
				}
				else  if (width > 1200) {
					newSize = "main";
				}
				if (newSize != size) {
					$body.data("size",size);
					$body.removeClass("size-" + size);	
					$body.addClass("size-" + newSize);	
					console.log("Changing size to ", newSize);
				}

			}

			$(window).on("throttledresize", function( event ) {
				console.log("method 1");
			});

			$(window).on("throttledresize", function( event ) {
				console.log("Resize: ",event.target.innerWidth,event.target.innerHeight);
				resizeSite(event.target.innerWidth);

			});

			
		
		});

	</script>

</body>


</html>


<cfscript>
struct function sampleStyles(name="simple") {

	var settingsOptions = {};

	settingsOptions["simple"] = {

		"main"={
			"row-layout": "H-T-C-B-F",
			"column-layout"="S-M-X",
		},
		"mid" = {"column-layout"="S-MX"},
		"mobile" = {"column-layout"="SMX"}
	};

	settingsOptions["fixedboth"] = {
		"main"={
			"row-layout": "HF-TC-FF",
			"column-layout"="S-M-X",
			"header-height": "80px",
			"footer-height": "40px",
			"topnav-width":"280px"
		},
		"mid" = {"column-layout"="S-MX",
			"topnav-width":"280px"},
		"mobile" = {
			"column-layout"="SMX",
			"row-layout": "HF-T-C-F",
			"header-height": "40px",
			"topnav-width":"auto"
		}
	};

	settingsOptions["fixedhead"] = {
		"main"={
			"column-layout"="S-M-X",
			"header-height": "80px",
			"topnav-width":"200px",
			"row-layout": "HF-TC-B-F"			
		},
		"mid" = {"column-layout"="S-MX",
			"row-layout": "HF-TC-B-F",
			"topnav-width":"auto"
		},
		"mobile" = {
			"row-layout": "HF-T-C-B-F",
			"column-layout"="SMX",
			"header-height": "40px",
			"topnav-width":"auto"
		}
	};

	settingsOptions["leftnav"] = {
		"main"={
			"column-layout"="S-M-X",
			"header-height": "80px",
			"topnav-width":"240px",
			"row-layout": "H-TC-B-F"			
		},
		"mid" = {
			"column-layout"="S-MX",
			"row-layout": "H-TC-B-F",
			"topnav-width":"240px"
		},
		"mobile" = {
			"row-layout": "H-T-C-B-F",
			"column-layout"="SMX",
			"header-height": "40px",
			"topnav-width":"auto"
		}
	};

	return settingsOptions[arguments.name];

}

string function settingsForm() {
	var css= "<form action='columns.cfm'>";
	
	for (local.setting in ['row-layout','column-layout','header-height','topnav-width','topnav-height','footer-height']) {
		local.val = StructKeyExists(styles[url.media], local.setting) ? styles[url.media][local.setting] : "";
		css &= "<div class='fieldrow'>";
		css &= "<label>#local.setting#</label>";
		css &= "<div class='field'><input name='row-layout' value='#local.val#' /></div>";
		css &= "</div>";	
	
	}
	css &= "<div class='fieldrow'><input type='submit' value='Update'></div>";
	css &= "</form>";
	return css;
}

</cfscript>
