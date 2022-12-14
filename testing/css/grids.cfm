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
settingsObj = new clikpage.settings.settingsObj(debug=1);
contentObj = new clikpage.content.contentObj(settingsObj=settingsObj);
contentObj.debug = 1;
styles = settingsObj.loadStyleSheet(ExpandPath("../styles/testStyles.xml"));
grid_cs = contentObj.new(id="grid",type="grid");


// for page editing -- doesn't seem right. Where are the defaults? use the contentObj for defaults etc.
settings = {};

for (setting in contentObj.contentSections["grid"].styleDefs) {
	if (structKeyExists(url, setting) AND url[setting] != "") {
		styles.content["grid"][setting] = url[setting];
		settings[setting] = url[setting];
	}
	else {
		settings[setting] = "";
	}
}
// end page editing

contentObj.settings(content=grid_cs,styles=styles);

writeDump(grid_cs);

abort;

css = contentObj.css(grid_cs);

// abort;
</cfscript>

<cfparam name="url.maximages" default=""><!--- numeric or blank --->

<cfset images = getImages()>
<cfset maximagescalc = url.maximages eq "" ? arrayLen(images) : url.maximages>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="_styles/standard.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/images.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/grids.css">
		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
		
		<style id="dynamic_css">
			<cfoutput>#css#</cfoutput>
		</style>
	</head>

	<body class="body">

		<div id="panel">
			<h2>Settings</h2>
			<form action="grids.cfm">
				<cfoutput>
					<fieldset>
						<label>Mode</label>	
						<cfset options = contentObj.options("grid","grid-mode")>	

						<select name="grid-mode">
							<cfloop item="mode" array="#options#">
								<cfset selected = mode.code eq settings["grid-mode"] ? " selected": "">
								<option value="#mode.code#" #selected# title="#encodeForHTML(mode.description)#">#encodeForHTML(mode.name)#</option>
							</cfloop>
						</select>
						
						<label>Min grid width</label>				
						<input name="grid-width" value="#settings["grid-width"]#">
						<label>Grid gap</label>				
						<input name="grid-gap" value="#settings["grid-gap"]#">
						<label title="Only applies to  Fixed columns">Widths</label>				
						<input name="grid-template-columns" value="#settings["grid-template-columns"]#">
						<label title="Only applies to Fixed columns">Columns</label>				
						<input name="grid-columns" value="#settings["grid-columns"]#">
						<label>Justify</label>
						<cftry>

						<select name="justify-content">
							<cfloop item="mode" array="#contentObj.options("grid","justify-content")#">
								<cfset selected = mode.code eq settings["justify-content"] ? " selected": "">
								<option value="#mode.code#" #selected# title="#encodeForHTML(mode.description)#">#encodeForHTML(mode.name)#</option>
							</cfloop>
						</select>
							<cfcatch>
								<cfdump var="#cfcatch#">
							</cfcatch>
						</cftry>
						<label>Align</label>			
						<select name="align-items">
							<cfloop item="mode" array="#contentObj.options("grid","align-items")#">
								<cfset selected = mode.code eq settings["align-items"] ? " selected": "">
								<option value="#mode.code#" #selected# title="#encodeForHTML(mode.description)#">#encodeForHTML(mode.name)#</option>
							</cfloop>
						</select>
						<label>Max images</label>				
						<input name="maximages" value="#url.maximages#" type="number">
						<label></label>				
						<input type="submit" value="Update">
					</fieldset>
				</cfoutput>
			</form>
		</div>
		<div>
			
			<cfoutput>		
				<div id="grid" class="grid cs-photos">
				
				<cfloop index="i" from="1" to="#maximagescalc#">
					<cfset image = images[i]>
					<div class="frame">
						<figure>
							<img src="/images/#image#" />
							<figcaption>#ListFirst(image,"-")# #ListGetAt(image,2,"-")#</figcaption>
						</figure>
					</div>
				</cfloop>
					
				</div>
			</cfoutput>
					
		</div>

		
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
