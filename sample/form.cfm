<p>Applying various js to a form</p>

<form id='formtest'>
	<div>
		<label>Name</label>
		<div class="fieldWrap">
			<input id='name' name='name'>
		</div>
	</div>
	<div>
		<label>Email</label>
		<div class="fieldWrap">
			<input id='email' name='email'>
		</div>
	</div>
	<div>
		<label>Select one</label>
		<div class="fieldWrap">
			<select id='test' name='test'>
				<option value='1'>Option 1</option>
				<option value='2'>Option 2</option>
				<option value='3'>Option 3</option>
				<option value='4'>Option 4</option>
			</select>
		</div>
	</div>
	<div>
		<label>&nbsp;</label>
		<input type="submit">
	</div>
</form>

<cfscript>
request.prc.content.title = "A form";
request.prc.content.static_js["validate"] = 1;
request.prc.content.static_js["chosen"] = 1;
request.prc.content.static_css["chosen"] = 1;

request.prc.content.css &= "
	##formtest {width:400px;}  
";

request.prc.content.onready &= "$('##test').chosen();";
request.prc.content.onready &= "$('##formtest').validate({
	debug: true,
	rules: {
	    name: ""required"",
	    email: {
	    	required: true,
	    	email: true
		},
		messages: {
		    name: ""Please specify your name"",
		    email: {
		      required: ""We need your email address to contact you"",
		      email: ""Your email address must be in the format of name@domain.com""
		    }
		}
	}
});";

</cfscript>