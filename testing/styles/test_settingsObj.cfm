<!---
Test settingsObj

## Synopsis

Load a stylesheet(s) page and dump it.

--->

<cfscript>
settingsObj = new clikpage.settings.settings();
styles = {};
settingsObj.loadStyleSheet(expandPath("../css/_styles/test_settings.scss"), styles);
settingsObj.loadStyleSheet(expandPath("../css/_styles/grid_test.scss"), styles);

writeDump(styles);


</cfscript>