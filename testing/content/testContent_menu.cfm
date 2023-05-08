<cfscript>
cfinclude(template="testContent_include.cfm");
id = "mainmenu";
menu = contentObj.new(id="mainmenu",title="menu",type="menu");
menu.data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleMenu.json" ) ) );

styles.style["#id#"] = {
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

testCS(menu);

</cfscript>