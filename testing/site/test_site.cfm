<cfscript>
/*
 * Load a site definition and dump it
 *
 * ## Usage
 *
 * Uses the site definition in ./preview/config.json
 * 
 */

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

dataObj = new clikpage.data.data_text(config);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live",dataObj=dataObj);

siteObj.pageObj.content.static_css["fonts"] = 1;
siteObj.pageObj.content.static_css["content"] = 1;
siteObj.pageObj.content.static_css["google_icons"] = 1;
siteObj.pageObj.content.static_js["clik_onready"] = 1;
siteObj.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

start = getTickCount();
site = siteObj.loadSite(config.siteDef);
runtime = getTickCount() -start;

writeDump(site);

writeOutput("<p>Loaded site in <strong>#runtime#ms</strong></p>");

sections = siteObj.sectionList(site,"mainmenu");
menu = siteObj.menuData(site,sections);
writeDump(menu);


</cfscript>