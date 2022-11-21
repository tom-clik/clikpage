<cfscript>
siteObj = new clikpage.site.site();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

writeDump(site);

</cfscript>