<cfscript>
/* 
 * run local tests against API using api_test
 */

api_testObj = new api_test();

writeDump(api_testObj.sampleFunction(action="remove"));

// api_testObj.testError();

</cfscript>