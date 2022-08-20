<cfscript>
cfinclude(template="testContent_include.cfm");

text = contentObj.new(id="text",title="General",content="<p>hello world</p>",image="//d2033d905cppg6.cloudfront.net/tompeer/images/Graphic_111.jpg",caption="lorem ipsum");

testCS(text,false);

text.settings = {
	"image-align" = "left",
	"image-width" = "66%",
	"title" = {
		"font-family" = "Roboto"
	},
	"hover": {
		"color": "red"
	}

}

testCS(text,false);

writeDump(styles);

testCS(text);

</cfscript>