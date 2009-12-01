Flashless
=========

*This is the development site of Flashless. If you are interested in the product visit [github.com/flashless](http://useless.github.com/flashless/).*

**Flashless** is a Cocoa WebKit plug-in to display preview images for Flash based video services and block the rest. Requires Mac OS X 10.5 Leopard or later.

The plugin registers itself for Flash content (`application/x-shockwave-flash`) and is displayed by the browser when it encounters Flash embedded in a website. If the user clicks the plugin area the plugin converts the type of the embedded element to `application/futuresplash` which is handled by the original Flash plugin.

*Note:* This idea is taken from the ClickToFlash project. (See bottom of this document.)

Unlike existing Flash blockers we try to identify the blocked source and preview its content when supported. This works quite well for most video services. On some of them we can even download the video directly.

For supported video services see `Services.txt`.

Changelog
=========

Version 2.0.2 (Latest Release)
-------------
_The Birds_

* Disable Direct Play and Download for missing video IDs.

* Fix Blip.tv redirection.

* Reenable TwitVid downloads.

* Use custom spinner to show activity.


Version 2.0.1
-------------
_Panic_

* Adjust YouTube download on other sites.

* Remove TwitVid download due to site changes.


Version 2.0
-----------
_Delegation_

* Use delegate messages for retrieval of preview/download/original URLs.

* Support for Blip.tv, Flickr, Vimeo, and universal YouTube downloads.

* Use video tag with poster for direct play without Flash.

* Keep preview image aspect ratio.

* Improved icons, redrawing and tracking behaviour.

* Display icons also in small elements.


Version 1.5
-----------
_Clusterimage_

* Supports Mac OS X 10.6 Snow Leopard.

* 32 and 64 bit universal binary for Intel and PowerPC.

* Includes target for building a disk image for easier distribution.

* Clearer usage of download feature by displaying the download indicator only when pressing the option key.

* Use a class cluster for service support.


Version 1.4
-----------
_Blackwhite_

* Can open YouTube-Page for a video.

* Allows showing or removing of all flash instances.

* Allows automatic showing or removing from a source for the rest of the session.


Version 1.3
-----------

* Uses new icon for unknown flash content.

* Previews Flickr.

* Previews and downloads Google Video.

* Allows temporary removal of a Flash object from a site.

* Corrects handling of URLs with spaces.


Version 1.2
-----------

* Draws a circular play button for known video services.

* Displays a Flash-Badge for unknown contents.

* Previews Viddler and Vimeo.


Version 1.1
-----------

Initial public release.

***

This project is somewhat based on **ClickToFlash** (<http://github.com/rentzsch/clicktoflash>).
