<cfscript>
layoutObj = new clikpage.layouts.layouts(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testlayout1/testlayout6");

WriteDump(mylayout);

WriteOutput(HtmlCodeFormat(mylayout.layout.html()));
// WriteOutput(HtmlCodeFormat(layoutObj.getHTML(mylayout.layout)));
</cfscript>