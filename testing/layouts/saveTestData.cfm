<cfscript>
/* This script saves content and layout structs to JSON to allow
testing of the styles independently of the layout object.

## Synopsis

1. Load a layout object
2. Serialize the content struct and the json struct and save to the styles testing folder.

## Usage

Just run.

*/

inputDir = expandPath("testlayout1");
outFile = ExpandPath("../styles/testsite.json");

layoutsObj = new clikpage.layouts.layouts(inputDir);
data = layoutsObj.loadAll();

fileWrite(outFile,serializeJSON(data));

writeOutput("saved to " & outFile & "");
</cfscript>