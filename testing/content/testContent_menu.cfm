<cfscript>
cfinclude(template="testContent_include.cfm");

menu = contentObj.new(id="topmenu",title="menu",type="menu");

testCS(menu);

</cfscript>