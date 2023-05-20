<cfscript>
/* 
 * run local tests against API using settings_api_test
 *
 * ## Synopsis
 *
 * We use settings_api_test to extend the API and change the return method
 * to return ColdFusion data not JSON. This allows us to test the functions
 * without going via http or having to deserialize Json.
 */

api_testObj = new settings_api_test();

data = api_testObj.css(
cs_id = "test_imagegrid",
settings= "{'cs_id':'test_imagegrid','grid-mode':'fixedwidth','grid-fit':'auto-fit','grid-width':'160px','grid-max-width':'1fr','grid-columns':'2','grid-gap':'10','grid-template-columns':'','grid-template-rows':'','grid-template-areas':'','justify-content':'flex-start','align-items':'flex-start','flex-direction':'row','flex-stretch':'0','flex-wrap':'wrap','layout':'standard','popup':'0','grid-max-height':'','caption-position':'bottom','align-frame':'start','justify-frame':'start','object-fit':'scale-down','subcaptions':'0','contain':'0','freeScroll':'0','wrapAround':'0','pageDots':'0','prevNextButtons':'0'}"
);

writeDump(application.settingsTest.site.cs["test_imagegrid"].settings);

writeOutput("<pre>" & data.css & "</pre>");

// writeDump(api_testObj.sampleFunction(action="remove"));

</cfscript>