<!-- font-style
font-variant
font-weight
font-size/line-height
font-family -->

<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>CSS shorthand test</title>
	<style>
		div {
			--text-font: caption;
		}
		#d1 {
			font: italic small-caps bold 12px/30px Georgia, serif;
		}
		#d2 {
			font: 18px/1em var(--text-font);
		}
		#d3 {
			font: bold 12px/1em var(--text-font);
		}
	</style>
</head>
<body>

	<cfloop index="i" from="1" to="10">
		<cfoutput>
			<div id="d#i#">
				Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. </div>
		</cfoutput>
	</cfloop>

</body>
</html>