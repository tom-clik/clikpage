<cfscript>
/*
 * Load a site definition and dump it
 *
 * ## Usage
 *
 * Uses the site definition in ./preview/config.json
 *
 * 
 */

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

dataObj = new clikpage.data.data_markdown(config);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live",dataObj=dataObj);

start = getTickCount();
site = siteObj.loadSite(config.siteDef);
runtime = getTickCount() -start;

writeDump(site);

writeOutput("<p>Loaded site in <strong>#runtime#ms</strong></p>");




</cfscript>