window_move(fkey_num) {
	global fkey_barrier
	global fkey_repeat_action
	global window_move_mouse_x
	global window_move_mouse_y

	ac := fkey_repeat_action[fkey_num]

	if(ac == "run") {
		MouseGetPos, window_move_mouse_new_x, window_move_mouse_new_y
		window_move_mouse_new_x := to_primary_mouse_x(window_move_mouse_new_x)

		dx := window_move_mouse_new_x - window_move_mouse_x
		dy := window_move_mouse_new_y - window_move_mouse_y
		if(dx*dx + dy*dy > 400) {
			fkey_barrier[fkey_num] := true
	
			barrier_timer_label := "f" . fkey_num . "barriertimer"
			SetTimer, %barrier_timer_label%, Off
	
			MouseGetPos, window_move_mouse_x, window_move_mouse_y
			window_move_mouse_x := to_primary_mouse_x(window_move_mouse_x)

			SetTimer, process_window_move, 20
		}
	} else if(ac == "init") {
		MouseGetPos, window_move_mouse_x, window_move_mouse_y
		window_move_mouse_x := to_primary_mouse_x(window_move_mouse_x)

	} else if(ac == "end") {
		SetTimer, process_window_move, Off
	}
}

process_window_move:
MouseGetPos, window_move_mouse_new_x, window_move_mouse_new_y
window_move_mouse_new_x := to_primary_mouse_x(window_move_mouse_new_x)

dx := window_move_mouse_new_x - window_move_mouse_x
dy := window_move_mouse_new_y - window_move_mouse_y
cmnd = "%A_ScriptDir%\util\CycleWindowMonitor.exe" %dx% %dy% 0 0
RunWait, %cmnd%,, Hide

window_move_mouse_x := window_move_mouse_new_x
window_move_mouse_y := window_move_mouse_new_y
return



window_resize(fkey_num) {
	global fkey_barrier
	global fkey_repeat_action
	global window_resize_mouse_x
	global window_resize_mouse_y

	ac := fkey_repeat_action[fkey_num]

	if(ac == "run") {
		MouseGetPos, window_resize_mouse_new_x, window_resize_mouse_new_y
		window_resize_mouse_new_x := to_primary_mouse_x(window_resize_mouse_new_x)

		dx := window_resize_mouse_new_x - window_resize_mouse_x
		dy := window_resize_mouse_new_y - window_resize_mouse_y
		if(dx*dx + dy*dy > 400) {
			fkey_barrier[fkey_num] := true

			barrier_timer_label := "f" . fkey_num . "barriertimer"
			SetTimer, %barrier_timer_label%, Off

			MouseGetPos, window_resize_mouse_x, window_resize_mouse_y
			window_resize_mouse_x := to_primary_mouse_x(window_resize_mouse_x)

			SetTimer, process_window_resize, 20
		}
	} else if (ac == "init") {
		MouseGetPos, window_resize_mouse_x, window_resize_mouse_y
		window_resize_mouse_x := to_primary_mouse_x(window_resize_mouse_x)
	} else if (ac == "end") {
		SetTimer, process_window_resize, Off
	}
}

process_window_resize:
MouseGetPos, window_resize_mouse_new_x, window_resize_mouse_new_y
window_resize_mouse_new_x := to_primary_mouse_x(window_resize_mouse_new_x)

dw := window_resize_mouse_new_x - window_resize_mouse_x
dh := window_resize_mouse_new_y - window_resize_mouse_y
cmnd = "%A_ScriptDir%\util\CycleWindowMonitor.exe" 0 0 %dw% %dh%
RunWait, %cmnd%,, Hide

window_resize_mouse_x := window_resize_mouse_new_x
window_resize_mouse_y := window_resize_mouse_new_y
return



panscroll(fkey_num) {
	global fkey_barrier
	global fkey_repeat_action
	global panscroll_mouse_x
	global panscroll_mouse_y

	ac := fkey_repeat_action[fkey_num]

	if (ac == "run") {
		MouseGetPos, panscroll_mouse_new_x, panscroll_mouse_new_y
		dx := panscroll_mouse_new_x - panscroll_mouse_x
		dy := panscroll_mouse_new_y - panscroll_mouse_y

		if (dx*dx > 400) || (dy*dy > 400) {
			fkey_barrier[fkey_num] := true
			if (dx > 20) {
				Loop % dx/40 {
					SendInput {Right}
					KeyWait, Right, T0.1
				}
			} else if (dx < -20) {
				Loop % -dx/40 {
					SendInput {Left}
					KeyWait, Left, T0.1
				}
			}
			if (dy > 20) {
				Loop % dy/40 {
					SendInput {Down}
					KeyWait, Down, T0.1
				}
			} else if (dy < -20) {
				Loop % -dy/40 {
					SendInput {Up}
					KeyWait, Up, T0.1
				}
			}
		}
	} else if (ac == "init") {
		MouseGetPos, panscroll_mouse_x, panscroll_mouse_y
	}
}

history_scroll(fkey_num) {
	global fkey_barrier
	global fkey_repeat_action
	global history_scroll_delay
	global history_scroll_mouse_x

	ac := fkey_repeat_action[fkey_num]

	if (ac == "run") {
		MouseGetPos, history_scroll_mouse_new_x
		dx := history_scroll_mouse_new_x - history_scroll_mouse_x
		if (dx < -20 || dx > 20) {
			fkey_barrier[fkey_num] := true
			++history_scroll_delay
		} else {
			history_scroll_delay := 0
		}
		if (history_scroll_delay > 2) {
			history_scroll_delay := 0
			if (dx < -20) {
				SendInput {Backspace}
			} else if (dx > 20) {
				SendInput +{Backspace}
			}
		}
	} else if (ac == "init") {
		MouseGetPos, history_scroll_mouse_x
	}
}


loop_enter_after_delay(fkey_num) {
	global fkey_barrier
	global fkey_repeat_action
	global enter_loop_delay
	
	ac := fkey_repeat_action[fkey_num]

	if (ac == "run") {
		++enter_loop_delay
		if (enter_loop_delay == 6) {
			fkey_barrier[fkey_num] := true
			SendInput {Enter}
		} else if (enter_loop_delay > 20) {
			SendInput {Enter}
		}
	} else if (ac == "init") {
		enter_loop_delay := 0
	}
}

hold_drag_button(fkey_num, button, modifier := "none") {
	global fkey_barrier
	global fkey_repeat_action
	global hold_drag_button_mouse_x
	global hold_drag_button_mouse_y

	ac := fkey_repeat_action[fkey_num]

	if (ac == "init") {
		MouseGetPos, hold_drag_button_mouse_x, hold_drag_button_mouse_y
	} else if (ac == "run") {
		MouseGetPos, hold_drag_button_mouse_new_x, hold_drag_button_mouse_new_y
		dx := hold_drag_button_mouse_new_x - hold_drag_button_mouse_x
		dy := hold_drag_button_mouse_new_y - hold_drag_button_mouse_y

		if (dx*dx + dy*dy > 400 && !fkey_barrier[fkey_num]) {
			fkey_barrier[fkey_num] := true
			if (modifier != "none") {
				SendInput {%modifier% down}
			}
			SendInput {%button% down}
		}
	} else if (ac == "end") {
		if (fkey_barrier[fkey_num]) {
			if (modifier != "none") {
				SendInput {%modifier% up}
			}
			SendInput {%button% up}
		}
	}
}