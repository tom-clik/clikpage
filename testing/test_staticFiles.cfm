<!---

# test_api

Test pad for testing api

--->
<cfscript>
defFile = ExpandPath("test_js.json");
local.tempData = fileRead(defFile);
try {
	local.jsonData = deserializeJSON(local.tempData);
}
catch (Any e) {
	throw("Unable to parse static files definition file #arguments.defFile#");	
}

staticFilesObj = createObject("component", "publishing.staticFiles").init(staticDef=local.jsonData);
writeOutput("<pre>");
writeOutput(htmlEditFormat(staticFilesObj.getLinks({"jquery":true})));
writeOutput("</pre>");
</cfscript>
