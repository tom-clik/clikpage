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
			//local.text = FileRead("form_html_temp.html")
			//arguments.content.data = parseForm(local.text);
			throw("data not defined for cs form");
		}

		var html = this.recordsObj.form(
			record=arguments.content.data,
			data={},
			errors={}
		);
		
		return html;

	}

	public string function sampleForm() {
		return fileRead("form_html_temp.html");
	}

	public struct function parseForm(required formdata) {
		return this.recordsObj.record(arguments.formdata);
	}


	public string function onready(required struct content) {
		var js = "$(""###arguments.content.id#"").clikForm({
			debug:false,
			rules : {
				field1: {
			    	required: true,
			    	minlength: 20
			    },
			    email: {
			    	required: true,
			    	email: true
			    },
			    field2: {
			    	required: true,
			    	rangelength: [2, 3]
			    },
			    field3: {
			    	required: true			    	
			    },
			    field4: {
			    	required: true		
			    }
			},
			messages: {
		        field1: {
		            required: 'Email address is required',
		            email: 'Please enter a valid email address'
		        },
		        field2: 'Please select 2 or 3 items',
		        field3: 'select some values',
		        field6: 'Please tick you agree to our terms and conditions'
		    }

		});";

		return js;
	}


}