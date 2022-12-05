<cfscript>
cfinclude(template="testContent_include.cfm");

text = contentObj.new(id="sectiontitle",title="Simple title",type="title",content="A heading here");

testCS(text);

</cfscript>