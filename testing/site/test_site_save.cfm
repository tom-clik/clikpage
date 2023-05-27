<cfscript>
/*
 * Load a site definition and dump it
 *
 * ## Usage
 *
 * Uses the site dedinition in ./preview/config.json
 *
 * For a quick preview of another site, just change this filename e.g config_main.json
 * 
 */

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");
siteObj.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

site = siteObj.loadSite(config.siteDef);
start = getTickCount();
files = siteObj.save(site=site,outputDir=ExpandPath("_out"));
runtime = getTickCount() -start;
writeDump(files);

writeOutput("<p>Saved in <strong>#runtime#ms</strong></p>");


</cfscript>