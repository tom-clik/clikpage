<cfscript>
/*
 * Load a site definition
 */

// path = ExpandPath("./preview/config.json");
// fileData = fileRead(path );
// config = deserializeJSON(fileData);

config = {
    "layoutsFolder":ExpandPath("../../sample/_data/layouts"),
    "siteDef": siteDef=ExpandPath("../../sample/_data/sampleSite.xml")
};

siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");

start = getTickCount();
site = siteObj.loadSite(config.siteDef);
runtime = getTickCount() -start;

writeDump(site);

writeOutput("<p>Ran in <strong>#runtime#ms</strong></p>");


</cfscript>