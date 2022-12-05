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
		
		
		this.panels = [
			{"name":"item","panel":"item", "selector": " a"},
			{"name":"icon","panel":"icon", "selector": " .icon"}
		];

		return this;
	}

	public string function css(required struct styles, required selector) {
		
		var css = "#arguments.selector# {
			max-width: 800px;
			margin:12px auto;
			border:1px solid var(--border-color);
			background-color: ##efefef;
			--field-background-color: white;
			--field-border-color: ##aaa;
			--input-padding: 8px;
		}

		.button {
			--button-border-color:var(--border-color);
			--button-border-width:1px;
			--button-border-style:solid;
			--button-background-color: white;
		}

		#arguments.selector# .fieldrow:nth-child(even) {
			background-color: ##e3e3e3;
		}";

		return css;

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