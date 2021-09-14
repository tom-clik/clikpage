# StaticFiles component {#static_files}
 
Allows for easy inclusion of static files (js,css) in a web page

## Usage

### Configuration

Configure a definition along the lines of the defaults. See [Scripts](#static_files_scripts){.xref} and [Packages](#static_files_scripts){.xref} below for details.

The script array is the order in which the scripts must appear.

### Use

NB this can be used on its own but is designed for use the the `pageObject` component.

If you do want to just use this, you can instantiate the component in a permanent scope and initialise with the definition and your required prefix/suffix

To add files of packages, add to a "set" (a struct with a redundant key), e.g.

    js_static["myscript"] = 1
 
To get the script/style tags for an HTML page, use the `getLinks()` method, e.g.

    getLinks(js_static);

To use the "debug" versions (if specified) call the method with `getLinks(js_static,true);`

#### Scripts {#static_files_scripts}

Scripts (meaning css or js files) are defined as an array of objects with the following keys

:name
The name by which the script is referenced
:min
src of the production version of the script (usually minimised or such). Can only be omitted if the script is in a bundled package.
:debug
The debug version of the script. Can be omitted if a min version is specified. In debug mode, scripts are always included seperately even if in a bundled package
:requires
List or array of required scripts. Always include all required scripts even if it's something as common as jquery
:packageExclude (boolean)
Always show separate file even if in a package that is bundled. Typically the "min" script will be served from a CDN

Note the order of the array is the order the scripts appear in the page.

Sample script entry

```
{
    "debug": "/_assets/js/jquery.validate.js",
    "min": "https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.1/jquery.validate.js",
    "name": "validate",
    "packageExclude": 1,
    "requires": "jquery"
}
```

#### Packages {#static_files_scripts}

Groups of scripts can be defined in packages. These are added in the same way as normal scripts, e.g. for the package defined below:

    js_static["main"] = 1

These can include scripts like jquery that won't be "bundled". For any given script definition, the packageExclude
field can be set to true to ensure the individual script is always used, usually from a CDN.

A package can also be set to not to be packed. Otherwise an "min" attribute must be set for the packaged files (the src). Even if all scripts are marked packageExclude you must still supply either pack:false or a "min" src.

The static object can make attempts at packaging using legacy java components but this is off-piste. Gulp or other systems can also be used.

```
packages": [
        {
            "scripts": [
                "jquery",
                "jqueryui",
                "validate",
                "fuzzy",
                "metaforms",
                "datatables",
                "select2"
            ],
            "pack":false,
            "name":"main"
        }
    ]
```
