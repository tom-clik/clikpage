<!---
# Grids testing page


## Notes

This page has been renamed imagegrid. This is being kept only to preserve the work done in branch 22.

## Status

Broken settings form but we are planning to do this properly with the styleDefs

## History

2023-04-15  THP   Updated to use the grid styling in settingsObj 
2022-03-05  THP   Created

--->

<cfscript>
//numeric or blank
param name="url.maximages" default="";
request.rc.test = 'auto'; /* auto | fixedwidths | fixedcols */

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
images = getImages();

maximagescalc = url.maximages eq "" ? arrayLen(images) : url.maximages;

styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));

grid_cs = contentObj.new(id="testgrid",type="imagegrid");
grid_cs.class = "scheme-#request.rc.test#";

for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
	if (structKeyExists(url, setting) AND url[setting] != "") {
		styles.style["testgrid"]["main"][setting] = url[setting];
	}
}

contentObj.settings(content=grid_cs,styles=styles.style,media=styles.media);

// end page editing


css = contentCSS(grid_cs);

// try {
// 	myvar = settingsForm();
// }
// catch (any e) {
// 	writeDump(e);
// 	abort;
// }

</cfscript>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">
		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
		<style>
			body {
				background-color: #f3f3f3;
				padding:20px;
			}

			.button {
				padding:4px 8px;
				border:1px solid #333;
				background-color:white;
				margin-top:12px;
			}

			.button:hover {
				background-color:#efefef;
			}

			img {
				max-width: 100%;
				height:auto;
			}
			
			
		</style>
		<style id="dynamic_css">
			<cfoutput>#css#</cfoutput>
		</style>
	
	</head>

	<body class="body">

		<div id="settings_panel" class="settings_panel modal">
			<h2>Settings</h2>
			<form action="grids.cfm">
				
				<cfoutput>#settingsForm(settings=grid_cs.settings.main)#</cfoutput>
				
				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div>

		<div id="settings_panel_open"><div class="button auto"><a href="#settings_panel.open">Settings</a></div></div>

		<div>
			
			<cfoutput>		
				<div id="testgrid" class="cs-grid scheme-#request.rc.test#">
				
				<cfloop index="i" from="1" to="#maximagescalc#">
					<cfset image = images[i]>
					<a class="frame">
						
						<div class="image">
							<img src="/images/#image.image_thumbnail#" />
						</div>
						
						<div class="caption">#image.caption#</div>

					</a>
				</cfloop>
					
				</div>
			</cfoutput>
					
		</div>

		<cfoutput>
			
			<div class="code code_css">
				<pre>#css#</pre>
			</div>
		</cfoutput>
		
		<script src="/_assets/js/jquery-3.4.1.js" type="text/javascript" charset="utf-8"></script>
		<script src="/_assets/js/jquery.modal.js"></script>
		<script src="/_assets/js/jquery.autoButton.js"></script>
		<script>
		$(document).ready(function() {
			$('#settings_panel').modal({modal:0,draggable:1});
			$(".button").button();
		});
		</script>
	</body>
	
</html>

<cfscript>
array function getImages() {
	myXML = application.utils.fnReadXML(ExpandPath("../images/photos.xml"));
	return application.XMLutils.xml2Data(myXML);
}

function contentCSS(required struct cs) {
	local.site_data = { "#arguments.cs.id#" = arguments.cs};
	local.css = contentObj.contentCSS(styles=styles, content_sections=local.site_data, media=styles.media);
	return local.css;
}

string function settingsForm(required struct settings) {
	var retval = "";
	retval &= "<fieldset>";
	for (local.setting in contentObj.contentSections["imagegrid"].styleDefs) {
		local.settingDef = contentObj.contentSections["imagegrid"].styleDefs[local.setting];
		retval &= "<label title='#encodeForHTMLAttribute(local.settingDef.description)#'>#local.settingDef.name#</label>";
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

