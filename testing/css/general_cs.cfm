<!---
TODO: broken

# General content section test

A general content section is just a panel with a title, image and text wrap. 
Adjust layout of general cs using template positions.

If you just want a simple item, use a text, title, or image content section.


## Synopsis 

HTML is 

```html
<div class="item">

	<h3 class="title">Headline before image</h3>

	<div class="imageWrap">

		<img src="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg">
		 <div class="caption">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod 
			tempor incididunt ut </div>
	</div>

	<div class="textWrap">
		<p>
			Headline set to show before. Image set to show on left, column width is default 40%</p>
			
	</div>

</div>

```
htop
image-width
image-align
item-gridgap
```

## Status

Working really well. 

## TODO:

The image space functionality is missing. This is for when we have a listing of items
and the styling applies to all of them. Those without an image can show the image space or 
not. This will require a class appended to the individual item t indicate it doesn't
have an image.

--->

<cfscript>
/* to do: put this into a common include file */
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);

styles = settingsObj.loadStyleSheet(ExpandPath("general_test_styles.xml"));
contentObj.debug = 1;
/*---*/

tests = [
	{id="test1",title="No formatting",class=""},
	{id="test2",title="Headline before image except in mobile",caption=1},
	{id="test3",title="Larger image with scheme 'panels'",class="scheme-panels"},
	{id="test4",title="Larger image left",caption=1},
	{id="test5",title="No image with space still showing",image=false},
	{id="test6",title="No image with no space [broken]",text="This won't work for listings. We need an option to show some with images and some without with the same styling",image=false},
	{id="test7",title="Headline is inline"},
	{id="test8",title="Headline is inline left"},
	{id="test9",title="Flow left",text=lorem(1000)},
	{id="test10",title="Flow right",text=lorem(1000)}
];

cs = [=];

for (test in tests) {

	StructAppend(test,{"image":true,text=lorem(255),class="scheme-item scheme-title",caption=0},false)
	
	cs[test.id] = contentObj.new(
		id=test.id,
		title=test.title,
		content=test.text,
		class = test.class,
		link = "general_cs.cfm"
		);
	if (NOT structKeyExists(test,"image") OR test.image) {
		cs[test.id]["image"]="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg";
		if (test.caption) {
			cs[test.id]["caption"]="lorem ipsum";
		}
		

	}
	// NB problem with order of schemes. This is in elegant but necessary at the minute
	if (structKeyExists(test, "class")) {
		cs[test.id].class = ListAppend(cs[test.id].class,test.class," ");
	}
	// contentObj.settings(cs[test.id],styles.content,styles.media);

}

css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");
css &= contentObj.contentCSS(content_sections=cs,styles=styles.content,media=styles.media);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

// writeDump(cs.test3);

// WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>

<html>

	<title>General cs with grid positions</title>

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



<cfscript>
function lorem(len) {
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