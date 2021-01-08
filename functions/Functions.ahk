FlashMouseCoords() {
	MouseGetPos, fmx, fmy
	ToolTip, % fmx " " fmy
	Sleep 1000
	ToolTip
}

copy_from_clipboard() {
	tmp := ClipboardAll
	Clipboard := ""
	SendInput ^c
	ClipWait
	ret := Clipboard
	Clipboard := tmp
	tmp := ""
	return ret
}

desktop_width() {
	SysGet, monitor_num, MonitorCount
	; 0 should always be a valid coordinate
	x_min := 0
	x_max := 0
	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (boundsLeft < x_min) {
			x_min := boundsLeft
		} else if (boundsRight > x_max) {
			x_max := boundsRight
		}
	}
	return (x_max - x_min)
}

get_ordered_monitor_ids() {
	SysGet, monitor_num, MonitorCount
	remaining_ids := []
	Loop, %monitor_num% {
		remaining_ids.Push(A_Index)
	}

	; find leftmost in remaining, push to ordered, remove from remaining < repeat until none are remaining
	ordered_ids := []
	while (remaining_ids.MaxIndex()) {
		first := true
		for idx, id in remaining_ids {
			SysGet, bounds, Monitor, %id%
			if (first || boundsLeft < x_min) {
				first := false
				x_min := boundsLeft
				leftmost := id
			}
		}
		ordered_ids.Push(leftmost)
		remaining_ids.Delete(leftmost)
	}

	return ordered_ids
}

get_monitor_at(x) {
	; return -1 if x is not a coordinate inside any screen

	SysGet, monitorNum, MonitorCount
	Loop, %monitorNum% {
		SysGet, bounds, Monitor, %A_Index%
		if (boundsLeft <= x && boundsRight > x) {
			return A_Index
		}
	}

	return -1
}

get_next_monitor(monitor_id, steps) {
	SysGet, monitor_num, MonitorCount
	while (steps < 0) {
		steps := steps + monitor_num
	}

	ordered_ids := get_ordered_monitor_ids()
	for idx, id in ordered_ids {
		if (id == monitor_id) {
			curr_i := idx
			break
		}
	}
	next_i := Mod(curr_i - 1 + steps, ordered_ids.MaxIndex()) + 1
	return ordered_ids[next_i]
}

; ----------------------------- from here: unused .. testing fixes .. -----------------------------

get_monitor_at_window(hwnd) {
	monitor_id := 1
	VarSetCapacity(info, 40)
	NumPut(40, info)
	if (hmon := DllCall("MonitorFromWindow", "uint", hwnd, "uint", 0x2)) && DllCall("GetMonitorInfo", "uint", hmon, "uint", &info) {
		left := NumGet(info, 4, "Int")

		SysGet, monitor_num, MonitorCount
		Loop, %monitor_num% {
			SysGet, bounds, Monitor, %A_Index%
			if (boundsLeft == left) {
				monitor_id := A_Index
			}
		}
	} else {
		throw "failed to find monitor of the active window"
	}
	return monitor_id
}

get_desktop_bounds() {
	desktop_bounds := []

	SysGet, monitor_num, MonitorCount
	first := true
	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (first || boundsLeft < desktop_left) {
			desktop_left := boundsLeft
		}
		if (first || boundsRight > desktop_right) {
			desktop_right := boundsRight
		}
		first := false
	}
	desktop_bounds.Push(desktop_left)
	desktop_bounds.Push(desktop_right)
	return desktop_bounds
}

