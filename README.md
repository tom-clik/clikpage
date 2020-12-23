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

A photo gallery component would require a static Jquery library ("mygallery"), and some inline javascript to go into the onready:
     
     request.prc.content.static_js["mygallery"] = 1;
     request.prc.content.onready &= "$(""##gallery"").mygallery({speed:2000})";

The gallery might also set the page title:

    request.prc.content.title = "Gallery " & mygallery.gallery_name;

A page is typically rendered in the onRequestEnd method.

    WriteOutput(application.clikpage.html(request.prc.content));





