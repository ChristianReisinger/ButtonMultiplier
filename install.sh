#!/bin/bash


script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

(cd "${script_dir}/install"
	./init_user.sh
	./generate_settings.sh
	./generate_labels.sh
	./generate_windows.sh
)


