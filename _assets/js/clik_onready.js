// on ready to include in all pages
$(document).ready(function() {
	clik.resizeMethod = jQuery().throttledresize ? 'throttledresize' : 'resize';
	clik.clikContainers();
	clik.clikContent();
});
