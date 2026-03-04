<cfscript>

dataset = {
	"name" = "test",
	"tag" = "about",
	"sort_order" = "sort_order  desc"
}


data = application.dataObj.getDataset(dataset);
writeDump(data);


writeDump(application.dataObj.getRecords(data));



</cfscript>