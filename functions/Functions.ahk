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

get_ordered_monitor_ids() {
	; ----- prevent computing often .. reload script when monitor configuration changes ----
	global buttonmultiplier_functions_ordered_monitor_ids
	if(IsObject(buttonmultiplier_functions_ordered_monitor_ids)) {
		return buttonmultiplier_functions_ordered_monitor_ids
	}

	SysGet, monitor_num, MonitorCount
	remaining_ids := []
	Loop, %monitor_num% {
		remaining_ids.Push(A_Index)
	}

	; find leftmost in remaining, push to ordered, remove from remaining < repeat until none are remaining
	buttonmultiplier_functions_ordered_monitor_ids := []
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
		buttonmultiplier_functions_ordered_monitor_ids.Push(leftmost)
		remaining_ids.Delete(leftmost)
	}

	return buttonmultiplier_functions_ordered_monitor_ids
}

get_monitor_x_shifts() {
	global buttonmultiplier_function_monitor_x_shifts
	if(IsObject(buttonmultiplier_function_monitor_x_shifts)) {
		return buttonmultiplier_function_monitor_x_shifts
	}

	ordered_monitor_ids := get_ordered_monitor_ids()
	buttonmultiplier_function_monitor_x_shifts := []

	for idx, id in ordered_monitor_ids {
		SysGet, right_bounds, Monitor, %id%
		if (idx > ordered_monitor_ids.MinIndex()) {
			buttonmultiplier_function_monitor_x_shifts.Push(right_boundsLeft - left_boundsRight)
		}
		left_boundsLeft := right_boundsLeft
		left_boundsRight := right_boundsRight
	}

	return buttonmultiplier_function_monitor_x_shifts
}

; convert a mouse coord x to primary-monitor-relative x without possible gaps between monitors
; x must be result from MouseGetPos > the returned x should never be inside a gap
to_primary_mouse_x(x) {
	ordered_monitor_ids := get_ordered_monitor_ids()
	shifts := get_monitor_x_shifts()
	SysGet, primary_id, MonitorPrimary

	; get pos of monitor at x and primary monitor
	for idx, id in ordered_monitor_ids {
		SysGet, bounds, Monitor, %id%
		if (x >= boundsLeft && x < boundsRight) {
			curr_idx := idx
		}
		if (id == primary_id) {
			primary_idx := idx
		}
	}
	
	tot_shift := 0
	for idx, sh in shifts {
		if (idx >= curr_idx && idx < primary_idx) {
			tot_shift += sh
		} else if (idx >= primary_idx && idx < curr_idx) {
			tot_shift -= sh
		}
	}

	return x + tot_shift
}

ChangeActiveWinMonitor(steps) {
	cmnd = "%A_ScriptDir%\util\CycleWindowMonitor.exe" %steps%
	Run, %cmnd%,, Hide
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