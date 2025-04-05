/** Apply testing classes as selected by user */
function setTest(test) {
	var $bodyhere = $("body");
	console.log("Setting test ", test);
	$bodyhere.removeClassByPrefix("layout-");
	$bodyhere.addClass("layout-" + test);
	window.location.hash = test;
}

// This is the menu of different sample layouts
function demoMenu(tests) {
	var html = "<select>\n";
	for (let test of tests) {
		selected = test.id == hash ? " selected" : ""; 
		html += `<option${selected} value="${test.id}">${test.description}</option>\n`;
	}
	html += "</select>\n";

	$(html).appendTo("#testmenu").on("change", function( ) {
		var test = $(this).val()

		setTest(test);
		$(window).trigger('throttledresize');
	});
}