<cfscript>
/* Test apply scrollbar plug in to whole page

TODO: style this up to use vars.

*/
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
			--secondary-gray2: #bbbbbe;
			--secondary-gray3: #9e9e9e;
			padding:0px;
			--scrollbar-width:6px
		}

		#ubercontainer {
			height:100vh;
			overflow: hidden;
		}

		.content {
			max-width: 800px;
			padding:12px;
			margin:0 auto;
		}
		
		.mCSB_draggerContainer {
			margin:12px 0;
		}

		.mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {
			width:auto;
			background-color: var(--secondary-gray2);
			width:var(--scrollbar-width);
		}

		.mCSB_scrollTools .mCSB_dragger.mCSB_dragger_onDrag .mCSB_dragger_bar, 
		.mCSB_scrollTools .mCSB_dragger:hover .mCSB_dragger_bar { 
			background-color: var(--secondary-gray3);
		}

		.mCSB_scrollTools .mCSB_draggerRail {
			background-color:white;
			width:var(--scrollbar-width);
		}
	</style>
</head>
<body>

<div id="ubercontainer">
	<div class="content">
		<cfloop index="i" from="1" to="30">
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
<script src="/_assets/js/jquery.mCustomScrollbar.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript">
	$(document).ready(function() {
		$("#ubercontainer").mCustomScrollbar();
	});
</script>


</body>
</html>

