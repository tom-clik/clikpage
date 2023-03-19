<cfscript>

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");

start = getTickCount();
site = siteObj.loadSite(config.siteDef);
runtime = getTickCount() -start;
writeDump("Ran in #runtime#");

writeDump(site);

</cfscript>