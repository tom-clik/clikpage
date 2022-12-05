<cfscript>
siteObj = new clikpage.site.site();

siteObj.debug = true;

param name="request.rc.section" default="index";

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

dataset1 = siteObj.getDataSet(site=site,tag="test");

WriteDump(dataset1);
data = siteObj.getRecords(site=site,dataset=dataset1);
WriteDump(data);



dataset2 =siteObj.getDataSet(site=site,tag="gallery",type="images"); 
WriteDump(dataset2);
data = siteObj.getRecords(site=site,dataset=dataset2,type="images");
WriteDump(data);

record = siteObj.getRecord(site=site,id = dataset2[1],type="images");
WriteDump(record);

siteObj.addPageLinks(record=record, dataset=dataset2, site=site, section="gallery");
writeDump(record);


</cfscript>