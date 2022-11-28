<!---

Scratch pad for testing individual cs styling

--->

<cfscript>
settingsObj = CreateObject("component", "clikpage.settings.settings").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.content").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

menu = contentObj.new(id="topmenu",title="Menu",type="menu");

contentObj.settings(content=menu,styles=styles.content,media=styles.media);

writeOutput("<pre>" & settingsObj.outputFormat(contentObj.css(menu),styles.media,contentObj.debug) & "</pre>");

styles.content.topmenu.main.flex = "true";

contentObj.settings(content=menu,styles=styles.content,media=styles.media);

writeOutput("<pre>" & settingsObj.outputFormat(contentObj.css(menu),styles.media,contentObj.debug) & "</pre>");

styles.content.topmenu.mobile.orientation = "vertical";
styles.content.topmenu.main["menugap"] = "12px";
styles.content.topmenu.main["menucolor"] = "##ff00ff";
styles.content.topmenu.main["menuhicolor"] = "##ffff00";

styles.content.topmenu.mobile["menugap"] = "12px";

contentObj.settings(content=menu,styles=styles.content,media=styles.media);

writeOutput("<pre>" & settingsObj.outputFormat(css=contentObj.css(menu),media=styles.media,debug=contentObj.debug) & "</pre>");

</cfscript>