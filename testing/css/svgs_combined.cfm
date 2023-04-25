<cfscript>
/*
Fun with bootstrap icons. 

The actual file is 1mb so we need to do something to select only the ones we want

## Downloading icons

Ensure you have downloaded the whole "sprite" (bootstrap-icons.svg). Don't put them in the repo.

## Synopsis

The file is XML so we can read it and return an array of icons details.

## CDN

This seems to be broken. Can't get the CORS settings to work.

*/
mode = "cdn";// local|cdn -- cdn will show individual files.
path = "graphics/bootstrap-icons.svg";
cdn = "https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.2/icons/";
icons = readFile(ExpandPath(path));

// Read in the file to get list of icons
array function readFile(filename) {
	
	local.res = [];
	
	if (! fileExists(arguments.filename)) {
		throw(message="File #arguments.filename# not found. Please download the bootstrap icons (see notes)");
	}
	var data = FileRead(arguments.filename);
	var coldSoup = new coldsoup.coldSoup();

	var doc = coldSoup.parseXML(data);
	var symbols = doc.select("symbol");
	for (var symbol in symbols) {

		ArrayAppend(local.res,{"id":symbol.attr("id"),"html":symbol.outerHtml()});
	}
	
	return local.res;
	
}

function displayCode(html) {
	WriteOutput("<pre>" & HtmlEditFormat(arguments.html) & "<pre>");
}



</cfscript>


<!DOCTYPE html>
<html>
<head>
	<title>Combined SVGs</title>
	
	<meta charset="UTF-8">

	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">

	<style>
	:root {
		--icon-width:24px;
		--icon-height:24px;
		--icon-fill:black;
		--icon-bg: transparent;
	}
	.scheme-small {
		--mingridcol: 80px;
	}

	.cell {
		padding:8px;
		display: flex;
		flex-direction: column;
		grid-gap: 4px;
		align-items: center;
		justify-content: center;

	}

	.cell h2 {
		font-size:12px;
		text-align: center;
		height:80px;
	}

	.icon {
		width:var(--icon-width);
		height:var(--icon-height);
		background-color:var(--icon-bg);
	}

	svg {
		display: inline-block;
		width:100%;
		height:100%;		
		fill:var(--icon-fill);		
	}

	.smallblue {
		--icon-fill:#333;
	}

	.smallblue .icon:hover {
		--icon-fill:magenta;
	}

	.bigmagenta .icon {
		padding:4px;
		--icon-bg: magenta;
		--icon-fill:white;
		--icon-width:52px;
		--icon-height:52px;
		border-radius: 4px;
	}

	.bigmagenta .icon:hover {
		--icon-fill:turquoise;
	}
	</style>


</head>
<body>

<h2 class="open">Testing Combined SVGs</h2>

<p>Here all the images come from the same file. Don't use this in production. It is 1mb.</p>

<div class="smallblue scheme-grid scheme-small">
<cfscript>
count = 1;
for (img in icons) {

	iconURL = mode eq "local"? "#path####img.id#" : "#cdn##img.id#.svg###img.id#";
	writeOutput("<div class='cell'><div class='icon'><svg viewBox='0 0 16 16'><use xlink:href='#iconurl#'></svg></div><h2>#img.id#</h2></div>");
	count++;	
	if (count gt 20) {
		break;
	}
}
</cfscript>
</div>

</body>

</html>

