#!/bin/bash

in="../user/settings.ini"
globals_out="../autoexec/generated/global_vars_user.ahk"
labels_out="../impl/generated/FKeyLabels.ahk"

for out in "$globals_out" "$labels_out"; do
	mkdir -p "$(dirname "$out")"
done

echo -e "; *** this file is generated by install.sh *** \n\n" > "$labels_out"


fs="$(grep 'FButtons: ' "$in")"
fs="${fs#*: }"

function flabels {
num=$1

echo '
*F'${num}'::
begin_fkey_function('${num}')
return

*F'${num}' UP::
end_fkey_function('${num}')
return

f'${num}'timer:
++fkey_press_duration['${num}']
return

f'${num}'barriertimer:
function_name := get_fkey_function_name_prefix()
function_name .= "_repeat_while_pressed"
fkey_repeat_action['${num}'] := "run"
%function_name%('${num}')
return

'
}

for num in $fs; do
	if [[ $num =~ ^([1-9]|1[0-9]|2[0-4])$ ]]; then
		echo "fkey_is_ready[${num}] := true" >> "$globals_out"
		echo "fkey_press_duration[${num}] := 0" >> "$globals_out"
		
		flabels "$num" >> "$labels_out"
	fi
done
