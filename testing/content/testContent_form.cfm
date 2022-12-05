<cfscript>
cfinclude(template="testContent_include.cfm");

text = contentObj.new(id="form",title="Dummy form",type="form",content="");

testCS(text);

</cfscript>