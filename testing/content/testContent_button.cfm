<cfscript>
cfinclude(template="testContent_include.cfm");

contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

button = contentObj.new(id="button",title="button",type="button");

testCS(button);

</cfscript>