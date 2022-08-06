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
param name="url.style" default="fixedboth";
param name="url.media" default="main";

styles = sampleStyles(url.style);

columnsObj = new clikpic._testing.css_tests.columns();

for (setting in columnsObj.settings) {
	if (structKeyExists(url, setting)) {
		styles[url.media][setting] = url[setting];	
	}
}


</cfscript>

<html>
	<head>
		<title>Columns Test</title>

		<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">

		<link rel="stylesheet" type="text/css" href="reset.css">
		<!--- <link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/grids.css"> --->
		<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/columns.css">
		<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/schemes/menus-schemes.css">
		<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/menus.css">
		<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/forms.css">
		<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/title.css">
		
		<style type="text/css">
			
			
			
			.form {
				--form-width:80%;
				--form-row-gap:1px;
				--field-padding: 1px;
				
			}
			/*#content-test {
				position: sticky;
				top:calc(var(--header-height) + var(--body-margin-top) + 60px);
			}

			#sub-test {
				position: sticky;
				top:calc(var(--header-height) + var(--body-margin-top) + 10px);
			}*/

			.overlay {
				

			}

			#topnav > .inner > div.sticky {
				position: sticky;
				top:calc((var(--header-fixed-height) * var(--header-fixed)) + var(--body-margin-top) + var(--overlay-margin-top) );
			}

			div:not(.inner) {
				border:1px solid teal;
				padding:4px;
				margin:2px;
				background-color: white;
			}


		</style>

		<style id="columns_css">
			<cfoutput>#columnsObj.css(styles=styles)#</cfoutput>
		</style>

	</head>

<body>
	

	<div id="ubercontainer">
		
		<div id="header">
			<div class="inner">
				<h1 class="title">Header element</h1>
			</div>
		</div>

		<div id="topnav">
			<div class="inner">
				<div class="sticky">
					<div id="sub-test" class="cs-menu scheme-vertical">
						<ul class="submenu open" style="width: auto;"><li><a class="menu_sample1-2 hasmenu" href="sample1-2.html"><b></b><span>ectetur adipisi</span><i class="icon icon-next openicon"></i></a><ul class="submenu submenu"><li><a class="menu_sample1-3" href="sample1-3.html"><b></b><span>ipsum dolor </span></a></li><li><a class="menu_sample2-3" href="sample2-3.html"><b></b><span>em ipsum dolor </span></a></li><li><a class="menu_sample3-3" href="sample3-3.html"><b></b><span>r sit amet, cons</span></a></li><li><a class="menu_sample4-3" href="sample4-3.html"><b></b><span>lor sit amet, co</span></a></li><li><a class="menu_sample5-3" href="sample5-3.html"><b></b><span>amet, consecte</span></a></li></ul></li><li><a class="menu_sample2-2" href="sample2-2.html"><b></b><span>r sit amet, cons</span></a></li><li><a class="menu_sample3-2 hasmenu" href="sample3-2.html"><b></b><span>olor sit a</span><i class="icon icon-next openicon"></i></a><ul class="submenu submenu"><li><a class="menu_sample1-3" href="sample1-3.html"><b></b><span> ipsum dolor si</span></a></li><li><a class="menu_sample2-3" href="sample2-3.html"><b></b><span>dolor sit ame</span></a></li><li><a class="menu_sample3-3" href="sample3-3.html"><b></b><span>lor sit </span></a></li><li><a class="menu_sample4-3" href="sample4-3.html"><b></b><span>ipsum dolor si</span></a></li><li><a class="menu_sample5-3" href="sample5-3.html"><b></b><span>t amet, co</span></a></li></ul></li></ul>
					</div>
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
							
								<h1>Sub col</h1>

								<p>Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. </p>
								<p>Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. </p>
								<p>Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. Loads of random text. </p>

								
									<h1>sub col text</h1>
									<p>Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. Some random text. </p>
								

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
			"footer-height": "40px"
		},
		"mid" = {"column-layout"="S-MX"},
		"mobile" = {
			"column-layout"="SMX",
			"row-layout": "HF-T-C-F",
			"header-height": "40px"
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
			"row-layout": "HF-TC-B-F"},
		"mobile" = {
			"row-layout": "H-T-C-F",
			"column-layout"="SMX",
			"header-height": "40px"
		}
	};

	settingsOptions["leftnav"] = {
		"main"={
			"column-layout"="S-M-X",
			"header-height": "80px",
			"topnav-width":"200px",
			"row-layout": "H-TC-B-F"			
		},
		"mid" = {"column-layout"="S-MX",
			"row-layout": "H-TC-B-F"},
		"mobile" = {
			"row-layout": "H-T-C-B-F",
			"column-layout"="SMX",
			"header-height": "40px"
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