; transforms x to a coordinate in the coordinate system of the monitor that it would be *visually* at
; where x is a position relative to the monitor with id x_monitor_id, e.g. retrieved with WinGetPos
; e.g. for monitors |  1  |  2  |
;	an x visually on monitor 1, but represented in the system of 2 as coordinate that is less than the left boundary of 2, 
;	will be transformed to be represented in the coordinate system of 1
; does not cycle x, i.e. the result can still be smaller/bigger than the left/right boundary of the left-/right-most monitor
to_underlying_monitor_x(x_monitor_id, x) {
	dpi_scale := [1, 1.75, 1]

	SysGet, curr_bounds, Monitor, %x_monitor_id%

	; ----- get pos of the monitor w.r.t. which x is given -----
	ordered_monitor_ids := get_ordered_monitor_ids()
	for idx, id in ordered_monitor_ids {
		if (id == x_monitor_id) {
			curr_mon_idx := idx
			break
		}
	}

	while (x < curr_boundsLeft) {
		if (curr_mon_idx == ordered_monitor_ids.MinIndex()) {
			return x
		}
		distance_to_edge := (x - curr_boundsLeft) / dpi_scale[curr_mon_idx]
		--curr_mon_idx
		next_mon_id := ordered_monitor_ids[curr_mon_idx]
		SysGet, curr_bounds, Monitor, %next_mon_id%
		x := curr_boundsRight + distance_to_edge * dpi_scale[curr_mon_idx]
	}

	while (x >= curr_boundsRight) {
		if (curr_mon_idx == ordered_monitor_ids.MaxIndex()) {
			return x
		}
		distance_to_edge := (x - curr_boundsRight) / dpi_scale[curr_mon_idx]
		++curr_mon_idx
		next_mon_id := ordered_monitor_ids[curr_mon_idx]
		SysGet, curr_bounds, Monitor, %next_mon_id%
		x := curr_boundsLeft + distance_to_edge * dpi_scale[curr_mon_idx]
	}

	return x
}

; convert a mouse coord x to primary-monitor-relative x without possible gaps between monitors
; x must be result from MouseGetPos > the returned x should never be inside a gap
to_primary_mouse_x(x) {
	SysGet, primary_mon_id, MonitorPrimary
	SysGet, curr_bounds, Monitor, %primary_mon_id%
	if (x >= curr_boundsLeft && x < curr_boundsRight) {
		return x
	}

	; ----- get primary monitor position -----
	ordered_monitor_ids := get_ordered_monitor_ids()
	for idx, id in ordered_monitor_ids {
		if (id == primary_mon_id) {
			primary_mon_idx := idx
		}
	}

	; ----- shift coords of monitors to the right of primary -----
	x_shift := 0
	Loop % ordered_monitor_ids.MaxIndex() - primary_mon_idx {
		id := ordered_monitor_ids[primary_mon_idx + A_Index]
		SysGet, next_bounds, Monitor, %id%
		x_shift += next_boundsLeft - curr_boundsRight
		if (x >= next_boundsLeft && x < next_boundsRight) {
			return x - x_shift
		}
		curr_bounds := next_bounds
	}

	; ----- shift coords of monitors to the left of primary -----
	x_shift := 0
	Loop % primary_mon_idx - 1 {
		id := ordered_monitor_ids[primary_mon_idx - A_Index]
		SysGet, next_bounds, Monitor, %id%
		x_shift += next_boundsRight - curr_boundsLeft
		if (x >= next_boundsLeft && x < next_boundsRight) {
			return x - x_shift
		}
		curr_bounds := next_bounds
	}	

	throw "Invalid mouse x coord"
}

; --------------------------------------------- end of unused -------------------------------------

translate_x(x, dx) {
	; with desktop scaling, windows may leave gaps in the coordinate system ..
	; use this function to translate x by dx, accounting for possible gaps (i.e. the result is always a valid coordinate on some screen)

	n := get_monitor_at(x)
	SysGet, bounds, Monitor, %n%
	if (dx < 0) {
		; since dx < 0
		distance_to_edge := boundsLeft - x
		if (dx < distance_to_edge) {
			remaining_dx := dx - distance_to_edge - 1
			next_monitor := get_next_monitor(n, -1)
			SysGet, next_bounds, Monitor, %next_monitor%
			return translate_x(next_boundsRight - 1, remaining_dx)
		} else {
			return x + dx
		}
	} else {
		distance_to_edge := boundsRight - x
		if (dx > distance_to_edge) {
			remaining_dx := dx - distance_to_edge
			next_monitor := get_next_monitor(n, 1)
			SysGet, next_bounds, Monitor, %next_monitor%
			return translate_x(next_boundsLeft, remaining_dx)
		} else {
			return x + dx
		}
	}

	; something is wrong if this is reached ..
	return x + dx
}

