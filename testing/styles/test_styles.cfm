<cfscript>

settingsObj = CreateObject("component", "clikpage.settings.settingsObj").init(debug=1);
contentObj = CreateObject("component", "clikpage.content.contentObj").init(settingsObj=settingsObj);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

writeDump(styles);

css = "";
css &= settingsObj.fontVariablesCSS(styles);
css &= settingsObj.layoutCss(styles);
css &= settingsObj.containerCss(styles,"body","body");

css &= "@media.mobile {\n ";
css &= settingsObj.containerCss(styles,"body","body","mobile");
css &= settingsObj.containerCss(styles,"header","##header .inner","mobile");
css &=  "\n}\n";

WriteOutput("<pre>" & HtmlEditFormat(settingsObj.outputFormat(css,styles)) & "</pre>");


</cfscript>