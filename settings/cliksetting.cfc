component {

	this.name = "Base setting";
	this.description = "Abstract setting type";
	variables.type = "base";
	variables.default = "No value";

	public struct function new() {
		var ret = {"value" = variables.default,"type"=variables.type};
		return ret;
	}

	public string function display(struct setting) {
		return  arguments.setting.value;
	}

	public string function css(struct name, struct setting) {
		return  "--#arguments.name#: #arguments.setting.value#";
	}

}