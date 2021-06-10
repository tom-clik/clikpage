# Clikpage

Simple Page builder Framework for CFML

## Introduction

Clikpage provides a mechanism for managing JS and CSS scripts in a CFML application.

## Usage

Designed as a singleton pattern module for instantiation in the application scope, each "page" is a simple struct of data to keep memory overheads down.

Every component on a page (e.g. a menu) adds required javascript and css either by reference (e.g. "jquery"), by filename, or with inline code.

E.g.

You create the page content in onRequestStart:

    request.prc.content = application.pageObj.getContent();

A photo gallery component would require a static Jquery library ("megagallery"), and some inline javascript to go into the onready:
     
     request.prc.content.static_js["megagallery"] = 1;
     request.prc.content.onready &= "$(""##gallery"").megagallery({speed:2000})";

The gallery might also set the page title:

    request.prc.content.title = "Gallery " & mygallery.gallery_name;

A page is typically rendered in the onRequestEnd method.

    WriteOutput(application.clikpage.html(request.prc.content));

## Static File Definitions

To reference css or js by name you create static file definitions in json. 

"scripts": [
        {
            "debug": "/_assets/js/jquery-3.4.1.js",
            "min": "https://code.jquery.com/jquery-3.4.1.min.js",
            "name": "jquery",
            "packageExclude": 1
        },