ChangeActiveWinMonitor(steps) {
	if (steps == 0) {
		return
	}

	go_backwards := false
	if (steps < 0) {
		go_backwards := true
	}

	; "simulate" going backward by going forward the corresponding number of steps
	SysGet, monitor_num, MonitorCount
	while (steps < 0) {
		steps := steps + monitor_num
	}
	steps := Mod(steps, monitor_num)

	first := true
	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (first || boundsLeft < min_x) {
			min_x := boundsLeft
			leftmost_monitor_width := boundsRight - boundsLeft
		}
		if (first || boundsRight > max_x) {
			max_x := boundsRight
			rightmost_monitor_width := boundsRight - boundsLeft
		}
		first := false
	}

	WinGetPos, win_x, win_y, win_width, win_height, A
	if (win_x + win_width < min_x || win_x > max_x) {
		; if window fully out of view, move to center of outermost screen, and ignore steps
		if (go_backwards) {
			WinMove, A,, max_x - rightmost_monitor_width / 2 - win_width / 2, win_y
		} else {
			WinMove, A,, min_x + leftmost_monitor_width / 2 - win_width / 2, win_y
		}		
	} else {
		; if window is not fully out of view, but its center is off-screen to the right/left and
		;	(1) steps is negative/positive, then place its center on the nearest outermost screen
		; 	(2) steps is positive/negative, then pretend both outer screens are connected and place it on the screen that it is currently not on.
		;		This is the same as (1), but without decreasing the number of steps

		win_center_x := win_x + win_width / 2
		if (win_center_x > max_x) {
			win_center_x := win_center_x - rightmost_monitor_width
			if (go_backwards) {
				steps := steps + 1
			}
		} else if (win_center_x < min_x) {
			win_center_x := win_center_x + leftmost_monitor_width
			if (!go_backwards) {
				steps := steps - 1
			}
		}
		; now 'min_x < win_center_x < max_x' is guaranteed

		n := get_monitor_at(win_center_x)
		SysGet, curr_bounds, Monitor, %n%
		curr_width := curr_boundsRight - curr_boundsLeft
		screen_rel_center_x := (win_center_x - curr_boundsLeft) / curr_width

		m := get_next_monitor(n, steps)
		SysGet, next_bounds, Monitor, %m%
		next_width := next_boundsRight - next_boundsLeft
		new_win_center_x := translate_x(next_boundsLeft, screen_rel_center_x * next_width)
		new_win_x := translate_x(new_win_center_x, - win_width / 2)

		WinMove, A,, new_win_x, win_y
		WinMove, A,, new_win_x, win_y, win_width, win_height
	}
}

black_out_monitors() {

	Gui, black_out_monitor_gui:+LastFoundExist
	if WinExist() {
		Gui, black_out_monitor_gui:Destroy
	} else {

		min_x := 0
		max_x := 0
		min_y := 0
		max_y := 0

		SysGet, monitor_num, MonitorCount
		Loop, %monitor_num% {
			SysGet, bounds, Monitor, %A_Index%
			if (boundsLeft < min_x) {
				min_x := boundsLeft
			}
			if (boundsRight > max_x) {
				max_x := boundsRight
			}
			if (boundsTop < min_y) {
				min_y := boundsTop
			}
			if (boundsBottom > max_y) {
				max_y := boundsBottom
			}
		}
		width := max_x - min_x
		height := max_y - min_y

		WinGet, curr_win,, A
		Gui, black_out_monitor_gui:Color, black
		Gui, black_out_monitor_gui:+AlwaysOnTop
		Gui, black_out_monitor_gui:-Caption
		Gui, black_out_monitor_gui:Show, x%min_x% y%min_y% w%width% h%height%, MonitorDark
		WinActivate, ahk_id %curr_win%
	}
}

black_out_monitor_guiGuiClose:
Gui, black_out_monitor_gui:Destroy
return

CopySelectedFileName() {
	Clipboard =
	Send ^c
	ClipWait
	clpbrd := Clipboard
	SplitPath, clpbrd,,,, fname
	return fname
}

minimize_and_remember_window() {
	global recent_minimized_window
	if(recent_minimized_window == "") {
		recent_minimized_window := Array()
	}
	WinGet, win,, A
	recent_minimized_window.Push(win)
	if(recent_minimized_window.Length() > 10) {
		recent_minimized_window.RemoveAt(recent_minimized_window.MinIndex())
	}
	WinMinimize, ahk_id %win%
	WinWaitNotActive, ahk_id %win%
	WinActivate, A
}

restore_recent_minimized_window() {
	global recent_minimized_window
	win := recent_minimized_window.Pop()

	WinActivate, ahk_id %win%
}

monitors_off() {
	SendMessage 0x112, 0xF170, 2, , Program Manager
}

repeat_string(str, repeat_num) {
	Loop, %repeat_num%
		out .= str
	return out
}

move_mouse_to_window_center() {
	WinGetPos, winx, winy, winw, winh, A
	MouseMove, winx+winw/2, winy+winh/2, 0
}


RemoveToolTipTimer:
SetTimer, RemoveToolTipTimer, Off
ToolTip
return