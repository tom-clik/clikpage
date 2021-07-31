<cfscript>
cfinclude(template="testContent_include.cfm");

image = contentObj.new(id="imagegrid",title="imagegrid",type="imagegrid");

testCS(image);
</cfscript>