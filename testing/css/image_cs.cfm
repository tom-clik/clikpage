<!---

# Image section test



## Synopsis 

Each test case is defined in the array tests. Optional schemes can be assigned here 
as well as specifying whether to have an image or not.

The styles for each test and scheme are defined in css/image_test.css

## Usage

Define tests and styling and preview.

## Status

WIP. 


--->

<cfscript>
// Style definition -- see link to css file ibid.
settingsDef = ExpandPath("_styles/image_test_settings.xml");

// Test definitions
// ----------------------------------------------------------------
// See also testDefaults
tests = [
	{id="test1",title="Height applied to container",containerclass="fixedheight"},
	{id="test2",title="No formatting"},
	{id="test3",title="Stretch",containerclass="fixedheight"},
	{id="test4",title="Cover",containerclass="fixedheight"}
];

testDefaults = {"image":"/images/ozy-dozzy-wlNh84JRb2M-unsplash.jpg",text=lorem(255),class="",caption=0,containerclass=""};
// End Definitions

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
styles = settingsObj.loadStyleSettings(settingsDef);
contentObj.debug = 1;

cs = [=];

for (test in tests) {

	// Add defaults
	StructAppend(test,testDefaults,false)
	
	// create the CS
	cs[test.id] = contentObj.new(
		id=test.id,
		type="image",
		title=test.title,
		image=test.image,
		class = test.class
		);

	contentObj.settings(
		content=cs[test.id],
		styles=styles.style,
		media=styles.media
	);

}

css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");
css &= contentObj.contentCSS(content_sections=cs,styles=styles.style,media=styles.media);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

</cfscript>

<html>

	<title>Image cs testing</title>

	<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
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

	.itemlist > h1 {
		margin:12px;
	}

	.fixedheight {
		height:360px;
	}


	</style>

<body>

<div class="itemlist">

	<cfscript>
	for (test in tests) {
		writeOutput( "<h1>#test.id# #test.title#</h1>");
		writeOutput( "<div id='testwrap#test.id#' class='#test.containerclass#'>");
		pageData = contentObj.display(content=cs[test.id]);
		writeOutput( pageData.html);
		writeOutput( "</div>" );
	}
	</cfscript>
	
</div>

</body>

</html>

<cfscript>
/**
 * Generate length of filler text
 */
string function lorem(len) {
	return left(
		"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		, arguments.len);

}
</cfscript>