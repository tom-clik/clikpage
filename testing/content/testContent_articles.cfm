<cfscript>
cfinclude(template="testContent_include.cfm");

siteObj = new clikpage.site.siteObj();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../site/testSite.xml"));

cs = contentObj.new(id="list",title="Articles",type="articlelist");
cs.data = siteObj.getDataSet(site=site,tag="test");

testCS(cs);

</cfscript>