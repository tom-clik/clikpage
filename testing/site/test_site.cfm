<cfscript>
layoutsFolder = expandPath("../../sample/_data/layouts");
siteObj = new clikpage.site.site(layoutsFolder=layoutsFolder,mode="live");

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

writeDump(site);

</cfscript>