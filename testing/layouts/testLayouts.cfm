<cfscript>
layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testlayout1/testlayout5");

writeDump(mylayout);

WriteOutput("<pre>" & HtmlEditFormat(mylayout.layout.body().html()) & "</pre>");
</cfscript>