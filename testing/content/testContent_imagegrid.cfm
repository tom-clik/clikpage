<cfscript>
cfinclude(template="testContent_include.cfm");

cs = contentObj.new(id="imagegrid",title="imagegrid",type="imagegrid");
cs.data = siteObj.getDataSet(site=site,dataset={tag="gallery",type="images"});
request.data = site.images;

testCS(cs);
</cfscript>