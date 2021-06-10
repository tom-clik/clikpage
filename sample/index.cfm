<cfscript>



request.prc.content.title = "Home page";
request.prc.content.onready &= "alert('hello world');";

WriteOutput("<p>Normally you would include some sort of templating system. You can also remove the savecontent from onRequest() and update the struct implicitly.</p>");

</cfscript>