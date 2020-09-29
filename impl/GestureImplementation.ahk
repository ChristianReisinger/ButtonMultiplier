; **
; *	WARNING: adding gestures or programs / windows does not require changes here !!
; **

initiate_gesture() {
	global

	gestureactive := true
	MouseGetPos, mx, my
	mindist := 15
	dir := ""
	gest_str := ""
	last_dir := ""
	updist := 0
	downdist := 0
	rightdist := 0
	leftdist := 0
	adddir := 0
	SetTimer, checkgesture, 30
}

resolve_gesture() {
	global gest_str
	global gestureactive

	SetTimer, checkgesture, off
	if (gest_str = "" && gestureactive) {
		Click, right

	} else {
		function_name := get_fkey_function_name_prefix()
		function_name .= "_gesture"
		%function_name%(gest_str)
	}
	gestureactive := false
}


checkgesture:
MouseGetPos, mxx, myy
dx := mxx-mx
dy := myy-my
if (dx > 0) {
	rightdist += dx
} else if (dx < 0) {
	leftdist -= dx
}
if (dy > 0) {
	downdist += dy
} else if (dy < 0) {
	updist -= dy
}
if (rightdist >= mindist) {
	dir := "right"
} else if (downdist >= mindist) {
	dir := "down"
} else if (leftdist >= mindist) {
	dir := "left"
} else if (updist >= mindist) {
	dir := "up"
}
if (rightdist >= mindist || downdist >= mindist || leftdist >= mindist || updist >= mindist) {
	rightdist := 0
	downdist := 0
	leftdist := 0
	updist := 0
	adddir := 1
}

if (adddir = 1 && dir != last_dir) {
	gest_str .= " "
	gest_str .= dir
	last_dir := dir
	adddir := 0
}
mx := mxx
my := myy
return


#Include impl\generated\GestureEnable.ahk

#If gesture_enabled()

RButton::
initiate_gesture()
return

RButton UP::
resolve_gesture()
return

#If gesture_enabled() && gestureactive

LButton::
gest_str .= " L"
return

WheelDown::
gest_str .= " WD"
function_name := get_fkey_function_name_prefix()
function_name .= "_wheel_down_gesture"
%function_name%(gest_str)
return

WheelUp::
gest_str .= " WU"
function_name := get_fkey_function_name_prefix()
function_name .= "_wheel_up_gesture"
%function_name%(gest_str)
return

#If