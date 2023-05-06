<!--- 

# Columns Test


## Notes


## Details


## History

2022-03-05  THP   Created

--->

<cfscript>


</cfscript>

<html>
	<head>
		<title>Columns Test</title>

		<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">

		<link rel="stylesheet" type="text/css" href="reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/schemes/menus-schemes.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/menus.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/forms.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/title.css">
		<link rel="stylesheet" type="text/css" href="_styles/css-autoschemes.css">
		<link rel="stylesheet" type="text/css" href="_styles/grids.css">
		<style type="text/css">


			
			.form {
				--form-width:80%;
				--form-row-gap:1px;
				--field-padding: 1px;
				
			}
	
			/*#topnav > .inner > div.sticky {
				position: sticky;
				top:calc((var(--header-fixed-height) * var(--header-fixed)) + var(--body-margin-top));
			}

			#columns > div > .inner > div.sticky {
				position: sticky;
				top:calc((var(--header-fixed-height) * var(--header-fixed)) + var(--body-margin-top));
			}*/

			div:not(.inner) {
				border:1px solid teal;
				background-color: white;
				padding:4px;
			}

			body.notopnav #topnav {
				display: none;
			}

			body.nocontenttop #content_top {
				display: none;
			}

			body.nocontenttop #content > .inner {
				grid-template-areas: "content" "content_bottom";
				grid-template-rows: 1fr min-content;
			}

		</style>

	

	</head>

<body class="notopnav nocontenttop col-M-X-S mid-M-SX mob-SMX">

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
					topnav this this supposed to be sticky in some layouts.
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
						
						<div id="maincol_grid" class="scheme-grid">
							<div><p>Maincol grid 1</p></div>
							<div><p>Maincol grid 2</p></div>
							<div><p>Maincol grid 3</p></div>
							<div><p>Maincol grid 4</p></div>
							<div><p>Maincol grid 5</p></div>
							<div><p>Maincol grid 6</p></div>
						</div>

						<div id="maincol_right">
							<h2>Maincol right</h2>
							<p>Any odd text. Any odd text. Any odd text. Any odd text. Any odd text. Any odd text.</p>
						</div>
						<div id="maincol_left">
							<h2>Maincol left</h2>
							<p>Any odd text. Any odd text. Any odd text.</p>
							<p>Any odd text. Any odd text. Any odd text.</p>
						</div> 

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
			<div class="inner scheme-grid scheme-grid-fixedcols">
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

	<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
	<script src="/_assets/js/jquery.throttledresize.js"></script>
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
string function settingsForm() {
	var css= "<form action='columns.cfm'>";
	
	// for (local.setting in ['row-layout','column-layout','header-height','topnav-width','topnav-height','footer-height']) {
	// 	local.val = StructKeyExists(styles[url.media], local.setting) ? styles[url.media][local.setting] : "";
	// 	css &= "<div class='fieldrow'>";
	// 	css &= "<label>#local.setting#</label>";
	// 	css &= "<div class='field'><input name='row-layout' value='#local.val#' /></div>";
	// 	css &= "</div>";	
	
	// }
	css &= "<div class='fieldrow'><input type='submit' value='Update'></div>";
	css &= "</form>";
	return css;
}

</cfscript>
