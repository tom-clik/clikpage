<!---

# Grids testing page

See the documentation /technotes/css/grids.md for overview

## Notes

This needs changing to be a grids testing page and then a separate one for image grids with the photo
captions etc

Also the whole grids component is WIP. This needs updating to use the standard one not the one in this folder
which was canobalised from Clikpic.


## Status

Working ok. Named positions doesn't work. Otherwise ok. Flex options meaningless with such big images but they ware working.

## TODO 

-[ ] Same as the others -- needs formalising with move to clikpage.content components

## History

2022-03-05  THP   Created

--->

<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
grid_cs = contentObj.new(id="testgrid",type="imagegrid");

// for page editing -- doesn't seem right. Where are the defaults? use the contentObj for defaults etc.
settings = {};
contentObj.contentSections["imagegrid"].updateDefaults();
settings = contentObj.contentSections["imagegrid"].defaultStyles;

for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
	if (structKeyExists(url, setting) AND url[setting] != "") {
		styles.content["testgrid"]["main"][setting] = url[setting];
		settings[setting] = url[setting];
	}
	else if (StructKeyExists(styles.content["testgrid"]["main"], setting)) {
		settings[setting] = styles.content["testgrid"]["main"][setting];
	}
	else if (NOT structKeyExists(settings, setting)) {
		settings[setting] = "";
	}
}

// end page editing


contentObj.settings(content=grid_cs,styles=styles.content,media=styles.media);

css = contentObj.settingsObj.outputFormat(css=":root {\n" & contentObj.settingsObj.colorVariablesCSS(styles) & "}\n",media=styles.media);
css &= contentObj.css(grid_cs);

class="";

// abort;
try {
	myvar = settingsForm();
}
catch (any e) {
	writeDump(e);
	abort;
}
			
</cfscript>

<cfparam name="url.maximages" default=""><!--- numeric or blank --->

<cfset images = getImages()>
<cfset maximagescalc = url.maximages eq "" ? arrayLen(images) : url.maximages>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/navbuttons.css">

		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
		<style>
			body {
				
				background-color: #f3f3f3;
			}

			#testgrid {
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
			
		</style>
		<style id="dynamic_css">
			<cfoutput>#css#</cfoutput>
		</style>
		
		<style>
			
			#testgrid.bottom {
				--max-width:auto;
				--max-height:auto;
				--align-frame:center;
				--justify-frame:end;
				--image-grow:0;
				--frame-flex-direction:column-reverse;
/*				--object-fit:cover;*/
			}
			#testgrid.bottom .image {
				margin-top: auto;
				margin-bottom:0;
			}

			#testgrid.bottom.bottom_above .image {
				margin-top: 0;
				margin-bottom:0;
			}

			#testgrid.center {
				--max-width:auto;
				--max-height:auto;
				--align-frame:center;
				--justify-frame:center;
				--image-grow:0;
				--frame-flex-direction:column;
/*				--object-fit:cover;*/
			}
			#testgrid.center .image {
				margin-top: 0;
				margin-bottom:0;
			}

			#testgrid.above {
				--max-width:auto;
				--max-height:auto;
				--align-frame:center;
				--justify-frame:start;
				--image-grow:0;
				--frame-flex-direction:column-reverse;
/*				--object-fit:cover;*/
			}
			#testgrid.above .image {
				margin-top: 0;
				margin-bottom:0;
			}

			#testgrid.below {
				--max-width:auto;
				--max-height:auto;
				--align-frame:center;
				--justify-frame:start;
				--image-grow:0;
				--frame-flex-direction:column;
/*				--object-fit:cover;*/
			}
			#testgrid.below .image {
				margin-top: 0;
				margin-bottom:0;
			}

			#testgrid.overlay {
				--justify-frame:start;
				--justify-caption:center;
			}
			#testgrid.overlay .caption {
				position: absolute;
				top:0;
				left:0;
				width: 100%;
				height: 100%;
				opacity: 0;
				background-color: black;
				color:white;
				text-transform: uppercase;
				font-weight: bold;
			}
			#testgrid.overlay .frame:hover .caption {
				opacity: 1;
				background-color: rgba(0,0,0,0.6);
			}

			#testgrid.overlay .image {
				margin-top: 0;
				margin-bottom:0;
			}
		</style>
	
	</head>

	<body class="body">

		<div id="panel">
			<h2>Settings</h2>
			<form action="grids.cfm">
				
				<cfoutput>#myvar#</cfoutput>

				
				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div>
		<div>
			
			<cfoutput>		
				<div id="testgrid" class="grid cs-imagegrid #class#">
				
				<cfloop index="i" from="1" to="#maximagescalc#">
					<cfset image = images[i]>
					<a class="frame" href='/images/#image#'>
						
						<div class="image">
							<img src="/images/#image#" />
						</div>
						
						<div class="caption">#ListFirst(image,"-")# #ListGetAt(image,2,"-")#</div> 
					</a>
				</cfloop>
					
				</div>
			</cfoutput>
					
		</div>

		<cfdump var="#grid_cs#">
		
	</body>
	
</html>

<cffunction name="getImages">
	<cfreturn [
		"emil-widlund-Fyxq6Paxskw-unsplash_thumb.jpg",
		"harley-davidson-XnhmpwEbv5I-unsplash_thumb.jpg",
		"joshua-fernandez-Q4SCuuKtSDU-unsplash_thumb.jpg",
		"larisa-birta-h9kODfOsyOU-unsplash_thumb.jpg",
		"mak-ipkw44S_LHM-unsplash_thumb.jpg",
		"nate-johnston-cK_1Q_e5FfU-unsplash_thumb.jpg",
		"nathan-dumlao-ljbqCDlAhjY-unsplash_thumb.jpg",
		"emil-widlund-Fyxq6Paxskw-unsplash_thumb.jpg",
		"harley-davidson-XnhmpwEbv5I-unsplash_thumb.jpg",
		"joshua-fernandez-Q4SCuuKtSDU-unsplash_thumb.jpg",
		"larisa-birta-h9kODfOsyOU-unsplash_thumb.jpg",
		"mak-ipkw44S_LHM-unsplash_thumb.jpg",
		"nate-johnston-cK_1Q_e5FfU-unsplash_thumb.jpg",
		"nathan-dumlao-ljbqCDlAhjY-unsplash_thumb.jpg"
			]>

</cffunction>

<cfscript>
string function settingsForm() {
	var retval = "";
	retval &= "<fieldset>";
	for (setting in contentObj.contentSections["imagegrid"].styleDefs) {
		settingDef = contentObj.contentSections["imagegrid"].styleDefs[setting];
		retval &= "<label title='#encodeForHTMLAttribute(settingDef.description)#'>#settingDef.name#</label>";
		switch(settingDef.type) {
			case "dimension":
			case "dimensionlist":
			case "integer":
				retval &= "<input name='#setting#' value='#settings[setting]#'>";
				break;
			case "boolean":
			local.selected = isBoolean(settings[setting]) AND settings[setting] ? " selected": "";
				retval &= "<div class='field'><input type='checkbox' name='#setting#' #local.selected#value='1'>Yes</div>";
				break;
			case "list":
				options = contentObj.options("imagegrid",setting);
				retval &= "<select name='#setting#'>";
				for (mode in options) {
					try {
						selected = mode.value eq settings[setting] ? " selected": "";
						retval &= "<option value='#mode.value#' #selected# title='#encodeForHTMLAttribute(mode.description)#'>#encodeForHTML(mode.name)#</option>";
					}
					catch (any e) {
						local.extendedinfo = {"tagcontext"=e.tagcontext,mode=mode};
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
