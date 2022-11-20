<cfscript>
siteObj = new clikpage.site.siteObj();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

writeDump(site);

</cfscript>