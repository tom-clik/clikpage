<cfscript>
/* 

*/
//inputDir = expandPath("testlayout1");
inputDir = expandPath("../../sample/_data/layouts");

layoutsObj = new clikpage.layouts.layouts("C:\git\dm\clikdesign\samples\speaker\data\layouts");
data = layoutsObj.getLayout("main");
writeDump(data);
</cfscript>