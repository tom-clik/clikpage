<!---

# Button content section test


## Synopsis 

## Status

We've only just begun 

## TODO:

Add all the tests

--->

<cfscript>
/* to do: put this into a common include file */
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

styles = settingsObj.loadStyleSettings(ExpandPath("button_test_styles.xml"));
contentObj.debug = 1;

tests = [
	{id="test1",title="No formatting"},
	{id="test2",title="Right"},
	{id="test3",title="No icon"}
];

cs = [=];
html = "";

css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");

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

	contentObj.settings(content=cs[test.id],styles=styles.style,media=styles.media);

	pageData = contentObj.display(content=cs[test.id]);
	html &= pageData.html;

}

css &= contentObj.contentCSS(content_sections=cs,styles=styles.style,media=styles.media);

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
	  display: flex;
	  flex-direction: column;
	  grid-gap: 4px;
	}

	</style>

<body>

<div class="itemlist">

	<cfscript>
	writeOutput( html);
	</cfscript>
	
</div>

</body>

</html>

