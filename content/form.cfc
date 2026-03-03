/**
 * 
 */

component extends="contentSection" {
	
	variables.type = "form";
	variables.title = "form";
	variables.description = "Display a form";
	variables.defaults = {
		"title"="Untitled",
		"content"="Undefined content",
	};

	function init(required content contentObj) {
		
		super.init(arguments.contentObj);
		this.recordsObj = new articlemanager.records();

		variables.static_css = {
			"forms"=1,
			"select2"=1
		};
		variables.static_js = {
			"clikForm"=1
		};

		this.styleDefs = [
			"form-display": {
				"type":"list","options": [
					{"name":"Grid","value":"grid"},
					{"name":"Normal","value":"block"}
				],
				"default":"grid"
			},
			"form-stripe-background-color": {"type":"color"},
			"form-label-width": {"type":"dimension"},
			"form-label-gap": {"type":"dimension"},
			"form-row-gap": {"type":"dimension"},
			"field-padding": {"type":"dimensionlist"},
			"row-padding": {"type":"dimensionlist"},
			"field-checkbox-width": {"type":"dimension"},
			"field-border-color": {"type":"color"},
			"field-border-width": {"type":"dimension"},
			"field-background-color": {"type":"color"}
		];

		return this;
	}

	public string function html(required struct content) {
		if (! StructKeyExists(arguments.content, "data") ) {
			throw("data not defined for cs form");
		}
		var html = [];
		html.append("<form action=''>");
		loop collection=arguments.content.data key="local.q" value="local.val" {
			html.append("<div class='fieldrow'>");
			html.append("	<div class='fieldLabel'>");
			html.append("	<label>");
			html.append("		#local.val.label#");
			html.append("	</label>");
			html.append("	<div class='button'><a><i class='icon-help'></i></a></div>");
			html.append("	</div>");
			html.append("	<div class='field'>");
			html.append("		<input type='text' name='#local.q#'>");
			html.append("	</div>");
			html.append("</div>");
		}

		html.append("<div class='fieldButtons'>");
		html.append("	<div class='fieldSpace'><label>&nbsp;</label></div>");
		html.append("	<div>");
		html.append("		<div class='button'>");
		html.append("			<input type='submit' value='Submit'>");
		html.append("		</div>");
		html.append("	</div>");
		html.append("</div>");
		html.append("</form>");
		
		return html.toList("");

	}

	public string function sampleForm() {
		return fileRead("form_html_temp.html");
	}

	public struct function parseForm(required formdata) {
		local.form = [=];
		for ( local.val in arguments.formdata ) {
			StructAppend(local.val, {"type"="textarea","required"=false,"label"=local.val.name}, false);
			if ( local.val.required ) {
				if ( ! 
						( local.val.keyExists("message") ) OR
						( local.val.keyExists("messages") 
							&& local.val.messages.keyExists("required")
						)
				    ) {
					 local.val.message = "Please enter a value for #local.val.label#";

				}
			}
			local.form["#local.val.name#"] = local.val;
		}
		
		return local.form;

	}


	public string function onready(required struct content) {
		
		var data = {
			"debug":false,
			"rules" : {},
			"messages" : {}
		};

		loop collection=arguments.content.data key="local.q" value="local.val" {
			if ( local.val.required ) {
				data.rules["#local.q#"]["required"] = true;
			}
			if ( local.val.keyExists("message" ) ){
				data.messages["#local.q#"] = local.val.message;
			}
		}

		var js = "$(""###arguments.content.id#"").clikForm(#serializeJSON(data)#);";

		return js;
	}

	
}