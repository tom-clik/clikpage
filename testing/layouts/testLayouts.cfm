<cfscript>
layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testlayout1/testlayout6");

WriteDump(mylayout);

WriteOutput("<pre>" & HtmlEditFormat(layoutObj.getHTML(mylayout.layout)) & "</pre>");
</cfscript>