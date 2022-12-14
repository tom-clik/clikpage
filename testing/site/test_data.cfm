<cfscript>
path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");
site = siteObj.loadSite(config.siteDef);

dataset = {
	tag="mainmenu",type="sections"
};

param name="request.rc.section" default="index";

WriteDump(dataset);
menu =siteObj.getDataSet(site=site,dataset=dataset);
WriteDump(menu);

dataset.tag = "";
menu =siteObj.getDataSet(site=site,dataset=dataset); 
WriteDump(menu);

dataset = {
	tag="test"
};

records1 = siteObj.getDataSet(site=site,dataset=dataset);

WriteDump(records1);
data = siteObj.getRecords(site=site,dataset=records1);
WriteDump(data);

dataset = {
	tag="gallery",type="images"
};

records2 =siteObj.getDataSet(site=site,dataset=dataset); 
WriteDump(records2);
data = siteObj.getRecords(site=site,dataset=records2,type="images");
WriteDump(data);

record = siteObj.getRecord(site=site,id = records2[2],type="images");
WriteDump(record);

info = siteObj.getRecordSetInfo(site=site,dataset=records2,id=record.id);

writeDump(info);

</cfscript>