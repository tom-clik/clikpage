<cfscript>
cfinclude(template="testContent_include.cfm");


text = contentObj.new(id="text",title="text",type="text",content="Just plain text");

testCS(text,false);

</cfscript>