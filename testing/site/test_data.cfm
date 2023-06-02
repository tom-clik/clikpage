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

WriteDump(var=dataset,label="Dataset definition");
menu =siteObj.getDataSet(site=site,dataset=dataset);
WriteDump(var=menu,label="Dataset 1");

dataset.tag = "";
menu =siteObj.getDataSet(site=site,dataset=dataset); 
WriteDump(var=menu,label="Dataset with no tag");

menudata = siteObj.menuData(site,menu);
WriteDump(menudata);

dataset = {
	tag="test"
};

records1 = siteObj.getDataSet(site=site,dataset=dataset);

WriteDump(var=records1,label="Articles with tag test");
data = siteObj.getRecords(site=site,dataset=records1);
WriteDump(var=data,label="Data for last data set");

dataset = {
	tag="gallery",type="images"
};

records2 =siteObj.getDataSet(site=site,dataset=dataset); 
WriteDump(var=records2,label="Image data set");
data = siteObj.getRecords(site=site,dataset=records2,type="images");
WriteDump(var=data,label="Data from previous query");

record = siteObj.getRecord(site=site,id = records2[2],type="images");
WriteDump(var=record,label="Individual record");

info = siteObj.getRecordSetInfo(site=site,dataset=records2,id=record.id);
writeDump(var=info,label="Record set info");

dataset = {
	tag="{parent}",
	type="sections"
};

sections = siteObj.getDataSet(site=site,dataset=dataset,fields={"parent":"about"});
data = siteObj.getRecords(site=site,dataset=sections,type="sections");
writeDump(var=sections,label="Sub sections data set");
writeDump(var=data,label="Sub sections records");

siteObj.saveData(site=site,outputDir=ExpandPath("preview/scripts"));

</cfscript>