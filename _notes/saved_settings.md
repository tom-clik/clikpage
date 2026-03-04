# Saved settings

Definition files and other "system" data relating to the different content types is saved automatically from the system.

This is then used by the JavaScript components to generate the editing pages and also in the [](varclasses.md) mechanism.

To do this, there is a script in `/testing/tools/saveSettingsData.cfm` that saves the data to `/_assets/js/clik_settings.js`. This generates the setting information and a struct of option data ( e.g. for  `halign` the options for `left,center,right`).

The setting information contains the following keys:

1. panels - the list of text panels that can be styled with standard panel styling (border etc)
2. states - e.g. hover. 
3. styleDefs - the definition of the different properties. Each option has a `type` that will pick up the default editing options from settingsEdit, or else the information can be specified explicitly.

The actual types seems are also defined in the object. They have a default description (bit ropey at the minute), this is used as a default for the actual styleDefs. 

## Settings Types

Listed in the settings object, but not exported, these have the title and descriptions for settings. If a setting does not defined them itself, these will be used.

E.g. in a menu content section, a setting is defined as

```
"align" = {type="halign","description","Align the menu to the left, center, or right"};
```

The "title" value will be picked up as 




