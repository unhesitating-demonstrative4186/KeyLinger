#!/bin/zsh

set -euo pipefail

project_dir="${0:A:h}"
configuration="${1:-release}"
architecture="${2:-native}"

if [[ "$configuration" != "release" && "$configuration" != "debug" ]] || \
   [[ "$architecture" != "native" && "$architecture" != "arm64" && \
      "$architecture" != "x86_64" && "$architecture" != "universal" ]]; then
    print -u2 "用法: ./build_app.sh [release|debug] [native|arm64|x86_64|universal]"
    exit 2
fi

cd "$project_dir"
if [[ "$architecture" == "universal" ]]; then
    swift build -c "$configuration" --arch arm64
    arm_binary_dir="$(swift build -c "$configuration" --arch arm64 --show-bin-path)"
    swift build -c "$configuration" --arch x86_64
    x86_binary_dir="$(swift build -c "$configuration" --arch x86_64 --show-bin-path)"

    binary_dir="$project_dir/.build/keylinger-universal/$configuration"
    mkdir -p "$binary_dir"
    /usr/bin/lipo \
        -create \
        "$arm_binary_dir/KeyLinger" \
        "$x86_binary_dir/KeyLinger" \
        -output "$binary_dir/KeyLinger"
elif [[ "$architecture" == "arm64" || "$architecture" == "x86_64" ]]; then
    swift build -c "$configuration" --arch "$architecture"
    binary_dir="$(swift build -c "$configuration" --arch "$architecture" --show-bin-path)"
else
    swift build -c "$configuration"
    binary_dir="$(swift build -c "$configuration" --show-bin-path)"
fi

app_dir="$project_dir/dist/KeyLinger.app"

mkdir -p "$app_dir/Contents/MacOS"
mkdir -p "$app_dir/Contents/Resources"
install -m 755 "$binary_dir/KeyLinger" "$app_dir/Contents/MacOS/KeyLinger"
install -m 644 "$project_dir/Resources/Info.plist" "$app_dir/Contents/Info.plist"
install -m 644 "$project_dir/Resources/AppIcon.icns" "$app_dir/Contents/Resources/AppIcon.icns"
/usr/bin/ditto "$project_dir/Sources/KeyLinger/Resources" "$app_dir/Contents/Resources"
touch "$app_dir"
/usr/bin/codesign \
    --force \
    --deep \
    --sign - \
    --requirements '=designated => identifier "local.keylinger"' \
    "$app_dir"

print "已生成：$app_dir"
print "架构：$(/usr/bin/lipo -archs "$app_dir/Contents/MacOS/KeyLinger")"
