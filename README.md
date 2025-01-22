# AOSmium - The AXP.OS Browser

The [AXP.OS](https://axpos.org/) documentation can be found: [here](https://github.com/AXP-OS/build/wiki/Browser)

## Use

- This repository contains the compile scripts, patches, and prebuilt WebView providers
- The WebView here is not meant to be used as is, but compiled into an OS
- Standalone versions might be build as well
- Integration config:
    - easily by using [EXTENDROM](https://github.com/sfX-android/android_vendor_extendrom) (`EXTENDROM_PACKAGES="AXP.OS_WebView64"` or `"AXP.OS_WebView32"`)
    - manually by adding [its signature](https://github.com/sfX-android/android_vendor_extendrom/blob/main/extra/webview_axp.os.sig.xml) to your overlay of `frameworks/base/core/res/res/xml/config_webview_packages.xml`

## Automation

CI/CD has been implemented in 2 workflows:
1. building: [.gitea/workflows/build.yaml](.gitea/workflows/build.yaml)
1. signing: [.gitea/workflows/sign.yaml](.gitea/workflows/sign.yaml)
   - release (see the [Release](README.md#release) topic!)

### Building

_Building_ will be triggered when:
- `trigger-build.txt` changes

[trigger-build.txt](trigger-build.txt) can be used as a workflow trigger only but also to _configure_ the build process itself (see the inline comments).

### Signing + Release

#### Signing

_Signing_ will be triggered when:
- `prebuilt/*/browser-unsigned.apk` changes
- ˋprebuilt/*/webview-unsigned.apkˋ changes
- `trigger-release.txt` changes
- a _build_ finished (as that will change the apk's)

increasing the counter in [trigger-release.txt](trigger-release.txt) is usually **not** needed (as it runs anyways on apk pushes and one can trigger a workflow manually within the actions tab) but kept as an alternative method to force the signing + release process.

#### Release

Releases will be created automatically during the _Signing_ workflow above.

1. Releases will be set to **pre-release** as every build needs to be (mannually) tested first
1. Pre-releases need to be set as stable _manually_
1. The signed releases will be created on the Codeberg mirror only and are available [here](https://codeberg.org/AXP-OS_releases/app_aosmium/releases)

### CI/CD Signature

This app is signed by the [AXP.OS app key](https://github.com/AXP-OS/build/wiki/Signatures#axpos-app-signature)

## Goals

- Minimizing anti-features
- Included patches must be very simple to minimize maintenance
- Becoming a "privacy" browser is out of scope, use Mull instead

## Notes

- x86 and x86_64 will not be provided

## Credits

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
