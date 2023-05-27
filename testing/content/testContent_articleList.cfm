<cfscript>
cfinclude(template="testContent_include.cfm");
id = "list";
cs = contentObj.new(id=id,title="Articles",type="articlelist");

data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleArticles.json" ) ) );

cs.data = data.test;
request.data = data.articles;

styles.style["#id#"] = {
	"main": {
		"image-align":"left"
	}
}
testCS(cs);

</cfscript>