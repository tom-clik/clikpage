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
		
		variables.static_css = {
			"forms"=1,
			"select2"=1
		};
		variables.static_js = {
			"clikForm"=1
		};

		this.settings = {
			"form" = {
				"showlabel" = 1,
				"align" = "left"
			}
		};
		
		/* TODO: modernise to panels */
		this.styleDefs = [
			"field-border-color": {"type":"color"},
			"form-stripe-background-color": {"type":"color"},
			"form-label-width": {"type":"dimension"},
			"form-label-gap": {"type":"dimension"},
			"form-row-gap": {"type":"dimension"},
			"field-padding": {"type":"dimensionlist"},
			"input-padding": {"type":"dimensionlist"},
			"form-width": {"type":"dimension"},
			"field-checkbox-width": {"type":"dimension"},
			"field-border-width": {"type":"dimension"},
			"field-border-style": {"type":"text"},
			"field-background-color": {"type":"color"},
			"form-font": {"type":"text"},
			"form-color": {"type":"color"}
		];

		return this;
	}

	public string function html(required struct content) {
		
		return fileRead("form_html_temp.html");

	}

	public string function onready(required struct content) {
		var js = "$(""###arguments.content.id#"").clikForm({
			debug:false,
			rules : {
				field1: {
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