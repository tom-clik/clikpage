<cfscript>
/**
 * Fun with bootstrap icons. The actual file is 1mb so we need to do something to select only the ones
 * we want
 * 
 */

array function readFile(path) {
	
	local.res = [];

	var data = FileRead(ExpandPath(arguments.path));
	var coldSoup = new coldSoup();

	var doc = coldSoup.parseXML(FileRead(ExpandPath(arguments.path)));
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

<p>SVGs <em>can</em> be styled with CSS if you use the <code>use</code> syntax. The html for both these elements is the same, just copied</p>

<div class="smallblue scheme-grid scheme-small">
<cfscript>
path = "graphics/bootstrap-icons.svg";
for (img in readFile(path)) {
	writeOutput("<div class='cell'><div class='icon'><svg viewBox='0 0 16 16'><use xlink:href='#path####img.id#'></svg></div><h2>#img.id#</h2></div>");

}
</cfscript>
</div>

</body>

</html>

