<cfscript>

WriteOutput("<p>Apply chosen to a select box in a form</p>");

WriteOutput("<form id='formtest'><select id='test' name='test'>");
for (i = 1; i <= 10; i++ ) {
	WriteOutput("<option value='#i#'>Option #i#</option>");
}
WriteOutput("</select></form>");

request.prc.content.title = "A form";

request.prc.content.static_js["chosen"] = 1;
request.prc.content.static_css["chosen"] = 1;
request.prc.content.css &= "##formtest {width:400px;}  select {width:100%}";
request.prc.content.onready &= "$('##test').chosen();";

</cfscript>