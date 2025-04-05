<cfscript>

cfinclude(template="testContent_include.cfm");

// columnsObj = new clikpage.content.columns(contentObj=contentObj);

body = contentObj.new(id="body",title="body",type="columns");

testCS(body);

</cfscript>