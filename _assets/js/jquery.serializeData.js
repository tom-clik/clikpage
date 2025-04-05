// Create a proper struct of form data with arrays for checkboxes and
// blank entry for unticked boxes (or 0 if there is only one box and its
// value is 1: good for booleans)

(function($){
	$.fn.serializeData = function(ops){
		var data = {};
		var $form = $(this);
		$form.find(":input").filter("[name]").each(function() {
			$field = $(this);
			let type = $field.attr('type') || $field.prop("tagName").toLowerCase();
			let name = $field.attr("name");
			// have weird bug where multiple submissions
			// create hidden field with no name and value of submit button
			if (name == "") {
				return;
			}
			switch(type) {
				case "checkbox":
					// do we have multiple values?
					let count = $form.find("input[name=" + name + "]").length;
					if (count > 1) {
						if (! (name in data)) {
							data[name] = [];
						}
						if ($field.is(':checked')) {
							data[name].push($field.val());
						}
					}
					else {
						let offVal = ($field.val() == "1") ? "0" : "";
						data[name] = ($field.is(':checked')) ? $field.val() : offVal;
						
					}
					break;
				case "radio":
					if (! (name in data)) {
						data[name] = "";
					}
					if ($field.is(':checked')) {
						data[name] = $field.val();
					}
					break;
				case "button":case "cancel":
					break;
				default:
					data[name] = $field.val();
			}

		});
		return data;
	}
}(jQuery));
