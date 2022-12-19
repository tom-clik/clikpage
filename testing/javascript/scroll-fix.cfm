<cfscript>
/*
Testing scroll fix
*/
</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>Scrollbar test</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/text.css">
	
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<style>
		body {
			height:100%;
			--title-font: 'Open Sans';
			--title-font-size: 140%;
			--title-font-weight: 300;
			--border-color:#1B02A3;
			--accent-color:#DC00FE;
			--secondary-gray2: #bbbbbe;
			--secondary-gray3: #9e9e9e;
			padding:0px;
			--scrollbar-width:6px
			background-color:moccasin;
		}

		#ubercontainer {
			max-width: 1200px;
			margin: 0 auto;

		}

		#header {
			height:160px;
			padding:40px;
			background-color: hotpink;
		}

		#topnav {
			padding:40px;
			background-color: turquoise;
		}

		body.scroll #topnav {
			position:fixed;
			padding:20px;
			top:0;
			font-style: italic;
		}

		.content {
			background-color: white;
			margin:0 auto;
		}
		

	</style>
</head>
<body>

<div id="ubercontainer">
	<div id="header">
		<h1>Header scrolls off</h1>
	</div>
	<div id="topnav">
		<p>This should stay in place</p>
	</div>
	<div id="content">
		<cfloop index="i" from="1" to="20">
		<p>
		<cfoutput><strong>#i#</strong></cfoutput> Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
		tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
		quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
		consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
		cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
		proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
		</p>
		</cfloop>

	</div>
</div>

<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript">
	$(document).ready(function() {
		
		// check where the shoppingcart-div is 
		$scrollfixed = $('#topnav'); 
		var offset = $scrollfixed.offset();
		var width = $scrollfixed.outerWidth();
		var $body = $('body');  

		$(window).on("scroll", function () {  
			var scrollTop = $(window).scrollTop(); // check the visible top of the browser  
			if (offset.top < scrollTop) {
				$body.addClass('scroll');
				$scrollfixed.css("width",width + "px");
			}
			else {
				$body.removeClass('scroll');  
			}
		});
	});
	
</script>


</body>
</html>

