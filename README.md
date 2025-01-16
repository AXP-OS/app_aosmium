AXP.OS WebView
=====
The [AXP.OS](https://axpos.org/) WebView

## Use

- This repository contains the compile scripts, patches, and prebuilt WebView providers
- The WebView here is not meant to be used as is, but compiled into an OS
- Standalone versions might be build as well
- Integration configs:
    - Bare: https://gitlab.com/divested-mobile/divestos-build/-/blob/master/Patches/Common/config_webview_packages.xml
    - With signature: https://gitlab.com/divested-mobile/divestos-build/-/blob/dc853bfdaecc73a273de252cf555c9a3b6a38864/Patches/Common/config_webview_packages.xml

## Automation

CI/CD has been implemented in 2 workflows:
1. building: [.gitea/workflows/build.yaml](.gitea/workflows/build.yaml)
1. signing: [.gitea/workflows/sign.yaml](.gitea/workflows/sign.yaml)
   - release

### Building

_Building_ will be triggered when:
- `build-trigger.txt` changes

[build-trigger.txt](build-trigger.txt) can be used as a workflow trigger only but also to _configure_ the build process itself (see the inline comments).

### Signing + Release

_Signing_ will be triggered when:
- `prebuilt/*/webview-unsigned.apk` changes
- `sign-trigger.txt` changes
- a _build_ finished (as that will change the apk's)

increasing the counter in [sign-trigger.txt](sign-trigger.txt) is usually **not** needed (as it runs anyways on apk pushes and one can trigger a workflow manually within the actions tab) but kept as an alternative method to force the signing + release process.

Notes:
1. Releases will be set to **pre-release** as every build needs to be (mannually) tested first
1. Pre-releases need to be set as stable _manually_

### CI/CD Signature

```
Signer #1 certificate DN: CN=APK SIGNING KEY, OU=AXP.OS, O=AXP.OS, L=N/A, ST=N/A, C=DE
Signer #1 certificate SHA-256 digest: 005c9805d501bf50c1a8bfd3204b6908843088581fdcf3db8ab4f688ffc0e7b6
Signer #1 certificate SHA-1 digest: 53c4021704a4a565e4833d0620eb38f6808e1316
Signer #1 certificate MD5 digest: 4ff29417c66aeb46375d9e9913b9ffd2
Signer #1 key algorithm: EC
Signer #1 key size (bits): 521
Signer #1 public key SHA-256 digest: f002a63815f5433343677dcbabe110bd1a83a3483136fc97d6385bbe09088bc4
Signer #1 public key SHA-1 digest: 4248c76806aa5a8d5fb897061c3fc01414becf9d
Signer #1 public key MD5 digest: b6c4006030da70fd1a1692c0124ac18f


Full Signature:
MIICajCCAcugAwIBAgIJAKKFzP6qpdgWMAoGCCqGSM49BAMEMGUxCzAJBgNVBAYTAkRFMQwwCgYDVQQIEwNOL0ExDDAKBgNVBAcTA04vQTEPMA0GA1UEChMGQVhQLk9TMQ8wDQYDVQQLEwZBWFAuT1MxGDAWBgNVBAMTD0FQSyBTSUdOSU5HIEtFWTAeFw0yNTAxMDgxNzAxMjNaFw0zNTAxMDYxNzAxMjNaMGUxCzAJBgNVBAYTAkRFMQwwCgYDVQQIEwNOL0ExDDAKBgNVBAcTA04vQTEPMA0GA1UEChMGQVhQLk9TMQ8wDQYDVQQLEwZBWFAuT1MxGDAWBgNVBAMTD0FQSyBTSUdOSU5HIEtFWTCBmzAQBgcqhkjOPQIBBgUrgQQAIwOBhgAEAOhJfTYKhxYAs391+zrDZVKxtMnKkDvoFQfUHrl/HLCwK+c9X9kSHXaG7DcEzBPtEc7105CUyhk9YtN5GNCphnSqAa7fG5v4nngeTOFplZUq295outNAjT0NlWFWuA+3ei3JV43AzQGimH5EQ/UD9CpFemLoAQpUlOMU5tr5BWzAyUsqoyEwHzAdBgNVHQ4EFgQUpv+2CCk3423DCp5oTA5bZmxYX9owCgYIKoZIzj0EAwQDgYwAMIGIAkIBrPhoYHbix9fESALKBCQvW2Z4RULHJs7CwFSEc71rNN30QWHA5W8sRkfUgZJzFGcFQmhf8nHUISMWpRFm0kdszkUCQgHhWodLT3JmqiR1Eg5fU5oo4cdijJft50slR1u7gTiTamY5SmuohJvLO51LhmgnRN1uCE69yYloqvfvoIoaSBdmyA==
```

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
