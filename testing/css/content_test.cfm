<!---

# Content section testing page

## Notes


## Status

Working of a fashion. 

## History

2023-05-20 Getting something close to a generic test page

--->

<cfscript>

param name="request.rc.reload" type="boolean" default="0";
param name="request.rc.action" default='index';
param name="request.rc.test" default='';
param name="request.rc.medium" default='main';
param name="request.rc.type" default="imagegrid";

if (request.rc.reload OR ! StructKeyExists(application, "settingsTest") ) {
	application.settingsTest = new settingsTest();
	application.settingsEdit = new clikpage.settings.settingsEdit(
		contentObj = application.settingsTest.contentObj
	);
}
else {
	application.settingsTest.loadSettings();
}

id = "#request.rc.type#";
class = "scheme-#request.rc.type#";

if (request.rc.test != "") {
	class = ListAppend(class, "scheme-#request.rc.test#", " ");
}

application.settingsTest.addCs(
	site=application.settingsTest.site, 
	type=request.rc.type,
	class=class,
	id=id
);

cs = application.settingsTest.site.cs[id];
cs.settings = {};

application.settingsEdit.updateSettings(
	cs=cs,
	styles=application.settingsTest.styles,
	values=request.rc
);

pageData = application.settingsTest.pageData(
	cs=cs,
	data=application.settingsTest.getSiteData(request.rc.type)
);

pageContent = application.settingsTest.pageObj.getContent();
pageContent.static_css["navbuttons"] = 1;
pageContent.static_css["scrollbar"] = 1;
pageContent.static_css["tabs"] = 1;
pageContent.static_js["main"] = 1;
pageContent.static_js["clikutils"] = 1;
pageContent.static_js["scrollbar"] = 1;
pageContent.static_js["tabs"] = 1;
pageContent.static_js["settingsForm"] = 1;

application.settingsTest.contentObj.addPageContent(pageContent,application.settingsTest.contentObj.getPageContent(cs,{}));

// DEPRECTAED: Moving to JS plug-in
// form_html = application.settingsEdit.settingsForm(contentsection=application.settingsTest.site.cs[id],type=request.rc.type);

// TODO: define schemes in some sort of data format.
hasTests = 0;
schemesFile = expandPath("_styles/#request.rc.type#.json");
if (FileExists(schemesFile)) {
	jsonData = FileRead( schemesFile );
	tests = deserializeJSON( jsonData );
	hasTests = 1;
}
css = application.settingsTest.css();
</cfscript>

<html>
	<head>
		<title>Content Section Testing Page</title>

		<cfoutput>
		#application.settingsTest.pageObj.cssStaticFiles.getLinks(pagecontent.static_css,1)#
		</cfoutput>
		
		
		<link rel="stylesheet" type="text/css" href="_styles/settingsPanel.css">
		
		<style id="main">
			body {
				background-color: #f3f3f3;
				padding:20px;
			}
			
			
		</style>
		<style id="css">
			<cfoutput>#css#</cfoutput>
		</style>		
		
	</head>

	<body class="body">
		
		<div>			
			<cfoutput>#pageData.html#</cfoutput>
		</div>

		<cfif hasTests>
			<div>
				<form>
					<cfoutput>
						<input type="hidden" name="type" value="#request.rc.type#">
					</cfoutput>
					<h2>Test mode</h2>
					<select name="test">
						<cfloop index="test" array="#tests#">
							<cfset selected =request.rc.test eq test.id ? "selected" : "">
							<cfoutput>
							<option #selected# value="#test.id#">#test.title#</option>
							</cfoutput>
						</cfloop>
					</select>

					<label></label>				
					<div class="button"><input type="submit" value="Update"></div>
				</form>
			</div>
		</cfif>

		<div id='settings_panel' class='settings_panel modal'></div>
		
		<div id="settings_panel_open"><div class="button auto"><a href="#settings_panel.open">Settings</a></div></div>

		<cfoutput>
		#application.settingsTest.pageObj.jsStaticFiles.getLinks(pagecontent.static_js,1)#
		</cfoutput>
		
		
		<script>
		$( document ).ready( function() {
			<cfoutput>
			$("##settings_panel").settingsForm({
				id: '#cs.id#',
				type: '#cs.type#',
				settings: #serializeJSON(cs.settings.main)#,
				api: 'api/settings_api.cfc'
			});
			
			#pageData.pagecontent.onready#
			</cfoutput>

		});	
		</script>

	</body>
	
</html>

