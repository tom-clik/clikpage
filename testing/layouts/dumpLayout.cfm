<cfscript>
/* 

*/

//inputDir = expandPath("testlayout1");
inputDir = expandPath("../../sample/_data/layouts");

layoutsObj = new clikpage.layouts.layouts(inputDir);
data = layoutsObj.getLayout("main");
writeDump(data);
</cfscript>