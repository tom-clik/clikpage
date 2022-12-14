<cfscript>
cfinclude(template="testContent_include.cfm");

menu = contentObj.new(id="topmenu",title="menu",type="menu");
menu.data = siteObj.getDataSet(site=site,dataset={"tag"="",type="sections"});

request.data = site.sections;

testCS(menu);

</cfscript>