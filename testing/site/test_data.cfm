<cfscript>
siteObj = createObject("component", "clikpage.site.siteObj").init();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("./testSite.xml"));

WriteDump(siteObj.getData(site=site,tag="test"));

WriteDump(siteObj.getData(site=site,tag="test2"));


</cfscript>