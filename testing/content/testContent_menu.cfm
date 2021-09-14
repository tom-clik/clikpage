<cfscript>
cfinclude(template="testContent_include.cfm");

menu = contentObj.new(id="menu",title="menu",type="menu");

testCS(menu);

</cfscript>