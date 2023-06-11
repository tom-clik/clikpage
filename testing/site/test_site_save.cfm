<cfscript>
/*
 * Load a site definition and save it
 *
 * ## Usage
 *
 * Uses the site definition in ./preview/config.json
 *
 */

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");
siteObj.contentObj.loadButtonDefFile(ExpandPath("/_assets/images/buttons.xml"));

site = siteObj.loadSite(config.siteDef);
start = getTickCount();
files = siteObj.save(site=site,outputDir=ExpandPath("_out"),debug=0);
runtime = getTickCount() -start;
writeDump(files);

writeOutput("<p>Saved in <strong>#runtime#ms</strong></p>");


</cfscript>