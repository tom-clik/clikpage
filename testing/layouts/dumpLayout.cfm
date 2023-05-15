<cfscript>
/* 

Use to quickly dump any layout

*/

layoutsObj = new clikpage.layouts.layouts("C:\git\dm\clikdesign\samples\webb\layouts");
data = layoutsObj.getLayout("main");
writeDump(data);
</cfscript>