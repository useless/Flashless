Flashless
=========

<http://useless.github.com/flashless/>

*A WebKit plug-in to display preview images for Flash based video services and block the rest.*

Unlike existing Flash blockers we try to identify the blocked source and preview its content when supported. This works quite well for most video services. On some of them we can even download the video directly.

For supported video services see `Services.txt`.


Install
-------

*Requires Mac OS X 10.5 Leopard or later.*

* Quit *Safari*.
* Drag the icon labeled *Flashless.webplugin* from the disk image to the icon labeled *Internet Plug-Ins*.
* Relaunch *Safari*. Done.

**Note:** This will install *Flashless* for all users. To install just for the current user, copy 
*Flashless.webplugin* to `∼/Library/Internet Plug-Ins` instead.


Changes and Source
------------------

For the version history see `CHANGELOG`.

The source is available as Github or the Bitbucket mirror.
<http://github.com/useless/Flashless>
<http://bitbucket.org/useless/flashless>


How it works
------------

**Flashless** is a Cocoa plug-in for WebKit-browsers to display preview images for Flash based video services and block the rest.

The plugin registers itself for Flash content (`application/x-shockwave-flash`) and is displayed by the browser when it encounters Flash embedded in a website. If the user clicks the plugin area the plugin converts the type of the embedded element to `application/futuresplash` which is handled by the original Flash plugin.


Acknowledgement
---------------

Flashless is originally based on **ClickToFlash** (<http://github.com/rentzsch/clicktoflash>).
