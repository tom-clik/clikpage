/*

Parse a CSS style stylesheet into a struct

## NOTES

Our CSS stylesheets are nested with values for panels, media, and component settings

E.g.

```css
#ubercontainer {
	height:100%;
	padding:0 0 20px 0;
	inner {
		height:100%;
	}
	grid {
		grid-mode:templateareas;
		grid-template-areas:"header" "pagecontent" "footer";
		grid-template-rows:min-content 1fr min-content;
	}
	@mobile {
		grid {
			grid-mode:none;
		}
	}
}
```

To parse this, we use a recursive loop checking the depth of the curly brackets.

The result is a nested Struct. Note we don't actually use the @, #, or . at the start of the identifier.

*/
component {

	public cssParser function init() {
		variables.patternObj = createObject( "java", "java.util.regex.Pattern");
		// pattern to remove comments
		variables.commentpattern = variables.patternObj.compile("\/\*[^*]*\*+([^/*][^*]*\*+)*\/", variables.patternObj.MULTILINE + variables.patternObj.UNIX_LINES);
		// pattern to characets from start of "key"
		variables.keypattern = variables.patternObj.compile("[##\.]");
		return this;
	}

	/**
	 * Parse a css string into a nested struct
	 */
	public struct function parse(string css) {
		
		var ret = {};
		arguments.css = REReplace(arguments.css, "[\t\r\n]+", " ","all");
		arguments.css = variables.commentpattern.matcher(arguments.css).replaceAll("");

		parseChildren(data=ret, text=arguments.css);

		return ret;

	}

	/**
	 * @hint move root settings "up" into "main" medium
	 *
	 * When styles are defined, the settings for the main medium
	 *  are just in the root. For consistency, we put them into
	 *  a key "main".
	 *
	 */
	public void function addMainMedium(required struct styles) {
		local.main = [=];
		local.keys = StructKeyArray(arguments.styles);
		for (local.setting in local.keys) {
			if (left(local.setting,1) NEQ "@") {
				local.main[local.setting] = arguments.styles[local.setting];
				structDelete(arguments.styles, local.setting);
			}
			else {
				arguments.styles[ListFirst(local.setting,"@")] = arguments.styles[local.setting];
				structDelete(arguments.styles,local.setting);
			}
		}
		arguments.styles["main"] = local.main;
		
	}

	/**
	 * Recursive loop function to do the parsing
	 */
	private void function parseChildren(required struct data, required string text) {
		
		local.depth = 0;
		local.len = Len(arguments.text);
		local.value = "";
		local.keyname = "";
		local.inKeyName = true;

		for (local.i = 1; local.i lte local.len; local.i++) {
			local.char = Mid(arguments.text,local.i ,1);
			switch (local.char) {
				case " ":
					if (!local.inKeyName) {
						local.value  &= local.char;
					}
					continue;
					break;
				case "{":
					if (local.depth eq 0) {
						local.inKeyName = false;
					}
					else {
						local.value  &= local.char;
					}
					local.depth++;
					break;
				case ":":
					if (local.depth eq 0) {
						local.inKeyName = false;
					}
					else {
						local.value  &= local.char;
					}
					break;
				case ";":
					if (local.depth eq 0) {
						local.keyname = checkKeyName(local.keyname);
						arguments.data["#local.keyname#"] = Trim(local.value);
						local.keyname = "";
						local.inKeyName = true;
						local.value = "";
					}
					else {
						local.value  &= local.char;
					}
					break;
				case "}":
					local.depth--;
					if (local.depth eq 0) {
						local.keyname = checkKeyName(local.keyname);
						arguments.data["#local.keyname#"] = {};
						parseChildren(data=arguments.data["#local.keyname#"],text=local.value);
						local.keyname = "";
						local.inKeyName = true;
						local.value = "";
					}
					else {
						local.value  &= local.char;
					}
					break;
				default:
					if (local.inKeyName) {
						local.keyname &= local.char;
					}
					else {
						local.value  &= local.char;
					}

			}
		
		}

	}

	/*
	Remove characters from start of key name.
	*/
	private string function checkKeyName(required string keyname) {
		return variables.keypattern.matcher(arguments.keyname).replaceAll("");
	}

}