<!---

Load a site and call  siteCSS


// see test_settingsObj. This no longer works.

--->



<cfscript>

path = ExpandPath("../site/preview/config.json");
fileData = fileRead(path );
config = deserializeJSON(fileData);

dataObj = new clikpage.data.data_text(config);
siteObj = new clikpage.site.site(layoutsFolder=config.layoutsFolder,mode="live",dataObj=dataObj);

site = siteObj.loadSite(config.siteDef);

outfile = ExpandPath("output/test_settings.css");

siteObj.contentObj.debug = true;
css = siteObj.siteCSS(site=site);

fileWrite(outfile, css);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>