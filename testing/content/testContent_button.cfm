<cfscript>
cfinclude(template="testContent_include.cfm");

defFile = ExpandPath("/_assets/images/buttons.xml");

contentObj.loadButtonDefFile(defFile);

button = contentObj.new(id="button",title="button",type="button");

testCS(button);

</cfscript>