<cfscript>
/* 

Use to quickly dump any layout

*/

layoutsObj = new clikpage.layouts.layouts("C:\git\dm\clikdesign\samples\poster\layouts");
data = layoutsObj.getLayout("home");
writeDump(data);
</cfscript>