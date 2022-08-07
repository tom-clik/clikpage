<cfscript>
siteObj = new clikpage.site.siteObj();

siteObj.debug = true;

param name="request.rc.section" default="index";

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

dataset1 = siteObj.getDataSet(site=site,tag="test");

WriteDump(dataset1);
data = siteObj.getData(site=site,dataset="dataset1");
WriteDump(data);

dataset2 =siteObj.getDataSet(site=site,tag="gallery",type="images"); 
WriteDump(dataset2);
data = siteObj.getData(site=site,dataset="dataset2",type="images");
WriteDump(data);


record = siteObj.getRecord(site=site,dataset="dataset2",id = dataset2[1];,type="images");

WriteDump(record);


</cfscript>