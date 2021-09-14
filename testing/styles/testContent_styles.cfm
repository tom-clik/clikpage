<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

menu = contentObj.new(id="topmenu",title="Menu",type="menu");

contentObj.settings(menu,styles);

writeOutput("<pre>" & settingsObj.outputFormat(contentObj.css(menu,styles.media),styles,contentObj.debug) & "</pre>");

styles.content.topmenu.main.flex = "true";

contentObj.settings(menu,styles);

writeOutput("<pre>" & settingsObj.outputFormat(contentObj.css(menu,styles.media),styles,contentObj.debug) & "</pre>");

styles.content.topmenu.mobile.orientation = "vertical";
styles.content.topmenu.main["menugap"] = "12px";
styles.content.topmenu.main["menucolor"] = "##ff00ff";
styles.content.topmenu.main["menuhicolor"] = "##ffff00";

styles.content.topmenu.mobile["menugap"] = "12px";

contentObj.settings(menu,styles);

writeOutput("<pre>" & settingsObj.outputFormat(contentObj.css(menu,styles.media),styles,contentObj.debug) & "</pre>");

</cfscript>