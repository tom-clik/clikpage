<!---

# Content section testing page

## Notes


## Status

Working of a fashion. 

## History

2023-05-20 Getting something close to a generic test page

--->

<cfscript>

include template="css_test_inc.cfm";

param name="request.rc.test" default="";
param name="request.rc.type" default="articlelist";

id = "#request.rc.type#";
class = "";

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
pageContent.static_js["main"] = 1;
pageContent.static_js["clikutils"] = 1;
pageContent.static_js["scrollbar"] = 1;

application.settingsTest.contentObj.addPageContent(pageContent,application.settingsTest.contentObj.getPageContent(cs,{}));

form_html = application.settingsEdit.settingsForm(contentsection=application.settingsTest.site.cs[id],type=request.rc.type);

// TODO: define schemes in some sort of data format.
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
			#settings_panel {
				--draggable:true;
				--modal:false;
				--fixed:true;
			}

			#settings_panel .wrap {
				--scrollbar:1;
			}

			#settings_panel_close {
				--label-display:none;
				--icon-display:block;
				--shape:close;
				--icon-width:16px;
				--icon-height:16px;
				position: absolute;
				top:4px;
				right:4px;
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

		<div>
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

				<label></label>				
				<div class="button"><input type="submit" value="Update"></div>
			</form>
		</div>

		<cfoutput>
		#form_html#
		</cfoutput>
		
		<div id="settings_panel_open"><div class="button auto"><a href="#settings_panel.open">Settings</a></div></div>

		<cfoutput>
		#application.settingsTest.pageObj.jsStaticFiles.getLinks(pagecontent.static_js,1)#
		</cfoutput>
		
		<script>
		$( document ).ready( function() {
			
			<cfoutput>
			#pageData.pagecontent.onready#
			#application.settingsEdit.settingsFormJS(id)#
			</cfoutput>

		});	
		</script>

	</body>
	
</html>

