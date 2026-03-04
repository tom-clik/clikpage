<!--

Can hide the header and footer for a print page by using
@page margin: 0 

-->


<!DOCTYPE html>
<html lang="en">
<head>
	<title>Print tests</title>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="/_assets/css/reset.css">
	<style>
		
		@media print {
			@page { 
				margin: 0; 
			}
			body {
				padding:24px;
			}
		}

	</style>
</head>

<body>
	<div id="uberContainer"> 
	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
	tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
	quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
	consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
	cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
	proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
	</div>
</body>
</html>








