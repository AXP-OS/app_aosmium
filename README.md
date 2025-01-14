![Banner](https://divestos.org/images/featureGraphics/Mulch.png)

Mulch
=====
The [AXP.OS](https://axpos.org/) WebView

Use
---
- This repository contains the compile scripts, patches, and prebuilt WebView providers
- The WebView here is not meant to be used as is, but compiled into an OS
- Standalone versions of Mulch might be build as well
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
- x86 and x86_64 will not be provided

Credits
-------
- Tad / DivestOS who puts an incredible amount of work into creating, building and maintaining Mulch until Dec 2024
    - Upstream: https://gitlab.com/divested-mobile/mulch
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
