<!---

Save some sample menu data to JSON files for testing

## Usage

Preview. Saves data _out

menus sampleMenu.json
articles sampleMenu.json

All hardwired. Sort of a scratchpad.

--->
<cfscript>
path = ExpandPath("./preview/config_main.json");
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

dataset = {
	tag="test",type="articles"
};

articles["test"] = siteObj.getDataSet(site=site,dataset=dataset);
articles["articles"] =site.articles;
FileWrite(ExpandPath("_out/sampleArticles.json"), serializeJSON(articles));

WriteOutput("Articles saved");

dataset = {
	tag="gallery",type="images"
};

images["gallery"] = siteObj.getDataSet(site=site,dataset=dataset);
images["images"] =site.images;
FileWrite(ExpandPath("_out/sampleImages.json"), serializeJSON(images));

WriteOutput("Images saved");



</cfscript>