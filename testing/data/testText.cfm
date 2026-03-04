<cfscript>
config = {"dataFolder": expandPath("../../sample/_data/data")};
config.imageRoot = "/images/";

dataObj = new clikpage.data.data_text(config);

dataset = {
	"name" = "test",
	"tag" = "gallery",
	"sort_order" = "sort_order  desc"
}

dataset2 = {
	"name" = "test2",
	"tag" = "test2",
	"sort_order" = "pubdate"
}


writeDump(dataObj.getDataset(dataset));
writeDump(dataObj.getDataset(dataset2));


writeDump(dataObj.getRecords([]));



</cfscript>