<cfscript>
/* 

*/

inputDir = expandPath("testlayout1");
outFile = ExpandPath("../styles/testsite.json");

layoutsObj = new clikpage.layouts.layouts(inputDir);
data = layoutsObj.getLayout("testlayout1");
writeDump(data);
</cfscript>