<cfscript>
cfinclude(template="testContent_include.cfm");
id = "articlelist";
cs = contentObj.new(id=id,title="Articles",type="articlelist",class="scheme-articlelist_panels");

data =  deserializeJSON( FileRead( expandPath( "../site/_out/sampleArticles.json" ) ) );

cs.data = data.test;
request.data = data.articles;

settingsObj.loadStyleSheet(expandPath("../css/_styles/articlelist_test.scss"), styles);

testCS(cs);

</cfscript>