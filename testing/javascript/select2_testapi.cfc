/*
# Select 2 Demo API

Return sample search results for testing Select 2.

See select2.html

*/
component  {
	
	variables.data = randomData();

	remote struct function search(string q="") returnformat="json" {
		var ret = {"results"=[]};
		local.data = getData();
		local.len = len(arguments.q);
		for (local.item in local.data) {
			if ((NOT local.len) OR Left(local.item.text,local.len) eq arguments.q) {
				ArrayAppend(ret.results, {"id":"id"=local.item.id,"text"=local.item.text});
			}
		}
		return local.ret;
	}

	public string function getOptions() format="json" {
		local.output = "";
		local.data = getData();
		local.group = "";

		for (local.data in local.data) {
			if (local.group neq local.data.group) {
				local.output &= (local.output eq "") ? "" : "</optgroup>";
				local.output &= "<optgroup label='#local.data.group#'>";
			}
			local.output &= "<option>" & local.data.text & "</option>";
			local.group = local.data.group;
		}
		local.output &= "</optgroup>";
		return local.output;
	}

	public array function getData(max=50) {
		local.sample = this.randomData();
		data = [];
		local.id = 1;
		for (local.category =1 ; local.id <= arguments.max ; local.category += 1) {
			local.group = local.sample[local.id];
			local.id++;
			for (local.i = 1; i lte 10 and local.id <= arguments.max  ; i++) {
				ArrayAppend(data,{"id"=local.id,"group"=local.group,"text"=local.sample[local.id]});
				local.id++;
			}
		}

		return data;
	}

	private array  function randomData() {
		var arr= ["Status of Issue","Subject","Description","Issue Type","Category","Version","Milestone","Priority","Resolutions",
			"Assignee","Comment","Start Date","Due Date","Estimated Hours","Actual Hours","Add Issue","Edit Issue",
			"Copy Issue","Attach File to Issue","Link to Shared File","Related pull request","Search Issue","Find Issues",
			"Search by Keywords","Simple Search","Advanced Search","Search from all projects",
			"Customize the view of search results","Saving search criteria","Backup Backlog Data","Dashboard",
			"Global Navigation","Notification","Watching issues","Update issues at once","Subtasking","Project Home",
			"About Project Home","About the icons","Status","Category","Milestone","Milestone Calendar (iCalendar)",
			"Project Members","Profiles of Users","Project Setting","Burndown Chart","Issue Type","Summary of Issue Type"
			,"Edit Issue Type","Add Issue Type","Edit Details of Issue Type","Delete Issue Type","Category","Category",
			"Category Settings","Sample Category Names","Edit Category","List of Categories","Version / Milestone",
			"Version/Milestone","List of Versions/Milestones","Add Versions/Milestones","Edit Version/Milestone","Personal Settings",
			"About Personal Settings","Edit User Information","Email Notification","Language and Timezone Setting",
			"Change Password","Email Notification for each Project","Private Address Setting","API Settings","
			Rule to formatting texts (Backlog)","Rule to formatting texts (Markdown)","Wiki","Home","Toolbar",
			"Tag","Attach File","Export to PDF","Notification when Wiki is Added or Updated","Search","Side Bar",
			"Formatting Texts","Edit Table Directly","Example of Wiki","Additional Information","List of History",
			"Show Differences","Show Older Version","Tree view","File","Subversion","Git","Gantt Chart",
			"Burndown Chart","Star","Member","Custom field","Shortcut Key"];
		ArraySort(arr,"textnocase");

		return arr;
	}
}
