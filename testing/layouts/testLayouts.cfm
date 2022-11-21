<cfscript>
layoutsObj = new clikpage.layouts.layouts(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutsObj.getLayout("testlayout1/testlayout1");

WriteDump(mylayout);

WriteOutput(HtmlCodeFormat(mylayout.layout.html()));
// WriteOutput(HtmlCodeFormat(layoutObj.getHTML(mylayout.layout)));
</cfscript>