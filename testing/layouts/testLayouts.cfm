<cfscript>
layoutObj = createObject("component", "clikpage.layouts.layouts").init(getDirectoryFromPath(getCurrentTemplatePath()));

mylayout = layoutObj.getLayout("testlayout1/testlayout2");

writeDump(mylayout);

WriteOutput(HTMLEDiTFORMAT(mylayout.layout.body().html()));
</cfscript>