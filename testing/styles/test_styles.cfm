<!---

Load a site and call  siteCSS

--->

<cfscript>
layoutsFolder = expandPath("../../sample/_data/layouts");
siteFile = expandPath("../../sample/_data/sampleSite.xml");

siteObj = new clikpage.site.site(layoutsFolder=layoutsFolder,mode="live");
site = siteObj.loadSite(siteFile);

styleSettings = siteObj.settingsObj.loadStyleSettings(ExpandPath("../../sample/_data/styles/sample_stylesettings.xml"));

outfile = ExpandPath("output/test_settings.css");

siteObj.contentObj.debug = true;
css = siteObj.siteCSS(site=site,debug=false);

fileWrite(outfile, css);

WriteOutput("<pre>" & HtmlEditFormat(css) & "</pre>");

</cfscript>