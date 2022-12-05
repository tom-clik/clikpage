<cfscript>
cfinclude(template="testContent_include.cfm");

siteObj = new clikpage.site.site();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

cs = contentObj.new(id="imagegrid",title="imagegrid",type="imagegrid");

cs.data = siteObj.getRecords(site=site, dataset=siteObj.getDataSet(site=site,tag="gallery",type="images"),type="images");

testCS(cs);
</cfscript>