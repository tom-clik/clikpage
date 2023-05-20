<!---

# Image Grid testing page

Test styling for image grids. Also contains all our work on the settings form.

Currently working as a proof of concept albeit with a bit of a lash up.

## WIP

Now sort of working for dynamic updates. The javaScript doesn't reload when you change layout mode, so I'm working on that.



TODO: 

1. Make generic for all components
2. Reload on media change
3. Panels
4. Persist and save results

## Notes

The plan:

1. Persist the content sections in an application variable
2. Write out CSS for all of them where here we are just doing the CSS for one.
3. 

## Status

Working of a fashion. All hardwired to grids.

## History

2023-05-15 THP Merged back in the form stuff. This has broken the idea of a "test". Need to separate out the selection of a test and the settings form.
2023-05-01  THP   Wasn't using the cs obj (??).
2023-04-15  THP   Updated to use the grid styling in settingsObj 
2022-03-05  THP   Created

--->

<cfscript>

include template="css_test_inc.cfm";
param name="request.rc.test" default="";
param name="request.rc.type" default="item";

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
		<title>Grids CSS Samples</title>

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
		<!---
		<script src="/_assets/js/jquery-3.4.1.js"></script>
		<script src="/_assets/js/imagesloaded.pkgd.js"></script>
		<script src="/_assets/js/isotope.pkgd.min.js"></script>
		<script src="/_assets/js/masonry-horizontal.js"></script>
		<script src="/_assets/js/flickity.pkgd.min.js"></script>
		<script src="/_assets/js/jquery.modal.js"></script>
		<script src="/_assets/js/jquery.autoButton.js"></script>
		<script src="/_assets/js/jquery.serializeData.js"></script>
		<script src="/_assets/js/clik_settings.js"></script>
		<script src="/_assets/js/getSettings.js"></script>
		<script src="/_assets/js/photogrid.js"></script>
		<script src="/_assets/js/jquery.mCustomScrollbar.min.js" type="text/javascript" charset="utf-8"></script>
		--->
		<script>
		
		$( document ).ready( function() {
			
			<cfoutput>
			#pageData.pagecontent.onready#
			</cfoutput>



			<cfoutput>
			#application.settingsEdit.settingsFormJS(id)#
			</cfoutput>

		});	
		</script>
	</body>
	
</html>

