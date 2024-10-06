<cfscript>
/* Test custom scrollbar plug in */
</cfscript>

<!DOCTYPE html>
<html>
<head>
	<title>Scrollbar test</title>
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<link rel="stylesheet" href="/_assets/css/text.css">
	<link rel="stylesheet" href="/_assets/css/jquery.mCustomScrollbar.css">
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
			padding:120px;
		}

		#ubercontainer {
			max-width:800px;
			
			border:1px solid slategray;
			background-color: #cecece;
			padding:12px;
		}

		.content {
			height:260px;
		}
		@media only screen and (max-width: 600px) {
			body {
				padding:8px;
			}
		}
	</style>
</head>
<body>

<div id="ubercontainer">
	<div class="content">
		<cfloop index="i" from="1" to="20">
		<p>
		Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
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
<script src="/_assets/js/jquery.mCustomScrollbar.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript">
	$(document).ready(function() {
		$(".content").mCustomScrollbar();
	});
</script>


</body>
</html>

