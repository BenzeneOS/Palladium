# Palladium

Palladium is a privacy and security hardened variant of Chromium providing the WebView and standard browser for [BenzeneOS](https://github.com/BenzeneOS). It is based on [Vanadium](https://github.com/GrapheneOS/Vanadium) from GrapheneOS with additional features and customizations.

## Features

In addition to Vanadium's privacy/security hardening:

- **Chrome Extension Support** - Install extensions from Chrome Web Store
- **Kagi Search Engine** - Built-in as a search engine option
- **Custom Search Engines** - Add your own search engines manually (no OpenSearch auto-detection wait)
- **Privacy Features** - AMP removal, automatic cookie consent acceptance
- **Fingerprinting Mitigations** - Additional protections against browser fingerprinting
- **Edge Swipe Navigation** - Configurable swipe gestures

## Building

### Prerequisites

- Linux build environment
- depot_tools
- ~100GB disk space

### Setup

```bash
# Clone this repo
git clone https://github.com/BenzeneOS/Palladium.git
cd Palladium

# Fetch Chromium source (uses depot_tools)
fetch --nohooks chromium
cd src
git checkout 144.0.7559.59  # current stable version
gclient sync --with_branch_heads --with_tags -D

# Apply patches (in order)
cd ..
for patch in patches/*.patch; do
    git -C src am --keep-non-patch "$patch"
done

# Run gclient sync again to apply subproject patches via hooks
cd src
gclient runhooks
```

Note: Patches 0214-0218 set up automatic application of subproject patches (v8, search_engines_data) via gclient hooks. Patch 0240 adds Kagi search engine support.

### Build

```bash
cd src
mkdir -p out/palladium
cp ../args.gn out/palladium/args.gn
gn gen out/palladium
autoninja -C out/palladium trichrome_chrome_64_apk trichrome_library_64_apk trichrome_webview_64_apk
```

## License

See LICENSE files for details. Based on Chromium (BSD-style) and Vanadium (GPL-2.0).
