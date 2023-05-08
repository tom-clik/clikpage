<cfscript>

/**
 * Test generation of media queries
 *
 * Generate CSS media query from a definition
 * 
 */

settingsObj = new settingsTest();
styles = settingsObj.loadStyleSettings(ExpandPath("./testStyles.xml"));

for (medium in styles.media) {
	writeOutput("<h2>#medium#</h2>");
	writeOutput("<pre>" & htmlEditFormat(settingsObj.mediaQuery(styles.media[medium])) & "</pre>");
}

</cfscript>