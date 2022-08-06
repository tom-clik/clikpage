<!---

# Tables CSS

Done via classes

Ready to be Clikicised

--->

<!DOCTYPE html>
<html>
<head>
	<title>Table tests</title>

	<meta charset="UTF-8">
	<link rel="stylesheet" type="text/css" href="reset.css">
	<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/tables.css">
	<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/columns.css">
	<link rel="stylesheet" type="text/css" href="_styles/asset_proxy.cfm?asset=css/forms.css">
	<style type="text/css">
		
	
		body {
			--title-font:font-family: 'Open Sans';
		}

		table {
			--table-cell-padding:8px;
		}

		table.info {
			--table-border-color: #303030;
			--table-stripe-bg: #c3c3c3;
		}

		table.info th {
			--table-bg: black;
			--table-text: white;
		}

		table.info td, table.info th {
			--table-border-color: #c3c3c3;
		}

		table.info tr td:nth-of-type(3) {
			--table-font-weight:bold;
			--table-text-align:right;	
		}

		
	</style>
</head>
<body>
<table class="">
	<thead>
		<tr>
			<th>COl 1</th>
			<th>COl 2</th>
			<th>COl 3</th>
		</tr>
	</thead>
	<tbody>
		<tr><td>Lorem ipsum dolor sit ame</td><td>t, consectetur adipisicing</td><td> elit, sed do eiusmod</td></tr>
		<tr><td>tempor incididunt ut labo</td><td>re et dolore magna aliqua.</td><td> Ut enim ad minim veniam,</td></tr>
		<tr><td>quis nostrud exercitation</td><td> ullamco laboris nisi ut </td><td>liquip ex ea commodo</td></tr>
		<!-- <tr><td>consequat. Duis aute irur</td><td>e dolor in reprehenderit i</td><td>n voluptate velit esse</td></tr> -->
		<tr><td>cillum dolore eu fugiat n</td><td>ulla pariatur. Excepteur s</td><td>int occaecat cupidatat non</td></tr>
		<tr><td>proident, sunt in culpa q</td><td>ui officia deserunt mollit</td><td> anim id est laborum.</td></tr>
	</tbody>

</table>

<table class="info">
	<thead>
		<tr>
			<th>COl 1</th>
			<th>COl 2</th>
			<th>COl 3</th>
		</tr>
	</thead>
	<tbody>
		<tr><td>Lorem ipsum dolor sit ame</td><td>t, consectetur adipisicing</td><td> elit, sed do eiusmod</td></tr>
		<tr><td>tempor incididunt ut labo</td><td>re et dolore magna aliqua.</td><td> Ut enim ad minim veniam,</td></tr>
		<tr><td>quis nostrud exercitation</td><td> ullamco laboris nisi ut </td><td>liquip ex ea commodo</td></tr>
		<tr><td>consequat. Duis aute irur</td><td>e dolor in reprehenderit i</td><td>n voluptate velit esse</td></tr>
		<tr><td>cillum dolore eu fugiat n</td><td>ulla pariatur. Excepteur s</td><td>int occaecat cupidatat non</td></tr>
		<tr><td>proident, sunt in culpa q</td><td>ui officia deserunt mollit</td><td> anim id est laborum.</td></tr>
	</tbody>

</table>



</body>
</html>