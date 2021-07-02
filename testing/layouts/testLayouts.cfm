<cfscript>
layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testlayout1/testlayout2");

WriteDump(mylayout);

WriteOutput("<pre>" & HtmlEditFormat(layoutObj.getHTML("testlayout1/testlayout2")) & "</pre>");
</cfscript>