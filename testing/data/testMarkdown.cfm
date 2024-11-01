<cfscript>
config = {"dataFolder": expandPath("../../sample/_data/data")};

dataObj = new clikpage.data.data_text(config);

dataset = {
	"name" = "test",
	"tag" = "test",
	"sort_order" = "pubdate desc"
}

dataset2 = {
	"name" = "test2,sections",
	"tag" = "sections",
	"sort_order" = "pubdate desc"
}


writeDump(dataObj.getDataset(dataset));
writeDump(dataObj.getDataset(dataset2));


writeDump(dataObj.getRecords([]));



</cfscript>