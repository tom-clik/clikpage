<!--

# Jquery Menu Test

-->
<cfscript>
settingsTest = new settingsTest();
pageContent = settingsTest.pageObj.getContent();

//writeDump(pageContent);
//writeDump(settingsTest.styles);

id = "mainmenu";
menu = settingsTest.contentObj.new(id=id,title="menu",type="menu");
menu.data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleMenu.json" ) ) );

settingsTest.site.cs[id] = menu;

settingsTest.styles.style[id] = {
	"main": {
		"padding": 0,
		"border-type":"dividers",
		"menu-item-border":1,
		"menu-border-color":"accent",
		"width": "auto",
		"align": "left",
		"orientation": "vertical",
		"link-color": "panel-text",
		"item" : {
			"padding": "8px",
			"background": {
				"color" :"panel-bg"
			},
			"hover": {
				"link-color": "textcolor",
				"background": {
					"color" :"light-panel-bg"
				}
			}
		},
		"subitem" : {
			"link-color": "myfavcolor",
			"padding": "8px 8px 8px 24px",
			"hover": {
				"link-color": "panel-text"
			}
		},
		"menu-gap":0,
		"submenu_position":"static"
		
	}
};

settingsTest.contentObj.settings(
	content=menu,
	styles=settingsTest.styles,
	media=settingsTest.styles.media
);


menu.html = "<h2>Testing</2>"


</cfscript>




<cfsavecontent variable="pageContent.body">

	<div id="ubercontainer">
		

		<div id="menu_container">
			<div class="inner">
				<cfoutput>#menu.html#</cfoutput>				
			</div>
		</div>	

	</div>

</cfsavecontent>


<cfscript>
writeOutput( settingsTest.pageObj.buildPage(pageContent) );
</cfscript>