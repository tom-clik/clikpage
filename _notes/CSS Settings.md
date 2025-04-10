# CSS Classes

To ensure that all styling can be applied only through setting simple css variables, we use a mechanism which we call `CSS Classes`. As an example, carousels have properties `carousel-contain` and `carousel-freeScroll`.

This can be set in a style sheet so

```
#mygrid {
	--carousel-contain: 0;
	--carousel-freeScroll: 1
}
```

The JavaScript then reads these from the CSS and initialised the plug in with them in. The resize method of the page will pickup changes to these var (according to media queries) and re-apply the plug in.

## getSettings script

A script, getSettings.js is supposed to be used to get these. These are a couple of ad-hoc implementations in `clik_onready` that need to be updated.

The script looks for the "type" in `clik_settings` (see following) and retrieves a struct of settings.

It then looks for each of these in the CSS settings and applies a default if required. 

Each setting has a "type" to ensure correct formatting of the value (really only booleans are an issue).

## Clik_settings

The details of the settings are saved automatically to a JavaScript file `clik_settings.js`. This is done with a script `testing\tools\saveSettingsData.cfm`. 

When the settings in any of the type components are updated, this will need running and the static JS packages updating.
