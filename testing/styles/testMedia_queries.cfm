<cfscript>

settingsObj = createObject("component", "settingsTestObj").init();
styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

for (medium in styles.media) {
	writeOutput("<pre>" & htmlEditFormat(settingsObj.mediaQuery(medium.name,styles, "Styling for #medium.name#")) & "</pre>");
}


// writeOutput("<pre>" & htmlEditFormat(settingsObj.css(menu)) & "</pre>");

</cfscript>