<!---

# Grids testing page


## Notes

This page originally had a sort of proto type settings form in it. This is here, commented out


## Status

Broken settings form but we are planning to do this properly with the styleDefs

## History

2023-04-15  THP   Updated to use the grid styling in settingsObj 
2022-03-05  THP   Created

--->

<cfscript>
//numeric or blank
param name="url.maximages" default="";
request.rc.test = 'auto'; /* fixedwidths | fixedcols */

settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
images = getImages();

maximagescalc = url.maximages eq "" ? arrayLen(images) : url.maximages;

styles = settingsObj.loadStyleSettings(ExpandPath("../styles/testStyles.xml"));

grid_cs = contentObj.new(id="testgrid",type="imagegrid");
grid_cs.class = "scheme-#request.rc.test#";

// WILLDO: remove these comments once we have introduced a proper settings editing system.
// // for page editing -- doesn't seem right. Where are the defaults? use the contentObj for defaults etc.
// settings = {};
// contentObj.contentSections["imagegrid"].updateDefaults();
// settings = contentObj.contentSections["imagegrid"].defaultStyles;

// for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
// 	if (structKeyExists(url, setting) AND url[setting] != "") {
// 		styles.content["testgrid"]["main"][setting] = url[setting];
// 		settings[setting] = url[setting];
// 	}
// 	else if (StructKeyExists(styles.content["testgrid"]["main"], setting)) {
// 		settings[setting] = styles.content["testgrid"]["main"][setting];
// 	}
// 	else if (NOT structKeyExists(settings, setting)) {
// 		settings[setting] = "";
// 	}
// }

// end page editing

contentObj.settings(content=grid_cs,styles=styles.style,media=styles.media);
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
			.duumyy {
				grid-template-columns: repeat(var(--grid-fit), minmax(var(--grid-width), var(--grid-max-width)));
			}

			
		</style>
		<style id="dynamic_css">
			<cfoutput>#css#</cfoutput>
		</style>
	
	</head>

	<body class="body">

		<!--- <div id="panel">
			<h2>Settings</h2>
			<form action="grids.cfm">
				
				<cfoutput>#myvar#</cfoutput>
				
				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div> --->

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

// string function settingsForm() {
// 	var retval = "";
// 	retval &= "<fieldset>";
// 	for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
// 		settingDef = contentObj.contentSections["imagegrid"].styleDefs[setting];
// 		retval &= "<label title='#encodeForHTMLAttribute(settingDef.description)#'>#settingDef.name#</label>";
// 		switch(settingDef.type) {
// 			case "dimension":
// 			case "dimensionlist":
// 			case "integer":
// 				retval &= "<input name='#setting#' value='#settings[setting]#'>";
// 				break;
// 			case "boolean":
// 			local.selected = isBoolean(settings[setting]) AND settings[setting] ? " selected": "";
// 				retval &= "<div class='field'><input type='checkbox' name='#setting#' #local.selected#value='1'>Yes</div>";
// 				break;
// 			case "list":
// 				options = contentObj.options("imagegrid",setting);
// 				retval &= "<select name='#setting#'>";
// 				for (mode in options) {
// 					try {
// 						selected = mode.value eq settings[setting] ? " selected": "";
// 						retval &= "<option value='#mode.value#' #selected# title='#encodeForHTMLAttribute(mode.description)#'>#encodeForHTML(mode.name)#</option>";
// 					}
// 					catch (any e) {
// 						local.extendedinfo = {"tagcontext"=e.tagcontext,mode=mode};
// 						throw(
// 							extendedinfo = SerializeJSON(local.extendedinfo),
// 							message      = "Error:" & e.message, 
// 							detail       = e.detail
// 						);
// 					}
// 				}
// 				retval &= "</select>";
// 				break;

// 		}
		
// 	}
// 	retval &= "</fieldset>";
// 	return retval;
// }
</cfscript>
