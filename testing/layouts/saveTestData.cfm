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

data = {
	"content" = {},
	"containers" = {}
};

for (i = 1; i lte 6 ; i++) {
	mylayout = layoutsObj.getLayout("testlayout1/testlayout#i#");
	StructAppend(data.content,mylayout.content);
	StructAppend(data.containers,mylayout.containers);
}

fileWrite(outDir & "testsite.json",serializeJSON(data));


</cfscript>