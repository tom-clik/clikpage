<!---

# Image Grid testing page

Note that this was just originally our grid testing page even though it had an image grid in it. We might want to do a separate one just for grids.

## Notes

This page originally had a sort of prototype settings form in it. It's been removed from here but it's sort of done in branch 22. Will need a tricky merge now as it's really diverged.

## Status

Now working in standard fashion.

## History

2023-05-01  THP   Wasn't using the cs obj (??).
2023-04-15  THP   Updated to use the grid styling in settingsObj 
2022-03-05  THP   Created

--->

<cfinclude template="images_include.cfm">

<cfscript>
param name="request.rc.test" default='auto';

// Style definition -- see link to css file ibid.
settingsDef = ExpandPath("../styles/testStyles.xml");

tests = [
	{id="auto",title="Auto grid"},
	{id="fixedwidth",title="Columns have set width"},
	{id="fixedcols",title="Fixed number of columns"},
	{id="setcols",title="Specified columns"},
	{id="heights",title="Limit the height of images"},
	{id="captiontop",title="Caption at the top plus some frame styling"},
	{id="overlay",title="Caption overlay"},
	{id="masonry",title="Masonry"},
	{id="carousel",title="Carousel"}
];

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
site={};
image_sets = getImages(site);

styles = settingsObj.loadStyleSettings(settingsDef);

grid_cs = contentObj.new(id="testgrid",type="imagegrid");
grid_cs.data = image_sets;
grid_cs.class = "scheme-grid scheme-#request.rc.test#";

contentObj.settings(content=grid_cs,styles=styles.style,media=styles.media);

css = ":root {\n";
css &= settingsObj.colorVariablesCSS(styles);
css &= settingsObj.fontVariablesCSS(styles);
css &=  "\n}\n";
css &= settingsObj.CSSCommentHeader("Content styling");
css &= contentCSS(grid_cs);
css = settingsObj.outputFormat(css=css,media=styles.media,debug=contentObj.debug);

pageData = contentObj.display(content=grid_cs,data=site.images);
html = pageData.html;
</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/flickity.css">

		<style>
			body {
				background-color: #f3f3f3;
				padding:20px;
			}
			<cfoutput>#css#</cfoutput>
		</style>
	
	</head>

	<body class="body">

		<div>
			
			<cfoutput>#html#</cfoutput>
		
		</div>

		<div>
			<h2>Test mode</h2>
			<form action="imagegrid.cfm">
			<select name="test" onchange="this.form.submit();">
				<cfloop index="test" array="#tests#">
					<cfset selected =request.rc.test eq test.id ? "selected" : "">
					<cfoutput>
					<option #selected# value="#test.id#">#test.title#</option>
					</cfoutput>
				</cfloop>
			</select>
		</div>
		<script src="/_assets/js/jquery-3.4.1.js"></script>
		<script src="/_assets/js/imagesloaded.pkgd.js"></script>
		<script src="/_assets/js/isotope.pkgd.min.js"></script>
		<script src="/_assets/js/masonry-horizontal.js"></script>
		<script src="/_assets/js/flickity.pkgd.min.js"></script>
		<script>
		$( document ).ready( function() {
			<cfoutput>
			#pageData.pagecontent.onready#
			</cfoutput>
		});	
		</script>
	</body>
	
</html>
