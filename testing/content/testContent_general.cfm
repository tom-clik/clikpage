<cfscript>
cfinclude(template="testContent_include.cfm");


text = contentObj.new(id="text",title="General",content="<p>hello world</p>",image="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg",caption="lorem ipsum");

testCS(text);

text.settings.align = "left";
text.settings.imagewidth = "66%";

testCS(text);

</cfscript>