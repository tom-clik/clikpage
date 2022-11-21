<cfscript>

/**
 * Test generation of media queries
 *
 * Generate CSS media query from a definition
 * 
 */

settingsObj = createObject("component", "settingsTest").init();
styles = settingsObj.loadStyleSheet(ExpandPath("./testStyles.xml"));

for (medium in styles.media) {
	writeOutput("<h2>#medium#</h2>");
	writeOutput("<pre>" & htmlEditFormat(settingsObj.mediaQuery(styles.media[medium])) & "</pre>");
}

</cfscript>