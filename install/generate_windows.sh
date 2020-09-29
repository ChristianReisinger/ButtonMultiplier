#!/bin/bash

profile_dir="../user/profiles"
out_names="../impl/generated/WindowNames.ahk"
out_gestures="../impl/generated/GestureEnable.ahk"
out_includes="../impl/generated/ProfileIncludes.ahk"

for out in "$out_names" "$out_gestures" "$out_includes"; do
	mkdir -p "$(dirname "$out")"
done


echo -e "; *** this file is generated by install.sh *** \n\n" > "$out_names"
echo -e "; *** this file is generated by install.sh *** \n\n" > "$out_gestures"
echo -e "; *** this file is generated by install.sh *** \n\n" > "$out_includes"

echo "#Include ${profile_dir#../}/Default.ahk" >> "$out_includes"

echo '
get_fkey_function_name_prefix() {
	Switch
	{' >> "$out_names"

echo -n '
gesture_enabled() {
	if 0 ' >> "$out_gestures"

##### the following is a bit of a hack to avoid dealing with windows linebreaks ... #####
for f in "${profile_dir}/"*.ahk; do
	window_def="$(head -n1 "$f" | grep -oE -m1 '[[:alpha:]]+[[:space:]]+"[^"]+"')" && (
		window_name="$(echo "$window_def" | sed -nr 's/([[:alpha:]]+)[[:space:]]+"[^"]+"/\1/p')"
		window_title="$(echo "$window_def" | sed -nr 's/[[:alpha:]]+[[:space:]]+("[^"]+")/\1/p')"

		echo "#Include ${f#../}" >> "$out_includes"

		echo '		Case WinActive('"$window_title"'):	prefix := "'"$window_name"'"' >> "$out_names"

		grep -qE "${window_name}(_wheel_up|_wheel_down)?_gesture[[:space:]]*\([[:space:]]*[A-Za-z0-9_]*[[:space:]]*\)[[:space:]]*\{" "$f" || (
			echo -n "|| WinActive($window_title) " >> "$out_gestures"
		)
	)
done


echo '
		Default:	prefix := "default"
	}
	return prefix
}
' >> "$out_names"

echo '{
		return false
	}
	return true
}' >> "$out_gestures"