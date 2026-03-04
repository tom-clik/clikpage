<cfscript>
cfinclude(template="testContent_include.cfm");
id = "mainmenu";
menu = contentObj.new(id="mainmenu",title="menu",type="menu",class="scheme-menu");
menu.data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleMenu.json" ) ) );

settingsObj.loadStyleSheet(expandPath("../css/_styles/menu_test.scss"), styles);

testCS(menu);

</cfscript>