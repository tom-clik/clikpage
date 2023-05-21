/*
Place holder for client side messages
*/
messageHandler = {

	log: function(message) {
		console.log(message);
	},
	warn: function(message) {
		console.warn(message);
	},
	error: function(message) {
		alert(message);
		console.error(message);
	},
	ok: function(message) {
		alert(message);
	}

}