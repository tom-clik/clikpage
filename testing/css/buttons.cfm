<!---

# Button content section test


## Synopsis 

## Status

We've only just begun 

## TODO:

--->

<cfscript>
/* to do: put this into a common include file */
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

styles = settingsObj.loadStyleSheet(ExpandPath("button_test_styles.xml"));
contentObj.debug = 1;

tests = [
	{id="test1",title="No formatting",class=""}
];

cs = [=];

for (test in tests) {

	StructAppend(test,{},false);
	
	cs[test.id] = contentObj.new(
		id=test.id,
		title=test.title,
		content=test.title,
		class = "scheme-button",
		link = "buttons.cfm",
		type = "button"
		);
	// NB problem with order of schemes. This is in elegant but necessary at the minute
	if (structKeyExists(test, "class")) {
		cs[test.id].class = ListAppend(cs[test.id].class,test.class," ");
	}
}

css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");
css &= contentObj.contentCSS(content_sections=cs,styles=styles.content,media=styles.media);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

// writeDump(cs.test1);

// WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>

<html>

	<title>Buttons cspositions</title>

	<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/text.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/fonts/fonts_local.css">	
	<style>

	<cfoutput>#css#</cfoutput>
	
	/* styling for this page only */
	.itemlist {
	  min-width:260px;
	  max-width: 560px;
	  margin:20px auto;
	}

	</style>

<body>

<div class="itemlist">

	<cfscript>
	for (id in cs) {
		writeOutput( "<h1> test #id#</h1>");
		pageData = contentObj.display(content=cs[id]);
		
		writeOutput( pageData.html);
		
		// if (id eq "test3") {
		// 	writeDump(cs[id].settings);
		// }
	}
	</cfscript>
	
</div>

</body>

</html>

