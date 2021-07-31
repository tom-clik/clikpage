<cfscript>
siteObj = createObject("component", "clikpage.site.siteObj").init();

siteObj.debug = true;

param name="request.rc.section" default="index";

site = siteObj.loadSite(ExpandPath("./testSite.xml"));

dataset1 =siteObj.getDataSet(site=site,tag="test"); 
WriteDump(dataset1);


dataset2 =siteObj.getDataSet(site=site,tag="test2"); 
WriteDump(dataset2);

request.rc.id = dataset2[1].id;

WriteDump(siteObj.getData(site=site,id=request.rc.id,section=request.rc.section,dataSet=dataset2));

</cfscript>