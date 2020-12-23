<!---

# test_staticFiles

Test pad for testing api

## Usage

Configure a test file and staticDefTest and run. It will show the html from getLinks

--->

<cfscript>
staticDefTest = {"jquery":true};

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
writeOutput(htmlEditFormat(staticFilesObj.getLinks(scripts=staticDefTest)));
writeOutput("</pre>");
</cfscript>
