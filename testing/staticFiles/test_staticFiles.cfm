<!---

# test_staticFiles

Test pad for testing staticFiles component

## Usage

Create a staticfiles object and Use test_js.json as the definition file.

Create a page struct and then output the links for debug mode and live mode.

--->

<cfscript>
defFile = ExpandPath("test_js.json");
local.tempData = FileRead(defFile);
try {
	local.jsonData = deserializeJSON(local.tempData);
}
catch (Any e) {
	throw("Unable to parse static files definition file #arguments.defFile#");	
}

staticFilesObj = createObject("component", "clikpage.staticFiles.staticFiles").init(staticDef=local.jsonData);


count = 1;
for (js in [
	{"testpackage":true,"main":true,"notdefined":1},
	{"fuzzy":true},
	{"menus":true}]
	) {

	writeOutput("<h2>Test ###count#</h2>");
	writeOutput("<h3>Source</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(serializeJSON(js)));
	writeOutput("</pre>");

	writeOutput("<h3>Debug</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(staticFilesObj.getLinks(js,true)));
	writeOutput("</pre>");
	writeOutput("<h3>Live</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(staticFilesObj.getLinks(js,false)));
	writeOutput("</pre>");
	count++;
}


</cfscript>
