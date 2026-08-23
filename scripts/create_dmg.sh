#!/bin/zsh

set -euo pipefail

project_dir="${0:A:h:h}"
version="${1:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$project_dir/Resources/Info.plist")}"
version="${version#v}"
app_path="$project_dir/dist/KeyLinger.app"
output_path="$project_dir/dist/KeyLinger-v${version}-macOS-universal.dmg"

if [[ ! -d "$app_path" ]]; then
    print -u2 "未找到 $app_path，请先运行 ./build_app.sh release universal"
    exit 1
fi

architectures="$(/usr/bin/lipo -archs "$app_path/Contents/MacOS/KeyLinger")"
if [[ "$architectures" != *"arm64"* || "$architectures" != *"x86_64"* ]]; then
    print -u2 "KeyLinger.app 不是 Universal Binary：$architectures"
    exit 1
fi

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
