<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init();

settingsObj = createObject("component", "clikpage.settingsObj").init();

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));




menu = contentObj.new(id="menu",title="Menu",type="menu");
writeDump(menu);

writeOutput("<pre>" & htmlEditFormat(contentObj.css(menu)) & "</pre>");

menu.settings.main.flex = "true";
writeOutput("<pre>" & htmlEditFormat(contentObj.css(menu)) & "</pre>");

menu.settings.main.orientation = "vertical";
menu.settings.main["menugap"] = "12px";
menu.settings.main["menucolor"] = "##ff00ff";
menu.settings.main["menuhicolor"] = "##ffff00";
writeOutput("<pre>" & htmlEditFormat(contentObj.css(menu)) & "</pre>");

</cfscript>