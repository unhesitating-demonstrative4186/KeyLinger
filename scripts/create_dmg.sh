#!/bin/zsh

set -euo pipefail

project_dir="${0:A:h:h}"
bundle_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$project_dir/Resources/Info.plist")"
if [[ "${1:-}" == "arm64" || "${1:-}" == "x86_64" || "${1:-}" == "universal" ]]; then
    version="$bundle_version"
    requested_architecture="$1"
else
    version="${1:-$bundle_version}"
    requested_architecture="${2:-auto}"
fi
version="${version#v}"
app_path="$project_dir/dist/KeyLinger.app"

if [[ ! -d "$app_path" ]]; then
    print -u2 "未找到 $app_path，请先运行 ./build_app.sh release <架构>"
    exit 1
fi

architectures="$(/usr/bin/lipo -archs "$app_path/Contents/MacOS/KeyLinger")"
if [[ "$requested_architecture" == "auto" ]]; then
    if [[ "$architectures" == "arm64" ]]; then
        requested_architecture="arm64"
    elif [[ "$architectures" == "x86_64" ]]; then
        requested_architecture="x86_64"
    elif [[ "$architectures" == *"arm64"* && "$architectures" == *"x86_64"* ]]; then
        requested_architecture="universal"
    else
        print -u2 "无法识别 KeyLinger.app 的架构：$architectures"
        exit 1
    fi
fi

case "$requested_architecture" in
    arm64)
        artifact_architecture="Apple-Silicon"
        if [[ "$architectures" != "arm64" ]]; then
            print -u2 "期望 arm64 App，实际架构为：$architectures"
            exit 1
        fi
        ;;
    x86_64)
        artifact_architecture="Intel"
        if [[ "$architectures" != "x86_64" ]]; then
            print -u2 "期望 x86_64 App，实际架构为：$architectures"
            exit 1
        fi
        ;;
    universal)
        artifact_architecture="universal"
        if [[ "$architectures" != *"arm64"* || "$architectures" != *"x86_64"* ]]; then
            print -u2 "期望 Universal App，实际架构为：$architectures"
            exit 1
        fi
        ;;
    *)
        print -u2 "用法: ./scripts/create_dmg.sh [版本] [arm64|x86_64|universal]"
        print -u2 "   或: ./scripts/create_dmg.sh [arm64|x86_64|universal]"
        exit 2
        ;;
esac

output_path="$project_dir/dist/KeyLinger-v${version}-macOS-${artifact_architecture}.dmg"

staging_dir="$(mktemp -d /tmp/keylinger-dmg.XXXXXX)"
cleanup() {
    rm -rf "$staging_dir"
}
trap cleanup EXIT

/usr/bin/ditto "$app_path" "$staging_dir/KeyLinger.app"
/bin/ln -s /Applications "$staging_dir/Applications"

/usr/bin/hdiutil create \
    -volname "KeyLinger" \
    -srcfolder "$staging_dir" \
    -ov \
    -format UDZO \
    "$output_path"

/usr/bin/hdiutil verify "$output_path"
print "已生成：$output_path"
