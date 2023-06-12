<cfscript>
local.markdown = new markdown.flexmark(attributes=1);

local.mytest = FileRead(ExpandPath("../../sample/_data/data/articles/article1.md"),"utf-8");
local.data = {};
local.html = local.markdown.toHtml(local.mytest,local.data);
writeDump(local.data);
</cfscript>
