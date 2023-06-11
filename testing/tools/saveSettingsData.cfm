<!---

# Save settings Data

Export settings definitions for each content type to a javascript file

## Usage

Run to generate the file /_assets/js/content_settings.js

This file is part of the static file definitions and you will need to bump the version for the minified

--->
<cfscript>
settingsTest = new clikpage.testing.css.settingsTest();
settingsEditObj = new clikpage.settings.settingsEdit(contentObj=settingsTest.contentObj);

clik_settings = settingsTest.contentObj.getSettings();

/* Save only data needed for live site */
live_data = {};
for (cs_type in clik_settings) {
	live_data[cs_type] = {"styleDefs"={}};
	for (setting in clik_settings[cs_type].styleDefs) {
		live_data[cs_type]["styleDefs"][setting] = {"type":clik_settings[cs_type].styleDefs[setting].type};
	}
}

live_js = "clik_settings = #serializeJSON(live_data)#;";
filePath = ExpandPath("/_assets/js/clik_settings_live.js");
FileWrite(filePath,live_js);

clik_settings["panel"]["styleDefs"] = settingsEditObj.styleDefs;
settingsOptions = settingsEditObj.settingsOptions;
settingsOptions["shapes"] = settingsTest.contentObj.shapeOptions();

js = "/* File auto generated by saveSettingsData */" & NewLine();
js &= "clik_settings = #serializeJSON(clik_settings)#;" & NewLine();
js &= "settingsOptions = #serializeJSON(settingsOptions)#;" & NewLine();
filePath = ExpandPath("/_assets/js/clik_settings.js");
FileWrite(filePath,js);
</cfscript>

<html>

<body>
	<cfoutput>
		File written to #filePath#. See console log for data.
	</cfoutput>
<script src="/_assets/js/jquery-3.4.1.js"></script>
<script src="/_assets/js/clik_settings.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		console.log(clik_settings);
		console.log(settingsOptions);
	});
</script>
</body>
</html>