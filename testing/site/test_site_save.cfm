<cfscript>
/*
 * Load a site definition and save it
 *
 * ## Usage
 *
 * Uses the site definition in ./preview/config.json
 *
 */

savecontent variable="nully" {
    cfinclude( template="test_site.cfm" );
}

outputDir=ExpandPath("_out");
pages = directoryList(outputDir,true,"path","*.js|*.html|*.css");
for (page in pages) {
    fileDelete(page);
}

start = getTickCount();
files = siteObj.save(site=site,outputDir=outputDir,debug=1);
runtime = getTickCount() -start;
writeDump(files);

writeOutput("<p>Saved in <strong>#runtime#ms</strong></p>");


</cfscript>