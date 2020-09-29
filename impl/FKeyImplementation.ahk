; **
; *	WARNING: adding keys or programs / windows does not require changes here !!
; **


; **
; * On a button press, use this function in the following way: 'fix_duration(adjust_duration(press_duration))'
; * where press_duration is the actual/physical duration the button was pressed.
; * Locks all following button press durations to the one this function was called with, until the
; * the button is either pressed again, or any button is pressed in a window different from the one where the duration was fixed
; **
fix_duration(press_duration) {
	global
	if (press_duration = fixed_duration) {
		fixed_duration := -1
	} else {
		WinGet, fixed_duration_window,, A
		fixed_duration := press_duration
	}
}


; **
; * When duration fix functionality is wanted, use this function instead of directly using the press duration (i.e. it acts as a filter)
; **
adjust_duration(press_duration) {
	global
	if WinActive("ahk_id " . fixed_duration_window) {
		if (fixed_duration < 0) {
			return press_duration
		} else {
			return fixed_duration
		}
	} else {
		fixed_duration := -1
		return press_duration
	}
}


begin_fkey_function(key_num) {
	global fkey_is_ready
	global fkey_press_duration
	global fkey_barrier
	global fkey_repeat_action
	global duration_level_separation_milliseconds
	global gestureactive

	if(fkey_is_ready[key_num]) {
		fkey_is_ready[key_num] := false
		fkey_barrier[key_num] := false
		fkey_press_duration[key_num] := 0

		keyname := "f" . key_num

		timer_label := keyname . "timer"
		SetTimer % timer_label, % duration_level_separation_milliseconds

		if(!gestureactive) {
			function_name := get_fkey_function_name_prefix()
			function_name .= "_repeat_while_pressed"
			fkey_repeat_action[key_num] := "init"
			%function_name%(key_num)

			barrier_timer_label := keyname . "barriertimer"
			SetTimer, %barrier_timer_label%, 20
		}
	}
}

end_fkey_function(key_num) {
	global fkey_is_ready
	global fkey_press_duration
	global fkey_barrier
	global fkey_repeat_action
	global gestureactive
	global gest_str
	global gesture_max_duration_level

	keyname := "f" . key_num

	timer_label := keyname . "timer"
	SetTimer, %timer_label%, Off

	barrier_timer_label := keyname . "barriertimer"
	SetTimer, %barrier_timer_label%, Off

	function_name := get_fkey_function_name_prefix()
	repeat_function := function_name . "_repeat_while_pressed"
	fkey_repeat_action[key_num] := "end"
	%repeat_function%(key_num)

	if(!gestureactive && !fkey_barrier[key_num]) {
		function_name .= "_function"
		%function_name%(key_num,adjust_duration(fkey_press_duration[key_num]))
	} else {
		gest_str .= " f" . key_num . "d"
		if(fkey_press_duration[key_num] > gesture_max_duration_level) {
			fkey_press_duration[key_num] := gesture_max_duration_level
		}
		gest_str .= fkey_press_duration[key_num]
	}
	fkey_is_ready[key_num] := true
}