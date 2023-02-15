<cfscript>

path = ExpandPath("./preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live");

site = siteObj.loadSite(config.siteDef);

writeDump(site);

</cfscript>