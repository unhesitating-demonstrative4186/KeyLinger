#!/bin/zsh

set -euo pipefail

project_dir="${0:A:h:h}"
localizations_dir="$project_dir/Sources/KeyLinger/Resources"
temporary_dir="$(mktemp -d /tmp/keylinger-localizations.XXXXXX)"

cleanup() {
    rm -rf "$temporary_dir"
}
trap cleanup EXIT

extract_keys() {
    /usr/bin/sed -E -n 's/^"([^"]+)"[[:space:]]*=.*/\1/p' "$1" | /usr/bin/sort
}

for table_name in Localizable.strings InfoPlist.strings; do
    reference_file="$localizations_dir/en.lproj/$table_name"
    reference_keys="$temporary_dir/${table_name}.reference"

    /usr/bin/plutil -lint "$reference_file" >/dev/null
    extract_keys "$reference_file" > "$reference_keys"

    for localization_file in "$localizations_dir"/*.lproj/"$table_name"; do
        locale_name="${localization_file:h:t}"
        localized_keys="$temporary_dir/${table_name}.${locale_name}"

        /usr/bin/plutil -lint "$localization_file" >/dev/null
        extract_keys "$localization_file" > "$localized_keys"

        if ! /usr/bin/diff -u "$reference_keys" "$localized_keys"; then
            print -u2 "$locale_name/$table_name 的文案键与 en.lproj 不一致"
            exit 1
        fi
    done
done

print "本地化校验通过"
