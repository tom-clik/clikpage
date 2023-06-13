<cfscript>
cfinclude(template="testContent_include.cfm");

myform = contentObj.new(id="form",title="Dummy form",type="form",content="");
local.xmlData = XmlParse(  contentObj.contentSections.form.sampleForm() );
local.formdata = application.XMLutils.xml2data(local.xmlData);
myform.data = contentObj.contentSections.form.parseForm(formdata=local.formdata);

testCS(myform);

</cfscript>