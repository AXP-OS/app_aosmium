#!/bin/bash
#########################################################################################
#
# Helper script for fetching, patching and building the AXP.OS WebView (fka Mulch)
#
# Copyright (c) 2020-2024 Divested Computing Group
# Copyright (c) 2025 AXP.OS <steadfasterX |AT| binbash #DOT# rocks>
#
# License: GPLv2
#########################################################################################
set -e

# grab latest published Vanadium tag
real_latestVanadium=$(git ls-remote --tags https://github.com/GrapheneOS/Vanadium.git "*.*.*" | cut -d '/' -f3 |grep -v '{' | sort -Vr | head -n 1)
latestVanadium="${vanadium_version:-$real_latestVanadium}"
relatedChromium=$(echo "${latestVanadium}" | cut -d '.' -f 1-4)
relatedChromiumCode=$(echo "${relatedChromium}" | cut -d '.' -f 3-4 | tr -d '.')

echo "Latest available Vanadium version: $latestVanadium"
echo "Related Chromium version: $relatedChromium"

# set version based on Vanadium or user input
chromium_version="${chromium_version:-$relatedChromium}"
chromium_code="${chromium_code:-$relatedChromiumCode}"

echo "Using Vanadium version: $latestVanadium"
echo "Using Chromium version: $chromium_version"
echo "Using Chromium code: $chromium_code"

chromium_code_config="2024041800"
chromium_rebrand_name="AOSmium"
chromium_rebrand_color="#800080" # Purple icon
chromium_packageid_webview="org.axpos.aosmium_wv"
chromium_packageid_standalone="org.axpos.aosmium"
chromium_packageid_libtrichrome="org.axpos.aosmium_tcl"
chromium_packageid_config="org.axpos.aosmium_config"
#unzip -p chromium.apk META-INF/[SIGNER].RSA | keytool -printcert | grep "SHA256:" | sed 's/.*SHA256:* //' | sed 's/://g' |  tr '[:upper:]' '[:lower:]'
#chromium_cert_trichrome="260e0a49678c78b70c02d6537add3b6dc0a17171bbde8ce75fd4026a8a3e18d2"
#chromium_cert_config="260e0a49678c78b70c02d6537add3b6dc0a17171bbde8ce75fd4026a8a3e18d2"
clean=${clean:-0}
gsync=${gsync:-0}
pause=0
supported_archs=(arm arm64 x86 x64)
build_targets="${build_targets:-system_webview_apk}"
aosmiumPath="$PWD"

usage() {
    echo "Usage:"
    echo "  build [ options ]"
    echo
    echo "  Options:"
    echo "    -a <arch> Build specified arch"
    echo "    -c Clean"
    echo "    -h Show this message"
    echo "    -p pause before starting the build"
    echo "    -r <release> Specify chromium release"
    echo "    -s Sync"
    echo "    -C <path> to chromium directory"
    echo "    -V <path> to vanadium directory"
    echo
    echo "  Example:"
    echo "    build -c -s -r $chromium_version:$chromium_code"
    echo
    exit 1
}

build() {
    build_args=$args' target_cpu="'$1'"'

    code=$chromium_code
    if [ $1 '==' "arm" ]; then
        code+=00
    elif [ $1 '==' "arm64" ]; then
        code+=50
        #build_args+=' arm_control_flow_integrity="standard"'
    elif [ $1 '==' "x86" ]; then
        code+=10
    elif [ $1 '==' "x64" ]; then
        code+=60
    fi
    build_args+=' android_default_version_code="'$code'"'

    gn gen "out/$1" --args="$build_args"
    ninja -C out/$1 $build_targets
    if [ "$?" -eq 0 ]; then
        [ "$1" '==' "x64" ] && android_arch="x86_64" || android_arch=$1
        [[ "$build_targets" =~ "system_webview_apk" ]] && cp out/$1/apks/SystemWebView.apk $aosmiumPath/prebuilt/$android_arch/webview-unsigned.apk
        [[ "$build_targets" =~ "chrome_public_apk" ]] && cp out/$1/apks/ChromePublic.apk $aosmiumPath/prebuilt/$android_arch/browser-unsigned.apk
    fi
}

copy_vanadium_patches(){
    cd $vanadiumPath
    git fetch --all
    git checkout $latestVanadium
    if [ -d "$aosmiumPath/patches/0001-Vanadium/" ];then rm -r "$aosmiumPath/patches/0001-Vanadium/";fi
    mkdir $aosmiumPath/patches/0001-Vanadium/
    cp patches/* $aosmiumPath/patches/0001-Vanadium/
    cd $aosmiumPath/patches/0001-Vanadium/
    bash ../rm-vanadium.sh
}

install_build_deps(){
    cd $chromiumPath/src
    ./build/install-build-deps.sh --no-prompt \
    --no-chromeos-fonts \
    --no-syms \
    --no-backwards-compatible

    cd $aosmiumPath
}

while getopts ":a:chpr:sC:V:" opt; do
    case $opt in
        a) for arch in ${supported_archs[@]}; do
               [ "$OPTARG" '==' "$arch" ] && build_arch="$OPTARG"
           done
           if [ -z "$build_arch" ]; then
               echo "Unsupported ARCH: $OPTARG"
               echo "Supported ARCHs: ${supported_archs[@]}"
               exit 1
           fi
           ;;
        c) clean=1 ;;
        h) usage ;;
        r) version=(${OPTARG//:/ })
           chromium_version=${version[0]}
           chromium_code=${version[1]}
           ;;
        p) pause=1 ;;
        s) gsync=1 ;;
        :)
          echo "Option -$OPTARG requires an argument"
          echo
          usage
          ;;
        \?)
          echo "Invalid option:-$OPTARG"
          echo
          usage
          ;;
        C) chromiumPath="$OPTARG" ;;
        V)
        vanadiumPath="$OPTARG"
        [ ! -d "$vanadiumPath" ] && echo -e "ERROR: cannot find specified path >$vanadiumPath< !\nDo you have cloned Vanadium?" && usage
        ;;
    esac
done
shift $((OPTIND-1))

# Add depot_tools to PATH
if [ ! -d depot_tools ]; then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
else
    cd depot_tools
    git pull
fi
export PATH="$(pwd -P)/depot_tools:$PATH"

if [ $gsync -eq 1 ]; then
    echo "Syncing"
    if [ -d $chromiumPath/src/.git ];then
        echo "Updating sources"
        find $chromiumPath/src -name index.lock -delete
        cd $chromiumPath/src
        git reset --hard 2>>/dev/null || true
        git add -A 2>>/dev/null || true
        git commit -m "build.sh: before-rebase" || true
        git rebase-update
        cd ..
        yes | gclient sync --jobs=12 --force --delete_unversioned_trees --reset --revision="$chromium_version"
    else
        echo "Initial source download"
        cd $chromiumPath
        fetch --nohooks android || true
a        yes | gclient sync --jobs=12 --force --delete_unversioned_trees --reset --revision="$chromium_version"
    fi

    gclient runhooks

    # workaround for android sdk which keeps on 35!?
    if [ ! -d src/third_party/android_sdk/public/platforms/android-36 ];then
        cp -a ../tools/android-36 src/third_party/android_sdk/public/platforms/
    fi

    cd $aosmiumPath
fi

# install dependencies
install_build_deps

# fix permission denied errors:
find $chromiumPath/src -type d -name bin -exec chmod -R +x {} \;

applyPatchReal() {
	currentWorkingPatch=$1;
	firstLine=$(head -n1 "$currentWorkingPatch");
	if [[ "$firstLine" = *"Mon Sep 17 00:00:00 2001"* ]] || [[ "$firstLine" = *"Thu Jan  1 00:00:00 1970"* ]]; then
		if git am "$@" 2>/dev/null ; then
            echo "Applied (git am): $currentWorkingPatch"
			git format-patch -1 HEAD --zero-commit --no-signature --output="$currentWorkingPatch"
        else
		    echo "Applying (git am): $currentWorkingPatch - fallback"
		    git am --abort 2>/dev/null|| true
		    echo "Applying (patch fallback): $currentWorkingPatch"
		    patch -r - --no-backup-if-mismatch --forward --ignore-whitespace --verbose -p1 < $currentWorkingPatch \
      			&& git add -A > /dev/null\
      		    	&& git commit --author="$(grep -i From: $currentWorkingPatch | cut -d ' ' -f2-100)" -m "$(grep -i Subject: $currentWorkingPatch | cut -d ' ' -f3-100)"
                if [ $? -ne 0 ];then
                    echo "ERROR applying $currentWorkingPatch"
                    return 3
                else
                    echo "Applying (am - patch fallback): $currentWorkingPatch - SUCCESS"
                fi
		fi
	else
        echo "Applying (as diff): $currentWorkingPatch"
		git apply "$@" \
            && git add -A > /dev/null\
      		&& git commit --author="$(grep -i From: $currentWorkingPatch | cut -d ' ' -f2-100)" -m "$(grep -i Subject: $currentWorkingPatch | cut -d ' ' -f3-100)"
        if [ $? -ne 0 ];then
            echo "ERROR: applying $currentWorkingPatch (diff)"
            return 3
        else
            echo "Applying (as diff): $currentWorkingPatch - SUCCESS"
        fi
	fi
}
export -f applyPatchReal;

applyPatch() {
	currentWorkingPatch=$1;
	if [ -f "$currentWorkingPatch" ]; then
		if git apply --check "$@" &> /dev/null; then
			applyPatchReal "$@";
		else
			if git apply --reverse --check "$@" &> /dev/null; then
				echo "Already applied: $currentWorkingPatch";
			else
				if git apply --check "$@" --3way &> /dev/null; then
                    echo "Applying (as 3way): $currentWorkingPatch"
					applyPatchReal "$@" --3way;
                else
	 				echo "Applying (last resort): $currentWorkingPatch"
    			    applyPatchReal "$@"
	 			fi
                if [ $? -ne 0 ];then
					echo -e "\e[0;31mERROR: Cannot apply: $currentWorkingPatch\e[0m"
                    exit 3
				fi
			fi
		fi
	else
		echo -e "\e[0;31mERROR: Patch doesn't exist: $currentWorkingPatch\e[0m"
        exit 3
	fi
}
export -f applyPatch;

cd $chromiumPath/src

# Apply our changes
if [ $gsync -eq 1 ]; then
    cd $aosmiumPath
    copy_vanadium_patches
    cd $chromiumPath/src

	#Apply all available patches safely
	echo "Applying patches"
	find $aosmiumPath/patches/0001-Vanadium/ -name "*.patch" -print | sort -n | xargs -I '{}' bash -c 'applyPatch "$0"' {} \;;
	find $aosmiumPath/patches/0002-LineageOS/ -name "*.patch" -print | sort -n | xargs -I '{}' bash -c 'applyPatch "$0"' {} \;;
	find $aosmiumPath/patches/0003-Cromite/ -name "*.patch" -print | sort -n | xargs -I '{}' bash -c 'applyPatch "$0"' {} \;;

	#Icon rebranding
	echo "Icon rebranding"
	#mkdir -p android_webview/nonembedded/java/res_icon/drawable-xxxhdpi
    find chrome/android/java/res_chromium_base/mipmap-* -type f -name 'app_icon*.png' -exec convert {} -colorspace gray -fill "$chromium_rebrand_color" -tint 75 -gamma 0.6 {} \;
    find chrome/android/java/res_chromium_base/mipmap-* -type f -name 'layered_app_icon*.png' -exec convert {} -colorspace gray -fill "$chromium_rebrand_color" -tint 75 -gamma 0.6 {} \;
    cp chrome/android/java/res_chromium_base/mipmap-mdpi/app_icon.png android_webview/nonembedded/java/res_icon/drawable-mdpi/icon_webview.png
	cp chrome/android/java/res_chromium_base/mipmap-hdpi/app_icon.png android_webview/nonembedded/java/res_icon/drawable-hdpi/icon_webview.png
	cp chrome/android/java/res_chromium_base/mipmap-xhdpi/app_icon.png android_webview/nonembedded/java/res_icon/drawable-xhdpi/icon_webview.png
	cp chrome/android/java/res_chromium_base/mipmap-xxhdpi/app_icon.png android_webview/nonembedded/java/res_icon/drawable-xxhdpi/icon_webview.png
	#cp chrome/android/java/res_chromium_base/mipmap-xxxhdpi/app_icon.png android_webview/nonembedded/java/res_icon/drawable-xxxhdpi/icon_webview.png

	#String rebranding, credit Vanadium
	echo "String rebranding"
	sed -ri 's/(Google )?Chrom(e|ium)/'$chromium_rebrand_name'/g' chrome/android/java/res_chromium_base/values/channel_constants.xml chrome/app/chromium_strings.grd chrome/browser/ui/android/strings/android_chrome_strings.grd components/browser_ui/strings/android/site_settings.grdp components/components_chromium_strings.grd components/new_or_sad_tab_strings.grdp components/page_info_strings.grdp components/security_interstitials_strings.grdp;
	find components/strings/ -name '*.xtb' -exec sed -ri 's/(Google )?Chrom(e|ium)/'$chromium_rebrand_name'/g' {} +;
	find chrome/browser/ui/android/strings/translations -name '*.xtb' -exec sed -ri 's/(Google )?Chrom(e|ium)/'$chromium_rebrand_name'/g' {} +;
	sed -i 's/Android System WebView/'$chromium_rebrand_name' System WebView/' android_webview/nonembedded/java/AndroidManifest.xml;

	#Config stuff
	#sed -i 's/Vanadium/'$chromium_rebrand_name'/' vanadium/android_config/BUILD.gn;
	#sed -i 's/TAG = "VanadiumConfigBridge"/TAG = "'$chromium_rebrand_name'ConfigBridge"/' base/android/java/src/org/chromium/base/config/VanadiumConfigBridge.java;
	#sed -i 's/app.vanadium.config/'$chromium_packageid_config'/' vanadium/android_config/config_apk_vars.gni;
	#sed -i 's/min_sdk_version = 29/min_sdk_version = 27/' vanadium/android_config/config_apk.gni;

	#Prepare the filter lists
	#python vanadium/android_config/filter_lists/filter_list_download.py --output vanadium/android_config/filter_lists/filter_lists.txt --urls https://easylist.to/easylist/easylist.txt https://easylist.to/easylist/easyprivacy.txt https://divested.dev/hosts-domains-wildcards https://filters.adtidy.org/extension/ublock/filters/11.txt https://filters.adtidy.org/extension/ublock/filters/17.txt https://filters.adtidy.org/extension/ublock/filters/18.txt https://filters.adtidy.org/extension/ublock/filters/19.txt https://filters.adtidy.org/extension/ublock/filters/20.txt https://filters.adtidy.org/extension/ublock/filters/21.txt https://filters.adtidy.org/extension/ublock/filters/22.txt https://filters.adtidy.org/extension/ublock/filters/2.txt https://filters.adtidy.org/extension/ublock/filters/3.txt https://filters.adtidy.org/extension/ublock/filters/4.txt https://malware-filter.gitlab.io/phishing-filter/phishing-filter.txt https://malware-filter.gitlab.io/urlhaus-filter/urlhaus-filter-ag-online.txt https://ublockorigin.github.io/uAssets/filters/annoyances-cookies.txt https://ublockorigin.github.io/uAssets/filters/badware.txt https://ublockorigin.github.io/uAssets/filters/filters.txt https://ublockorigin.github.io/uAssets/filters/lan-block.txt https://ublockorigin.github.io/uAssets/filters/privacy.txt https://ublockorigin.github.io/uAssets/filters/quick-fixes.txt https://ublockorigin.github.io/uAssets/filters/unbreak.txt
	#wc -l vanadium/android_config/filter_lists/filter_lists.txt
fi

if [ $pause -eq 1 ]; then
  read -p "Check-point: Press ENTER to start the build or Ctrl+C to abort"
fi

# Build args
args='target_os="android"'
args+=' android_channel="stable"' #Release build
args+=' android_default_version_name="'$chromium_version'"'
args+=' disable_fieldtrial_testing_config=true'
args+=' is_chrome_branded=false'
args+=' is_component_build=false'
args+=' is_official_build=true'
args+=' use_official_google_api_keys=false'
args+=' webview_devui_show_icon=false'
args+=' blink_symbol_level=0' #Release optimizations
args+=' v8_symbol_level=0'
args+=' is_debug=false'
args+=' symbol_level=0'
args+=' dfmify_dev_ui=false' #Don't build as module
args+=' ffmpeg_branding="Chrome"' #Codec support
args+=' proprietary_codecs=true'
args+=' use_login_database_as_backend=true' #Enable password manager without GMS
args+=' enable_nacl=false' #Unncessary
args+=' enable_resource_allowlist_generation=false'
args+=' enable_remoting=false'
args+=' enable_arcore=false'
args+=' enable_openxr=false'
args+=' enable_cardboard=false' # virtual reality (VR) platform by Google
args+=' enable_vr=false'
args+=' use_official_google_api_keys=false'
args+=' chrome_pgo_phase=false'
args+=' include_both_v8_snapshots=false'
args+=' system_webview_package_name="'$chromium_packageid_webview'"' #Package IDs
args+=' chrome_public_manifest_package="'$chromium_packageid_standalone'"'
args+=' trichrome_library_package="'$chromium_packageid_libtrichrome'"'
args+=' trichrome_certdigest="'$chromium_cert_trichrome'"'
args+=' is_cfi=true' #Security
args+=' use_cfi_cast=true'
args+=' use_relative_vtables_abi=false'
args+=' enable_reporting=false' #Privacy
args+=' use_v8_context_snapshot=false' # see https://github.com/uazo/cromite/pull/317 for context
args+=' include_both_v8_snapshots=false' # see https://github.com/uazo/cromite/blob/c00bb4e191c836301b797f913b57a2c54f32b068/build/chromium.gn_args#L8-L9
args+=' is_high_end_android=false' # TESTING. optimize ressource usage for low-end Android devices (drawbacks in performance for high end?!)
#args+=' use_relr_relocations=true' # optimize speed+size, requires SDK28+ though!

#args+=' config_apk_package="'$chromium_packageid_config'"' #Config app
#args+=' config_apk_certdigest="'$chromium_cert_config'"'
#args+=' config_apk_version_name="'$chromium_code_config'"'
#args+=' config_apk_version_code="'$chromium_code_config'"'
#args+=' config_apk_is_debug=false'

# Setup environment
[ $clean -eq 1 ] && rm -rf out && echo "Cleaned out"
. build/android/envsetup.sh

# Check target and build
if [ -n "$build_arch" ]; then
    build $build_arch
else
    echo "Building all"
    build arm
    build arm64
    #build x86
    #build x64
fi
