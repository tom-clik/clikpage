<!---

# test_staticFiles

Test pad for testing staticFiles component

## Usage

Create a staticfiles object and Use test_js.json as the definition file.

Create a page struct and then output the links for debug mode and live mode.

--->

<cfscript>
defFile = ExpandPath("test_js.json");
// defFile = ExpandPath("../../staticFiles/staticJS.json");
local.tempData = FileRead(defFile);

try {
	local.jsonData = deserializeJSON(local.tempData);
}
catch (Any e) {
	throw("Unable to parse static files definition file #arguments.defFile#");	
}

staticFilesObj = new clikpage.staticFiles.staticFiles(staticDef=local.jsonData);

count = 1;

for (test in [
		{"testpackage":true,"main":true,"notdefined":1,"metaforms":1,"menus":1,"select2":1,"fuzzy":1},
		{"fuzzy":true},
		{"menus":true},
		{"metaforms":true},
		{"coldlight":true}
	]
	) {

	writeOutput("<h2>Test ###count#</h2>");
	writeOutput("<h3>Source</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(serializeJSON(test)));
	writeOutput("</pre>");
	writeOutput("<h3>Debug</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(staticFilesObj.getLinks(test,true)));
	writeOutput("</pre>");
	writeOutput("<h3>Live</h3>");
	writeOutput("<pre>");
	writeOutput(htmlEditFormat(staticFilesObj.getLinks(test,false)));
	writeOutput("</pre>");
	count++;
}


</cfscript>
