<cfscript>
cfinclude(template="testContent_include.cfm");
id = "imagegrid";
cs = contentObj.new(id=id,title="imagegrid",type="imagegrid");

data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleImages.json" ) ) );

cs.data = data.gallery;
request.data = data.images;

styles.style["#id#"] = {
	"main": {
		"grid-mode":"auto"
	}
}


testCS(cs);
</cfscript>