<cfscript>
/* This function saves content and layout structs to JSON to allow
testing of the styles independently 

## Synopsis

1. Load a layout object
2. Serialize the content struct and the json struct and save to the styles testing folder.

## Usage

Just run.

*/

inputDir = getDirectoryFromPath(getCurrentTemplatePath());
outDir = getCanonicalPath(inputDir & "../styles");

layoutsObj = new clikpage.layouts.layouts(inputDir);

for (i = 1; i lte 6 ; i++) {

	mylayout = layoutsObj.getLayout("testlayout1/testlayout#i#");
	data = {
		"content" = mylayout.content,
		"containers" = mylayout.containers
	};
	fileWrite(outDir & "testlayout#i#.json",serializeJSON(data));
}





</cfscript>