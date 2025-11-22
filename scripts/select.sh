#!/bin/bash

function print_menu()
{
	local title_item="$1"
    shift
	local selected_item="$1"
    shift

    local function_arguments=($@)
	local menu_items=(${function_arguments[@]:0})
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))

    echo "$title_item"
	for (( i = 0; i < $menu_size; ++i ))
	do
		if [ "$i" = "$selected_item" ]
		then
			echo "-> ${menu_items[i]}"
		else
			echo "   ${menu_items[i]}"
		fi
	done
}

function run_menu()
{
    local title_item="$1"
    shift
	local selected_item="$1"
    shift

    local function_arguments=($@)
	local menu_items=(${function_arguments[@]:0})
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))

	clear
	print_menu "$title_item" "$selected_item" "${menu_items[@]}"
	
	while read -rsn1 input
	do
		case "$input"
		in
			$'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
				# macOS uses an older bash version that doesn't support float timeout
				# note: may be better to go by BASH_VERSION instead
				if [[ "$OSTYPE" == "darwin"* ]]; then
					read -rsn1 -t 1 input
				else
					read -rsn1 -t 0.1 input
				fi

				if [ "$input" = "[" ]  # occurs before arrow code
				then
					if [[ "$OSTYPE" == "darwin"* ]]; then
						read -rsn1 -t 1 input
					else
						read -rsn1 -t 0.1 input
					fi

					case "$input"
					in
						A)  # Up Arrow
							if [ "$selected_item" -ge 1 ]
							then
								selected_item=$((selected_item - 1))
								clear
								print_menu "$title_item" "$selected_item" "${menu_items[@]}"
							fi
							;;
						B)  # Down Arrow
							if [ "$selected_item" -lt "$menu_limit" ]
							then
								selected_item=$((selected_item + 1))
								clear
								print_menu "$title_item" "$selected_item" "${menu_items[@]}"
							fi
							;;
					esac
				fi

				# flushing stdin
				if [[ "$OSTYPE" == "darwin"* ]]; then
					read -rsn5 -t 1 input
				else
					read -rsn5 -t 0.1 input
				fi
				;;
			"")  # Enter key
				return "$selected_item"
				;;
		esac
	done
}
