<!---

# Save settings Data

Export settings definitions for each content type to a javascript file

## Usage

Run to generate the file /_assets/js/content_settings.js

This file is part of the static file definitions and you will need to bump the version for the minified

--->
<cfscript>
settingsObj = new clikpage.settings.settings(debug=1);
contentObj = new clikpage.content.content(settingsObj=settingsObj);
contentObj.debug = 1;

data = contentObj.getSettings(contentObj);

js = "clik_settings = #serializeJSON(data)#;";
filePath = ExpandPath("../_assets/js/clik_settings.js");
FileWrite(filePath,js);


</cfscript>

<html>

<body>
	<cfoutput>
		File written to #filePath#. See console log for data.
	</cfoutput>
<script src="/_assets/js/jquery-3.4.1.js"></script>
<script src="/_assets/js/content_settings.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		console.log(clik_settings);
	});
</script>
</body>
</html>
