<!---
Test settingsObj

## Synopsis

Load a stylesettings page and dump it.
--->

<cfscript>
// testFile = expandPath("../../sample/_data/styles/sample_layouts.css");
settingsObj = new clikpage.settings.settings();
styles = {};
settingsObj.loadStyleSheet(expandPath("./testStyles.css"), styles);
settingsObj.loadStyleSheet(expandPath("../css/_styles/grid_test.css"), styles);

writeDump(styles);


</cfscript>