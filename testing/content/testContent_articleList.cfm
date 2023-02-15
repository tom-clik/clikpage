<cfscript>
cfinclude(template="testContent_include.cfm");

cs = contentObj.new(id="list",title="Articles",type="articlelist");

cs.data = siteObj.getDataSet(site=site,dataset={"tag"="test"});
request.data = site.articles;

testCS(cs);

</cfscript>