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
param name="request.rc.medium" default='main';

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

for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
	if (structKeyExists(url, setting) AND url[setting] != "") {
		styles.style[grid_cs.id][request.rc.medium][setting] = url[setting];
	}
}

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
form_html = settingsForm(settings=grid_cs.settings.main);
</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/flickity.css">
		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
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

		<div id="settings_panel" class="settings_panel modal">

			
			<form action="imagegrid.cfm">

				<h2>Test mode</h2>
				<select name="test">
					<cfloop index="test" array="#tests#">
						<cfset selected =request.rc.test eq test.id ? "selected" : "">
						<cfoutput>
						<option #selected# value="#test.id#">#test.title#</option>
						</cfoutput>
					</cfloop>
				</select>

				<cfoutput>#form_html#</cfoutput>
					
				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div>

		<div id="settings_panel_open"><div class="button auto"><a href="#settings_panel.open">Settings</a></div></div>

		<script src="/_assets/js/jquery-3.4.1.js"></script>
		<script src="/_assets/js/imagesloaded.pkgd.js"></script>
		<script src="/_assets/js/isotope.pkgd.min.js"></script>
		<script src="/_assets/js/masonry-horizontal.js"></script>
		<script src="/_assets/js/flickity.pkgd.min.js"></script>
		<script src="/_assets/js/jquery.modal.js"></script>
		<script src="/_assets/js/jquery.autoButton.js"></script>
		<cfset pageData.pagecontent.onready &= "
		$(document).ready(function() {
			$('##settings_panel').modal({modal:0,draggable:1});
			$('.button').button();
		});">
		
		<script>
		$( document ).ready( function() {
			<cfoutput>
			#pageData.pagecontent.onready#
			</cfoutput>
		});	
		</script>
	</body>
	
</html>

<cfscript>

string function settingsForm(required struct settings) {
	var retval = "";
	retval &= "<fieldset>";
	for (local.setting in contentObj.contentSections["imagegrid"].styleDefs) {
		local.settingDef = contentObj.contentSections["imagegrid"].styleDefs[local.setting];
		local.description = local.settingDef.description? : "No description";

		retval &= "<label title='#encodeForHTMLAttribute(local.description)#'>#local.settingDef.name#</label>";
		local.value = arguments.settings[local.setting] ? : "";
		
		switch(local.settingDef.type) {
			case "dimension":
			case "dimensionlist":
			case "text":
			case "integer":
				retval &= "<input name='#local.setting#' value='#local.value#'>";
				break;
			case "boolean":
			local.selected = isBoolean(local.value) AND local.value ? " selected": "";
				retval &= "<div class='field'><input type='checkbox' name='#local.setting#' #local.selected#value='1'>Yes</div>";
				break;
			case "list":
				local.options = contentObj.options("imagegrid",local.setting);
				retval &= "<select name='#local.setting#'>";
				for (local.mode in local.options) {
					try {
						local.selected = local.mode.value eq local.value ? " selected": "";
						retval &= "<option value='#local.mode.value#' #local.selected# title='#encodeForHTMLAttribute(local.mode.description)#'>#encodeForHTML(local.mode.name)#</option>";
					}
					catch (any e) {
						local.extendedinfo = {"tagcontext"=e.tagcontext,mode=local.mode};
						throw(
							extendedinfo = SerializeJSON(local.extendedinfo),
							message      = "Error:" & e.message, 
							detail       = e.detail
						);
					}
				}
				retval &= "</select>";
				break;

		}
		
	}
	retval &= "</fieldset>";
	return retval;
}
</cfscript>