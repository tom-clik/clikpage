<!---

Save some sample menu data to JSON files for testing

## Usage

Preview. Saves menus defined in sample site to _out/sampleMenu.json

All hardwired. Sort of a scratchpad.

--->
<cfscript>
path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");
site = siteObj.loadSite(config.siteDef);

dataset = {
	tag="mainmenu",type="sections"
};
 
menu =siteObj.getDataSet(site=site,dataset=dataset);
menudata = siteObj.menuData(site,menu);
FileWrite(ExpandPath("_out/sampleMenu.json"), serializeJSON(menudata));

dataset = {
	tag="footermenu",type="sections"
};
menu =siteObj.getDataSet(site=site,dataset=dataset);
menudata = siteObj.menuData(site,menu);
FileWrite(ExpandPath("_out/sampleSmallMenu.json"), serializeJSON(menudata));

WriteOutput("Menus saved");

</cfscript>