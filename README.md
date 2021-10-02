![Banner](https://divestos.org/images/featureGraphics/Mulch.png)

Mulch
=====
The DivestOS WebView

Use
---
- This repository contains the compile scripts, patches, and prebuilt WebView providers
- The WebView here is not meant to be used as is, but compiled into an OS
- Standalone versions of Mulch for all systems are available here: https://divestos.org/pages/our_apps#mulch
- Can be updated out of band via F-Droid repo: https://divestos.org/pages/our_apps#repos
- Integration configs:
    - Bare: https://gitlab.com/divested-mobile/divestos-build/-/blob/master/Patches/Common/config_webview_packages.xml
    - With signature: https://gitlab.com/divested-mobile/divestos-build/-/blob/dc853bfdaecc73a273de252cf555c9a3b6a38864/Patches/Common/config_webview_packages.xml

Goals
-----
- Minimizing anti-features
- Included patches must be very simple to minimize maintenance
- Becoming a "privacy" browser is out of scope, use Mull instead

Notes
-----
- This repo will only keep one version at a time
- This repo will be reinitialized often
- x86 and x86_64 will track from LineageOS due to excessive compile times

Credits
-------
- Nearly all of the patches are from GrapheneOS's Vanadium browser
    - License: GPL-2.0-only with exceptions
    - Upstream: https://github.com/GrapheneOS/Vanadium
- The build script and makefiles are from LineageOS
    - License: Apache-2.0
- Additional patches from Cromite
    - License: GPL-2.0-or-later
    - Upstream: https://github.com/uazo/cromite
- (previously) Additional patches from Bromite
    - License: GPL-3.0
    - Upstream: https://github.com/bromite/bromite
- Banner backdrop from Paul Green
    - License: Unsplash
    - Author: https://unsplash.com/@pgreen1983
    - Original: https://unsplash.com/photos/mGQfQe3EOBI
