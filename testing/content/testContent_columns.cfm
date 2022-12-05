<cfscript>
throw("Deprecated");

cfinclude(template="testContent_include.cfm");

columnsObj = new clikpage.content.columns(contentObj=contentObj);

body = contentObj.new(id="text",title="text",type="text",content="Just plain text");
css =columnsObj.css("body.template-test",{
	"row-layout":"HF-TC-F",
	"column-layout" : "S-MX"
});
css = contentObj.processText(css);

writeOutput("<pre>" & css & "</pre>");

//content = contentObj.getPageContent(text,true)
//writeDump(content);
</cfscript>