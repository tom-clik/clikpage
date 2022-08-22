<!---

# Grids testing page

This page is the definitive testpad for Clik grids.

See the documentation /technotes/css/grids.md for overview

## NB there is also photo gallery styling in here, the captions etc

## History

2022-03-05  THP   Created

--->

<cfscript>
gridObj = new grid();
settings = gridObj.new(url);
// writeDump(settings);
// abort;

</cfscript>

<cfparam name="url.maximages" default=""><!--- numeric or blank --->

<cfset modes = [
	 
	{"name"="plain","title"="Grid","description"="Simple grid with min widths"},
	{"name"="fixedcols","title"="Fixed columns","description"="Fixed number of columns"},
	{"name"="fixed","title"="Fixed widths","description"="Columns have fixed width"},
	{"name"="test","title"="Exotica","description"="Showing off here"}
	
]>


<cfset images = getImages()>
<cfset maximagescalc = url.maximages eq "" ? arrayLen(images) : url.maximages>
<cfset css = gridObj.css(selector="div.cs-photos",settings=settings)>

<html>
	<head>
		<title>Grids CSS Samples</title>
		<link rel="stylesheet" type="text/css" href="/_assets/css/reset.css">
		<link rel="stylesheet" type="text/css" href="_styles/standard.css">
		<link rel="stylesheet" type="text/css" href="/_assets/css/imagegrids.css">
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
						<select name="grid-mode">
							<cfloop item="mode" array="#gridObj.modes()#">
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
							<cfloop item="mode" array="#gridObj.justifyOptions()#">
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
							<cfloop item="mode" array="#gridObj.justifyOptions()#">
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
		<div id="wrapper">
			
			<cfoutput>		
				<div class="cs-photos">
				
				<cfloop index="i" from="1" to="#maximagescalc#">
					<cfset image = images[i]>
					<div class="frame">
						<figure>
							<img src="/_sampleimages/random/out/#image#" />
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
		"emil-widlund-Fyxq6Paxskw-unsplash.jpg",
		"harley-davidson-XnhmpwEbv5I-unsplash.jpg",
		"joshua-fernandez-Q4SCuuKtSDU-unsplash.jpg",
		"larisa-birta-h9kODfOsyOU-unsplash.jpg",
		"mak-ipkw44S_LHM-unsplash.jpg",
		"nate-johnston-cK_1Q_e5FfU-unsplash.jpg",
		"nathan-dumlao-ljbqCDlAhjY-unsplash.jpg",
		"sarah-dokowicz-V3W8Lknvhq8-unsplash.jpg",
		"emil-widlund-Fyxq6Paxskw-unsplash.jpg",
		"harley-davidson-XnhmpwEbv5I-unsplash.jpg",
		"joshua-fernandez-Q4SCuuKtSDU-unsplash.jpg",
		"larisa-birta-h9kODfOsyOU-unsplash.jpg",
		"mak-ipkw44S_LHM-unsplash.jpg",
		"nate-johnston-cK_1Q_e5FfU-unsplash.jpg",
		"nathan-dumlao-ljbqCDlAhjY-unsplash.jpg",
		"sarah-dokowicz-V3W8Lknvhq8-unsplash.jpg"
			]>

</cffunction>
