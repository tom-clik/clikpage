<!---

Save some sample menu data to JSON files for testing

## Usage

Preview. Saves data _out

menus sampleMenu.json
articles sampleMenu.json

All hardwired. Sort of a scratchpad.

--->
<cfscript>
savecontent variable="nully" {
	cfinclude( template="test_site.cfm" );
}


menu = siteObj.sectionList(site=site,tag="mainmenu");
menudata = siteObj.menuData(site, menu);
FileWrite(ExpandPath("_out/sampleMenu.json"), serializeJSON(menudata));

menu = siteObj.sectionList(site=site,tag="footer");
menudata = siteObj.menuData(site,menu);
FileWrite(ExpandPath("_out/sampleSmallMenu.json"), serializeJSON(menudata));

WriteOutput("Menus saved");

dataset = {
	"tag"="test","type"="articles","name"="testdata"
};

articles["test"] = siteObj.getDataSet(site=site,dataset=dataset);
articles["articles"] =site.articles;

FileWrite(ExpandPath("_out/sampleArticles.json"), serializeJSON(articles));

WriteOutput("Articles saved");

// dataset = {
// 	tag="gallery",type="images"
// };

// images["gallery"] = siteObj.getDataSet(site=site,dataset=dataset);
// images["images"] =site.images;
// FileWrite(ExpandPath("_out/sampleImages.json"), serializeJSON(images));

// WriteOutput("Images saved");



</cfscript>