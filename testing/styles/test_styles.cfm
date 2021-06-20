<cfscript>
contentObj = CreateObject("component", "clikpage.contentObj").init();

settingsObj = CreateObject("component", "clikpage.settingsObj").init(debug=1);

contentObj.debug = true;

styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

css = "";

css &= settingsObj.getLayoutCss(styles);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>