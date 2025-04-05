<cfscript>
cfinclude(template="testContent_include.cfm");
id = "imagegrid";
cs = contentObj.new(id=id,title="imagegrid",type="imagegrid",class="scheme-overlay");

data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleImages.json" ) ) );

cs.data = data.gallery;
request.data = data.images;

settingsObj.loadStyleSheet(expandPath("../css/_styles/imagegrid_test.scss"), styles);

testCS(cs);
</cfscript>