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

get_monitor_at(x) {
	; return -1 if x is a coordinate outside the desktop

	SysGet, monitorNum, MonitorCount
	Loop, %monitorNum% {
		SysGet, bounds, Monitor, %A_Index%
		if (boundsLeft <= x && boundsRight > x) {
			return A_Index
		}
	}
	return -1
}

get_next_monitor(monitor_id) {
	; unspecified behavior if monitors are not side-by-side (i.e. each desktops left/right boundary matches the right/left boundary of the desktop to its left/right),
	; in which case this function may return -1

	SysGet, monitor_num, MonitorCount
	min_x := 0
	max_x := 0
	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (boundsLeft < min_x) {
			min_x:=boundsLeft
		}
		if (boundsRight > max_x) {
			max_x:=boundsRight
		}
	}
	tot_desktop_width := max_x - min_x
	SysGet, curr_bounds, Monitor, %monitor_id%
	next_monitor_left := Mod(curr_boundsRight - min_x, tot_desktop_width)

	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (Mod(boundsLeft - min_x, tot_desktop_width) == next_monitor_left) {
			return A_Index
		}
	}

	return -1
}

ChangeActiveWinMonitor(steps) {
	; NOTE: limitations - see get_next_monitor(..)
	; TODO: do nothing if limitations are not fulfilled ..

	SysGet, monitor_num, MonitorCount

	steps := steps < 0 ? (-1 * Mod(Abs(steps), monitor_num)) : Mod(steps, monitor_num)

	if (steps == 0) {
		return
	}

	min_x := 0
	max_x := 0
	leftmost_monitor_width := 0
	rightmost_monitor_width := 0

	Loop, %monitor_num% {
		SysGet, bounds, Monitor, %A_Index%
		if (boundsLeft < min_x) {
			min_x := boundsLeft
			leftmost_monitor_width := boundsRight - boundsLeft
		}
		if (boundsRight > max_x) {
			max_x := boundsRight
			rightmost_monitor_width := boundsRight - boundsLeft
		}
	}
	WinGetPos, win_x, win_y, win_width,, A

	if (win_x + win_width < min_x || win_x > max_x) {
		; if window fully out of view, move to center of outermost screen, and ignored the absolute value of steps

		if (steps < 0) {
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
			if (steps < 0) {
				steps := steps + 1
			}
		} else if (win_center_x < min_x) {
			win_center_x := win_center_x + leftmost_monitor_width
			if (steps > 0) {
				steps := steps - 1
			}
		}

		; now 'min_x < win_center_x < max_x' is guaranteed

		n := get_monitor_at(win_center_x)
		SysGet, curr_bounds, Monitor, %n%
		screen_rel_center_x := (win_center_x - curr_boundsLeft) / (curr_boundsRight - curr_boundsLeft)

		m := n
		next_steps := steps < 0 ? monitor_num + steps : steps
		Loop, %next_steps% {
			m := get_next_monitor(m)
		}
		SysGet, next_bounds, Monitor, %m%

		win_center_x := next_boundsLeft + screen_rel_center_x * (next_boundsRight - next_boundsLeft)

		WinMove, A,, win_center_x - win_width / 2, win_y
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