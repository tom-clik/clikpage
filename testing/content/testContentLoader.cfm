<cfscript>
cfinclude(template="testContent_include.cfm");

WriteOutput("<h2>Content types</h2>");
WriteOutput(contentObj.listTypes());

</cfscript>