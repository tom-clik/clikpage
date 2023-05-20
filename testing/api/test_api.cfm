<cfscript>
/* 
 * run local tests against API using api_test
 *
 * ## Synopsis
 *
 * We use api_test to extend the main API and change the return method
 * to return ColdFusion data not JSON. This allows us to test the functions
 * without going via http or having to deserialize Json.
 */

api_testObj = new api_test();

writeDump(api_testObj.sampleFunction(action="remove"));

api_testObj.testError();

</cfscript>