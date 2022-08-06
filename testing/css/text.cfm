<!DOCTYPE html>
<html>
<head>
	<title>Title and heading font test</title>
	<link rel="stylesheet" type="text/css" href="reset.css">
	<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/text.css">
	<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?assetfonts/fonts_local.css">

	
	<meta charset="UTF-8">
	<style>
		body {
			--title-font: 'Open Sans';
			--text-font: 'Verdana';
		}
	
		.cs-title {
			--title-font-size: 200%;
		}

		.title {
			--title-font-size: 140%;
			font-weight: bold;
		}

		.scheme-crosshead {
			--heading-margin:0 0 1em  0;
			--heading-font: Lato;
			--heading-font-weight:300;
			--heading-font-align:center;
			--heading-color:teal;
		}

		.scheme-crosshead h1 {
			--heading-font-size: 200%;	
		}

		.scheme-crosshead h2 {
			--heading-font-size: 170%;	
		}

		.scheme-crosshead h3 {
			--heading-font-size: 130%;	
		}

		.scheme-crosshead h4 {
			--heading-font-size: 50%;	
		}

		/* styling for test page */

		.test {
			margin:12px;
			padding:20px;
		}
		.test-header {
			margin:0 -20px 12px -20px;
			font-family: 'Courier new';
		}

		
	</style>
</head>
<body>

	<div class="test">
		<div class="test-header">These tags should be plain</div>

		<h1>Testing h1 plain</h1>
		<h2>Testing h2 plain</h2>
		<h3>Testing h3 plain</h3>
	</div>

	<div class="test">
		<div class="test-header">These tags should all be styled according to the syles applied to .cs-title</div>
	
		<div class="cs-title">
			
			<p>Plain para in cs-title</p>

			<h1>h1 in cs-title</h1>
			<h2>h2 in cs-title</h2>
			<h3>h3 in cs-title</h3>

		</div>

	</div>
	<div class="test">

		<div class="test-header">These tags should all be styled according to the syles applied to .title</div>


		<div class="cs-somethingelese">
			<div class="title">Title for something else</div>
			<div class="title"><h1>.title h1 in cs-somethingelese</h1></div>
			<div class="title">	<h2>.title h2 in cs-somethingelese</h2></div>
			<div class="title">	<h3>.title h3 in cs-somethingelese</h3></div>
		</div>
	</div>
	<div class="test">
		<div class="test-header">These headings here should have the default heading .textWrap styling</div>

		<div class="textWrap">
			<h1>Testing h1 textWrap</h1>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h2>Testing h2 textWrap</h2>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h3>Testing h3 textWrap</h3>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h4>Testing h4 textWrap</h4>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h5>Testing h5 textWrap</h5>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h6>Testing h6 textWrap</h6>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
		</div>
	</div>

	<div class="test">
		<div class="test-header">These headings here have additional custom styling applied via scheme-crosshead</div>

		<div class="scheme-crosshead testWrap">
			<h1>Testing h1 textWrap</h1>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h2>Testing h2 textWrap</h2>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h3>Testing h3 textWrap</h3>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h4>Testing h4 textWrap</h4>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h5>Testing h5 textWrap</h5>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
			<h6>Testing h6 textWrap</h6>
			<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
			tempor incididunt ut labore et dolore magna aliqua. </p>
		</div>
	</div>

</body>
</html>