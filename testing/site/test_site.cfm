<cfscript>
siteObj = new clikpage.site.siteObj();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../../sample/_data/sampleSite.xml"));

writeDump(site);

// writeDump(siteObj.menuData(site=site,sections=site.sectionlist));

// writeDump(site);

// html= FileRead(expandPath("../layouts/testlayout1/testlayout1.html"));
// writeOutput(HTMLEDitFormat(siteObj.dataReplace(site=site, html=html, sectioncode="home")));

</cfscript>