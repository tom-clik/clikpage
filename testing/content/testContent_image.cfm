<cfscript>
cfinclude(template="testContent_include.cfm");

image = contentObj.new(id="image",title="image",type="image",image="/images/matt-moloney-OAzh2bBN110-unsplash.jpg",caption="My caption");

testCS(image);

</cfscript>