<cfscript>
cfinclude(template="testContent_include.cfm");

siteObj = new clikpage.site.siteObj();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

cs = contentObj.new(id="list",title="Articles",type="articlelist");
cs.data = siteObj.getRecords(site, siteObj.getDataSet(site=site,tag="test"));

testCS(cs);

</cfscript>