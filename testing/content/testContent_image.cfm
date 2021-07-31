<cfscript>
cfinclude(template="testContent_include.cfm");

image = contentObj.new(id="image",title="image",type="image",image="http://localpreview.clikpic.com/sampleimages/nate-johnston-cK_1Q_e5FfU-unsplash.jpg",caption="My caption");

testCS(image);

</cfscript>