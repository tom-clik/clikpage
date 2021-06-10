<cfscript>
contentObj = createObject("component", "clikpage.contentObj").init();
contentObj.debug = true;

siteObj = createObject("component", "clikpage.site.siteObj").init();

siteObj.debug = true;

site = siteObj.loadSite(ExpandPath("../site/testSite.xml"));

text = contentObj.new(id="list",title="Articles",type="articlelist");
text.data = siteObj.getData(site=site,tag="test");

writeOutput("<pre>" & contentObj.css(text) & "</pre>");

html=contentObj.html(text);
writeOutput( HTMLEditFormat(contentObj.wrapHTML(content=text,html = html)));



</cfscript>