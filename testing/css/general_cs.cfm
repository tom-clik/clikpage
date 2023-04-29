<!---

# General content section test

A general content section is a panel with a title, image and text. The layout 
can be changed using grid positions, or in the case of a flow layout using float
positioning on the image. 

## Synopsis 

Each test case is defined in the array tests. Optional schemes can be assigned here 
as well as specifying whether to have an image or not.

The styles for each test and scheme are defined in css/general_test.css

## Usage

Defined tests and styling and preview.

## Status

Working. 


--->

<cfscript>
// Style definition -- see link to css file ibid.
settingsDef = ExpandPath("_styles/general_test_settings.xml");

// Test definitions
// ----------------------------------------------------------------
// See also testDefaults
tests = [
	{id="test1",title="No formatting",class=""},
	{id="test2",title="Headline before image except in mobile",caption=1},
	{id="test3",title="Larger image with scheme 'panels'",class="scheme-item scheme-title scheme-panels"},
	{id="test4",title="Larger image left",caption=1},
	{id="test5",title="No image with space still showing",image=false},
	{id="test6",title="No image with no space [broken]",text="This won't work for listings. We need an option to show some with images and some without with the same styling",image=false},
	{id="test7",title="Headline is inline"},
	{id="test8",title="Headline is inline left"},
	{id="test9",title="Flow left",text=lorem(1000)},
	{id="test10",title="Flow right",text=lorem(1000)}
];

testDefaults = {"image":true,text=lorem(255),class="scheme-item scheme-title",caption=0};
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
		title=test.title,
		content=test.text,
		class = test.class,
		link = "general_cs.cfm"
		);

	if (test.image) {
		cs[test.id]["image"]="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg";
		if (test.caption) {
			cs[test.id]["caption"]="lorem ipsum";
		}
	}
	
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

	<title>General cs testing</title>

	<meta name="VIEWPORT" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
	<link rel="stylesheet" type="text/css" href="/_assets/css/panels.css">
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

	</style>

<body>

<div class="itemlist">

	<cfscript>
	for (id in cs) {
		writeOutput( "<h1> Test #id#</h1>");
		pageData = contentObj.display(content=cs[id]);
		writeOutput( pageData.html);
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