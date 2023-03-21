<!---

Test settingsObj

## Synopsis

Load a stylesettings page and dump it.
--->

<cfscript>
// testFile = expandPath("../../sample/_data/styles/sample_layouts.css");
settingsObj = new clikpage.settings.settings();
writeDump(settingsObj.loadStyleSettings(expandPath("../../sample/_data/styles/sample_stylesettings.xml")));


</cfscript>